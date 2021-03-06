package io.rackshift.strategy.statemachine;

import com.alibaba.fastjson.JSONObject;
import io.rackshift.constants.ExecutionLogConstants;
import io.rackshift.constants.PluginConstants;
import io.rackshift.constants.ServiceConstants;
import io.rackshift.manager.BareMetalManager;
import io.rackshift.metal.sdk.IMetalProvider;
import io.rackshift.metal.sdk.util.CloudProviderManager;
import io.rackshift.model.RSException;
import io.rackshift.model.WorkflowRequestDTO;
import io.rackshift.mybatis.domain.BareMetal;
import io.rackshift.mybatis.domain.Task;
import io.rackshift.service.ExecutionLogService;
import io.rackshift.service.TaskService;
import io.rackshift.service.WorkflowService;
import io.rackshift.utils.ExceptionUtils;
import io.rackshift.utils.Translator;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public abstract class AbstractHandler implements IStateHandler {
    @Resource
    private BareMetalManager bareMetalManager;
    @Resource
    protected ExecutionLogService executionLogService;
    @Autowired
    private SimpMessagingTemplate template;
    @Resource
    private CloudProviderManager metalProviderManager;
    @Resource
    private TaskService taskService;
    @Resource
    private WorkflowService workflowService;

    protected BareMetal getBareMetalById(String id) {
        return bareMetalManager.getBareMetalById(id);
    }

    protected List<LifeStatus> preStatus = new ArrayList<LifeStatus>() {{
        add(LifeStatus.ready);
        add(LifeStatus.allocated);
        add(LifeStatus.deployed);
    }};

    protected List<String> preProcessRaidWf = new ArrayList<String>() {{
        add("Graph.Raid.Create.HpssaRAID");
        add("Graph.Raid.Create.AdaptecRAID");
        add("Graph.Raid.Create.PercRAID");
    }};

    public abstract void handleYourself(LifeEvent event) throws Exception;

    @Override
    public void handleNoSession(LifeEvent event) {
        String taskId = event.getWorkflowRequestDTO().getTaskId();
        Task task = taskService.getById(taskId);
        try {
            handleYourself(event);
        } catch (Exception e) {
            executionLogService.saveLogDetail(taskId, task.getUserId(), ExecutionLogConstants.OperationEnum.ERROR.name(), event.getBareMetalId(), String.format("?????????%s", ExceptionUtils.getExceptionDetail(e)));
        }
    }

    @Override
    public void handle(LifeEvent event) {
        BareMetal bareMetal = getBareMetalById(event.getWorkflowRequestDTO().getBareMetalId());
        Task task = taskService.getById(event.getWorkflowRequestDTO().getTaskId());
        if (StringUtils.isAnyBlank(bareMetal.getEndpointId(), bareMetal.getServerId())) {
            executionLogService.saveLogDetail(task.getId(), task.getUserId(), ExecutionLogConstants.OperationEnum.ERROR.name(), event.getBareMetalId(), "?????????????????????discovery??????,??????????????????");
            revert(event);
            return;
        }

        try {
            paramPreProcess(event);
            handleYourself(event);
        } catch (Exception e) {
            executionLogService.saveLogDetail(task.getId(), task.getUserId(), ExecutionLogConstants.OperationEnum.ERROR.name(), event.getBareMetalId(), String.format("?????????%s", ExceptionUtils.getExceptionDetail(e)));
            revert(event);
            throw new RuntimeException(e);
        }
    }

    private void paramPreProcess(LifeEvent event) {
        String taskId = event.getWorkflowRequestDTO().getTaskId();
        String user = taskService.getById(taskId).getUserId();
        if (preProcessRaidWf.contains(event.getWorkflowRequestDTO().getWorkflowName())) {
            if (Optional.of(event.getWorkflowRequestDTO()).isPresent()) {
                WorkflowRequestDTO workflowRequestDTO = event.getWorkflowRequestDTO();
                JSONObject params = workflowRequestDTO.getParams();

                IMetalProvider iMetalProvider = metalProviderManager.getCloudProvider(PluginConstants.PluginType.getPluginByBrand(getBareMetalById(event.getBareMetalId()).getMachineBrand()));
                if (params != null) {
                    JSONObject param = iMetalProvider.getRaidPayLoad(params.toJSONString());
                    executionLogService.saveLogDetail(taskId, user, ExecutionLogConstants.OperationEnum.START.name(), event.getBareMetalId(), String.format("??????????????????????????????:%s", (Optional.ofNullable(param).orElse(new JSONObject())).toJSONString()));
                    workflowRequestDTO.setParams(param);
                }
            }
        }
    }

    @Override
    public void revert(LifeEvent event) {
        Task task = taskService.getById(event.getWorkflowRequestDTO().getTaskId());
        task.setStatus(ServiceConstants.TaskStatusEnum.failed.name());
        taskService.update(task);
        changeStatus(event, LifeStatus.ready, false);
        executionLogService.saveLogDetail(task.getId(), task.getUserId(), ExecutionLogConstants.OperationEnum.ERROR.name(), event.getBareMetalId(), String.format("?????????event:%s:worflow:%ss,??????:%s,???????????????%s", event.getEventType().getDesc(), Optional.ofNullable(event.getWorkflowRequestDTO().getWorkflowName()).orElse("???"), (Optional.ofNullable(event.getWorkflowRequestDTO().getParams()).orElse(new JSONObject())).toJSONString(), LifeStatus.ready));
    }

    protected void beforeChange(LifeStatus curStatus) {
        if (!preStatus.contains(curStatus)) RSException.throwExceptions(Translator.get("status_not_valid"));
    }

    protected void changeStatus(LifeEvent event, LifeStatus status, boolean needCheckStatus) {
        WorkflowRequestDTO requestDTO = event.getWorkflowRequestDTO();
        BareMetal bareMetal = getBareMetalById(requestDTO.getBareMetalId());
        if (needCheckStatus) {
            beforeChange(LifeStatus.valueOf(bareMetal.getStatus()));
        }
        bareMetal.setStatus(status.name());
        bareMetalManager.update(bareMetal, true);
        notifyWebSocket(bareMetal, taskService.getById(event.getWorkflowRequestDTO().getTaskId()));
    }

    protected void notifyWebSocket(BareMetal bareMetal, Task task) {
        String status = bareMetal.getStatus();
        String taskStatus = task.getStatus();
        try {
            status = Translator.get(status);
            taskStatus = Translator.get(taskStatus);
        } catch (Exception e) {
        }
        template.convertAndSend("/topic/lifecycle", String.format("????????????%s,??????????????????%s", bareMetal.getMachineModel() + " " + bareMetal.getManagementIp(), status));
        String msg = String.format("????????????%s,???????????????%s,??????????????????%s", bareMetal.getMachineModel() + " " + bareMetal.getManagementIp(), workflowService.getFriendlyName(task.getWorkFlowId()), taskStatus);
        if (ServiceConstants.TaskStatusEnum.running.name().equalsIgnoreCase(task.getStatus())) {
            msg = String.format("????????????%s,???????????????%s,??????????????????%s", bareMetal.getMachineModel() + " " + bareMetal.getManagementIp(), workflowService.getFriendlyName(task.getWorkFlowId()), taskStatus);
        }
        template.convertAndSend("/topic/taskLifecycle", msg);
    }
}
