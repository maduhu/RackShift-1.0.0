package io.rackshift.controller;

import com.github.pagehelper.Page;
import com.github.pagehelper.PageHelper;
import io.rackshift.constants.AuthorizationConstants;
import io.rackshift.model.BareMetalQueryVO;
import io.rackshift.model.ResultHolder;
import io.rackshift.mybatis.domain.BareMetal;
import io.rackshift.service.BareMetalService;
import io.rackshift.utils.PageUtils;
import org.apache.shiro.authz.annotation.RequiresRoles;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

@RestController
@RequestMapping("bare-metal")
public class BareMetalController {
    @Resource
    private BareMetalService bareMetalService;

    @PostMapping("/list/{page}/{pageSize}")
    public ResultHolder list(@PathVariable int page, @PathVariable int pageSize, @RequestBody BareMetalQueryVO queryVO) {
        Page<BareMetal> pager = PageHelper.startPage(page, pageSize);
        return ResultHolder.success(PageUtils.setPageInfo(pager, bareMetalService.list(queryVO)));
    }

    @GetMapping("/power/{id}/{power}")
    public ResultHolder power(@PathVariable String id, @PathVariable String power) {
        return bareMetalService.power(id, power);
    }

    @PostMapping("/power/{power}")
    public ResultHolder powerBatch(@RequestBody String[] ids, @PathVariable String power) {
        return bareMetalService.powerBatch(ids, power);
    }

    @GetMapping("/hardwares/{bareId}")
    public ResultHolder hardwares(@PathVariable String bareId) {
        return bareMetalService.hardwares(bareId);
    }


    @RequiresRoles(AuthorizationConstants.ROLE_ADMIN)
    @PostMapping("del")
    public ResultHolder del(@RequestBody String[] ids) {
        return ResultHolder.success(bareMetalService.del(ids));
    }
}
