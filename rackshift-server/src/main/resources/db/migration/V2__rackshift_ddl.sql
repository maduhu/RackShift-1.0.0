CREATE TABLE IF NOT EXISTS `role` (
    `id`          varchar(50) NOT NULL COMMENT 'Role ID',
    `name`        varchar(64) NOT NULL COMMENT 'Role name',
    `description` varchar(255) DEFAULT NULL COMMENT 'Role description',
    `type`        varchar(50)  DEFAULT NULL COMMENT 'Role type, (system|organization|workspace)',
    `create_time` bigint(13)  NOT NULL COMMENT 'Create timestamp',
    `update_time` bigint(13)  NOT NULL COMMENT 'Update timestamp',
    PRIMARY KEY (`id`)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `system_parameter` (
    `param_key`   varchar(64) CHARACTER SET utf8mb4 NOT NULL COMMENT 'Parameter name',
    `param_value` varchar(255)                               DEFAULT NULL COMMENT 'Parameter value',
    `type`        varchar(100)                      NOT NULL DEFAULT 'text' COMMENT 'Parameter type',
    `sort`        int(5)                                     DEFAULT NULL COMMENT 'Sort',
    PRIMARY KEY (`param_key`)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `user` (
    `id`                   varchar(50) COLLATE utf8mb4_bin NOT NULL COMMENT 'User ID',
    `name`                 varchar(64) NOT NULL COMMENT 'User name',
    `email`                varchar(64) NOT NULL COMMENT 'E-Mail address',
    `password`             varchar(256) COLLATE utf8mb4_bin DEFAULT NULL,
    `status`               varchar(50) NOT NULL COMMENT 'User status',
    `create_time`          bigint(13)  NOT NULL COMMENT 'Create timestamp',
    `update_time`          bigint(13)  NOT NULL COMMENT 'Update timestamp',
    `language`             varchar(30)  DEFAULT NULL,
    `last_workspace_id`    varchar(50)  DEFAULT NULL,
    `last_organization_id` varchar(50)  DEFAULT NULL,
    `phone`                varchar(50)  DEFAULT NULL COMMENT 'Phone number of user',
    PRIMARY KEY (`id`)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `user_role`
(
    `id`          varchar(50) NOT NULL COMMENT 'ID of user''s role info',
    `user_id`     varchar(50) NOT NULL COMMENT 'User ID of this user-role info',
    `role_id`     varchar(50) NOT NULL COMMENT 'Role ID of this user-role info',
    `source_id`   varchar(50) DEFAULT NULL COMMENT 'The (system|organization|workspace) ID of this user-role info',
    `create_time` bigint(13)  NOT NULL COMMENT 'Create timestamp',
    `update_time` bigint(13)  NOT NULL COMMENT 'Update timestamp',
    PRIMARY KEY (`id`)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `out_band`
(
    `id`                      varchar(200) NOT NULL,
    `bare_metal_id`           varchar(50)  NOT NULL DEFAULT '' COMMENT '?????????id',
    `endpoint_id`             varchar(50)  NOT NULL DEFAULT '' COMMENT 'enpoint id',
    `mac`                     varchar(200) NOT NULL DEFAULT '',
    `ip`                      varchar(35)  NOT NULL DEFAULT '',
    `user_name`               varchar(100) NOT NULL DEFAULT '' COMMENT '?????????????????????',
    `pwd`                     varchar(200) NOT NULL DEFAULT '' COMMENT '??????????????????',
    `status`                  varchar(10)  NOT NULL DEFAULT 'off' COMMENT '??????????????????????????????????????????on:??????,off:??????',
    `update_time`             bigint(20)   NOT NULL COMMENT '????????????',
    `origin`                  tinyint(4)            DEFAULT '0' COMMENT '??????,1:???????????????2????????????3???RackHD???????????????4:RackHD???????????????5???RackHD????????????',
    `asset_id`                varchar(100)          DEFAULT NULL COMMENT '??????ID',
    `machine_room`            varchar(100)          DEFAULT NULL COMMENT '??????',
    `machine_rack`            varchar(100)          DEFAULT NULL COMMENT '??????',
    `u_number`                varchar(50)           DEFAULT NULL COMMENT 'U???',
    `remark`                  varchar(1000)         DEFAULT NULL COMMENT '??????',
    `apply_user`              varchar(100)          DEFAULT NULL COMMENT '?????????',
    `optimistic_lock_version` int(11)      NOT NULL DEFAULT '0' COMMENT '?????????',
    PRIMARY KEY (`id`),
    UNIQUE KEY `IDX_OUT_BOUND_IP` (`ip`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `bare_metal`
(
    `id`            varchar(64) NOT NULL,
    `endpoint_id`   varchar(50) NOT NULL DEFAULT '' COMMENT 'enpoint id',
    `hostname`      varchar(50) NOT NULL DEFAULT '' COMMENT '?????????hostname',
    `machine_type`  varchar(64)          DEFAULT NULL comment '??????????????????compute???pdu...',
    `cpu`           int(8)               DEFAULT NULL comment '??????cpu',
    `cpu_type`      varchar(45)          DEFAULT NULL comment 'cpu??????',
    `cpu_fre`       varchar(10) NOT NULL DEFAULT '' COMMENT 'CPU??????',
    `core`          int(11)     NOT NULL DEFAULT '1' COMMENT '??????cpu????????????',
    `thread`        int(11)     NOT NULL DEFAULT '1' COMMENT '??????cpu?????????????????????',
    `memory`        int(8)               DEFAULT NULL comment '???????????????GB',
    `memory_type`   varchar(45)          DEFAULT NULL comment '????????????',
    `disk_type`     varchar(45)          DEFAULT NULL comment '????????????',
    `disk`          int(8)               DEFAULT NULL comment '???????????????GB',
    `management_ip` varchar(15)          DEFAULT NULL comment '??????????????????',
    `bmc_mac`       varchar(20)          DEFAULT NULL COMMENT 'bmc??????mac??????',
    `ip_array`      varchar(500)         DEFAULT NULL comment '??????ip??????',
    `os_type`       varchar(128)         DEFAULT NULL comment ' os',
    `os_version`    varchar(50)          DEFAULT '' COMMENT 'os??????',
    `machine_brand` varchar(64)          DEFAULT NULL comment '????????????',
    `machine_model` varchar(45)          DEFAULT NULL comment '????????????',
    `server_id`     varchar(64)          DEFAULT NULL comment '??????rackhdid',
    `machine_sn`    varchar(64)          DEFAULT NULL comment '?????????',
    `status`        varchar(20)          DEFAULT NULL comment '??????',
    `power`         varchar(10) NOT NULL DEFAULT 'on' COMMENT '???????????????',
    `workspace_id`  varchar(64)          DEFAULT NULL,
    `recycled_time` bigint(20)           DEFAULT '0',
    `ssh_user`      varchar(50)          DEFAULT NULL,
    `ssh_pwd`       varchar(100)         DEFAULT NULL,
    `ssh_port`      int(10)              DEFAULT '22',
    `provider_id`   varchar(64)          DEFAULT NULL,
    `rule_id`       varchar(64) NOT NULL,
    `apply_user`    varchar(50)          DEFAULT '' COMMENT '?????????',
    `create_time`   bigint(20)           DEFAULT NULL,
    `update_time`   bigint(20)           DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `bare_metal_management_ip_index` (`management_ip`) USING BTREE,
    KEY `bare_metal_provider_id_index` (`provider_id`) USING BTREE,
    KEY `bare_metal_rule_id_index` (`rule_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;


CREATE TABLE if not exists `network`
(
    `id`          varchar(50) CHARACTER SET utf8mb4 NOT NULL,
    `endpoint_id` varchar(50)                       NOT NULL DEFAULT '' COMMENT 'enpoint id',
    `name`        varchar(45) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????',
    `vlan_id`     varchar(50) CHARACTER SET utf8mb4          DEFAULT NULL COMMENT 'VLANID',
    `start_ip`    varchar(50) CHARACTER SET utf8mb4          DEFAULT NULL COMMENT 'start_ip',
    `end_ip`      varchar(50) CHARACTER SET utf8mb4          DEFAULT NULL COMMENT 'end_ip',
    `netmask`     varchar(50) CHARACTER SET utf8mb4          DEFAULT NULL COMMENT 'netmask',
    `dhcp_enable` bit COLLATE utf8mb4_bin                    default 0 COMMENT '????????????DHCP',
    `pxe_enable`  bit COLLATE utf8mb4_bin                    default 0 COMMENT '????????????PXE',
    `create_time` bigint(13)                        NOT NULL COMMENT '????????????',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT ='IP?????????';


CREATE TABLE if not exists `image`
(
    `id`             varchar(50) NOT NULL,
    `endpoint_id`    varchar(50) NOT NULL DEFAULT '' COMMENT 'enpoint id',
    `name`           varchar(50) NOT NULL DEFAULT '' COMMENT '????????????',
    `os`             varchar(50)          DEFAULT NULL COMMENT '????????????',
    `os_version`     varchar(50)          DEFAULT NULL COMMENT '??????????????????',
    `url`            varchar(250)         DEFAULT NULL COMMENT 'url',
    `original_name`            varchar(250)         DEFAULT NULL COMMENT '????????????',
    `file_path`            varchar(250)         DEFAULT NULL COMMENT '??????????????????????????????',
    `mount_path`            varchar(250)         DEFAULT NULL COMMENT '?????????????????????',
    `ext_properties` longtext COMMENT '????????????',
    `update_time`    bigint(20)  NOT NULL DEFAULT '0' COMMENT '????????????',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `bare_metal_rule`
(
    `id`                  varchar(64) COLLATE utf8_bin NOT NULL,
    `name`                varchar(64) COLLATE utf8_bin          DEFAULT NULL,
    `start_ip`            varchar(64) COLLATE utf8_bin          DEFAULT NULL,
    `end_ip`              varchar(64) COLLATE utf8_bin          DEFAULT NULL,
    `mask`                varchar(64) COLLATE utf8_bin          DEFAULT NULL,
    `provider_id`         varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
    `credential_param`    longtext COLLATE utf8_bin,
    `sync_status`         varchar(64) COLLATE utf8_bin NOT NULL DEFAULT 'PENDING',
    `last_sync_timestamp` bigint(20)                            DEFAULT '0',
    PRIMARY KEY (`id`),
    KEY `bare_metal_ip_sync_status_index` (`sync_status`) USING BTREE,
    KEY `bare_metal_ip_start_ip_index` (`start_ip`) USING BTREE,
    KEY `bare_metal_ip_end_ip_index` (`end_ip`) USING BTREE,
    KEY `bare_metal_rule_provider_id_index` (`provider_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COLLATE = utf8_bin;

CREATE TABLE if not exists `disk`
(
    `id`            varchar(50) NOT NULL,
    `bare_metal_id` varchar(50) NOT NULL DEFAULT '' COMMENT '?????????id',
    `enclosure_id`  int(11)     NOT NULL DEFAULT '0' COMMENT '?????????raid???enclosure_id???????????????perccli??????storcli???????????????,raid??????',
    `controller_id` int(11)     NOT NULL DEFAULT '0' COMMENT '???????????????id????????????0??????????????????raid????????????????????????,raid??????',
    `drive`         varchar(200)         DEFAULT '' COMMENT '??????',
    `type`          char(10)    NOT NULL DEFAULT 'SAS' COMMENT ' ????????????',
    `size`          varchar(10) NOT NULL DEFAULT '' COMMENT '???????????????GB???',
    `raid`          varchar(20)          DEFAULT '' COMMENT 'raid??????',
    `virtual_disk`  varchar(100)         DEFAULT NULL COMMENT '????????????',
    `manufactor`    varchar(20)          DEFAULT '' COMMENT '?????????',
    `sync_time`     bigint(20)  NOT NULL DEFAULT '0' COMMENT '????????????',
    `sn`            varchar(50)          DEFAULT '' COMMENT '???????????????',
    `model`         varchar(50)          DEFAULT '' COMMENT '????????????',
    `status`        tinyint(4)           DEFAULT '0' COMMENT '????????????:0 ?????????1 ????????? 2 ??????',
    PRIMARY KEY (`id`),
    KEY `bare_metal_id` (`bare_metal_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `memory`
(
    `id`                varchar(50) NOT NULL,
    `bare_metal_id`     varchar(50) NOT NULL DEFAULT '' COMMENT '?????????id',
    `mem_cpu_num`       varchar(200)         DEFAULT '' COMMENT '?????????cpu???',
    `mem_mod_num`       varchar(200)         DEFAULT '' COMMENT '????????? ???CPU???????????????????????? mem_cpu_num:mem_mod_num',
    `mem_mod_size`      varchar(20) NOT NULL DEFAULT '' COMMENT '??????',
    `mem_mod_type`      varchar(200)         DEFAULT '' COMMENT '??????',
    `mem_mod_frequency` varchar(200)         DEFAULT '' COMMENT '??????',
    `mem_mod_part_num`  varchar(200)         DEFAULT '' COMMENT '??????',
    `mem_mod_min_volt`  varchar(200)         DEFAULT '' COMMENT '????????????',
    `sn`                varchar(50)          DEFAULT '' COMMENT '?????????',
    `sync_time`         bigint(20)  NOT NULL DEFAULT '0' COMMENT '????????????',
    `status`            tinyint(4)           DEFAULT '0' COMMENT '????????????:0 ?????????1 ????????? 2 ??????',
    PRIMARY KEY (`id`),
    KEY `bare_metal_id` (`bare_metal_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `cpu`
(
    `id`                     varchar(50)  NOT NULL,
    `bare_metal_id`          varchar(50)  NOT NULL DEFAULT '' COMMENT '?????????id',
    `proc_name`              varchar(200) NOT NULL DEFAULT '' COMMENT 'cpu??????',
    `proc_socket`            varchar(20)  NOT NULL DEFAULT '1' COMMENT '?????????',
    `proc_status`            varchar(20)           DEFAULT 'OP_STATUS_OK' COMMENT '??????',
    `proc_speed`             varchar(200)          DEFAULT '' COMMENT '??????',
    `proc_num_cores_enabled` varchar(200)          DEFAULT '' COMMENT '??????????????????',
    `proc_num_cores`         varchar(200)          DEFAULT '' COMMENT '?????????',
    `proc_num_threads`       varchar(200)          DEFAULT '' COMMENT '?????????',
    `proc_mem_technology`    varchar(20)  NOT NULL DEFAULT '64-bit Capable' COMMENT '???????????????',
    `proc_num_l1cache`       varchar(20)           DEFAULT '' COMMENT '1??????????????? kb',
    `proc_num_l2cache`       varchar(20)           DEFAULT '' COMMENT '2??????????????? kb',
    `proc_num_l3cache`       varchar(20)           DEFAULT '' COMMENT '3??????????????? kb',
    `sync_time`              bigint(20)   NOT NULL DEFAULT '0' COMMENT '????????????',
    `sn`                     varchar(50)           DEFAULT '' COMMENT '?????????',
    `status`                 tinyint(4)            DEFAULT '0' COMMENT '????????????:0 ?????????1 ????????? 2 ??????',
    PRIMARY KEY (`id`),
    KEY `bare_metal_id` (`bare_metal_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `network_card`
(
    `id`            varchar(255) NOT NULL COMMENT 'ID',
    `vlan_id`       varchar(255)          DEFAULT NULL COMMENT 'VlanId',
    `ip`            varchar(255)          DEFAULT NULL COMMENT 'IP??????',
    `number`        varchar(255)          DEFAULT NULL COMMENT '??????',
    `bare_metal_id` varchar(255)          DEFAULT NULL COMMENT '?????????ID',
    `mac`           varchar(255)          DEFAULT NULL COMMENT 'mac??????',
    `sync_time`     bigint(20)   NOT NULL DEFAULT '0' COMMENT '????????????',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `plugin`
(
    `id`       varchar(255) NOT NULL COMMENT 'ID',
    `name`     varchar(255) DEFAULT NULL COMMENT '??????',
    `platform` varchar(255) DEFAULT NULL COMMENT '???????????????',
    `icon`     varchar(255) DEFAULT NULL COMMENT 'icon',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `operation_log`
(
    `id`                 varchar(64)  NOT NULL,
    `workspace_id`       varchar(64)  NOT NULL DEFAULT '' COMMENT '????????????ID',
    `workspace_name`     varchar(100) NOT NULL DEFAULT '' COMMENT '??????????????????',
    `resource_user_id`   varchar(64)  NOT NULL DEFAULT '' COMMENT '???????????????ID',
    `resource_user_name` varchar(100) NOT NULL DEFAULT '' COMMENT '?????????????????????',
    `resource_type`      varchar(45)  NOT NULL DEFAULT '' COMMENT '????????????',
    `resource_id`        varchar(64)           DEFAULT NULL COMMENT '??????ID',
    `resource_name`      varchar(64)           DEFAULT NULL COMMENT '????????????',
    `operation`          varchar(45)  NOT NULL DEFAULT '' COMMENT '??????',
    `time`               bigint(13)   NOT NULL COMMENT '????????????',
    `message`            mediumtext COMMENT '????????????',
    `module`             varchar(20)           DEFAULT 'management-center' COMMENT '??????',
    `source_ip`          varchar(15)           DEFAULT NULL COMMENT '?????????IP',
    PRIMARY KEY (`id`),
    KEY `IDX_OWNER_ID` (`workspace_id`) USING BTREE,
    KEY `IDX_USER_ID` (`resource_user_id`) USING BTREE,
    KEY `IDX_OP` (`operation`) USING BTREE,
    KEY `IDX_RES_ID` (`resource_id`) USING BTREE,
    KEY `IDX_RES_NAME` (`resource_name`) USING BTREE,
    KEY `IDX_USER_NAME` (`resource_user_name`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

create table if not exists workflow_param_templates
(
    id              varchar(50)  not null,
    user_id         varchar(50) default null,
    bare_metal_id   varchar(50) default null,
    workflow_name   varchar(250) not null comment 'workflow name',
    params_template longtext     not null comment '????????????',
    extra_params    longtext    default null comment '??????????????????',
    primary key (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE if not exists `ip`
(
    `id`            varchar(50) NOT NULL,
    `ip`            varchar(36) NOT NULL DEFAULT '' COMMENT 'IP??????',
    `mask`          varchar(45)          DEFAULT NULL COMMENT '????????????',
    `gateway`       varchar(45)          DEFAULT NULL COMMENT '??????',
    `dns1`          varchar(45)          DEFAULT NULL COMMENT 'DNS1',
    `dns2`          varchar(45)          DEFAULT NULL COMMENT 'DNS2',
    `region`        varchar(45)          DEFAULT NULL COMMENT '??????',
    `network_id`    varchar(50) NOT NULL DEFAULT '' COMMENT '??????ID',
    `resource_type` varchar(45)          DEFAULT NULL COMMENT '????????????',
    `resource_id`   varchar(45)          DEFAULT NULL COMMENT '??????ID',
    `order_item_id` varchar(50)          DEFAULT NULL COMMENT '?????????ID',
    `status`        varchar(45) NOT NULL DEFAULT 'available' COMMENT '??????',
    PRIMARY KEY (`id`),
    UNIQUE KEY `UNQ_PID_IP` (`ip`, `network_id`) USING BTREE,
    KEY `IDX_PID` (`network_id`) USING BTREE,
    KEY `IDX_IP` (`ip`) USING BTREE,
    KEY `IDX_RID` (`resource_id`) USING BTREE,
    KEY `IDX_RTYPE` (`resource_type`) USING BTREE,
    KEY `IDX_STATUE` (`status`) USING BTREE,
    KEY `IDX_OID` (`order_item_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='?????????ip';

CREATE TABLE if not exists `execution_log`
(
    `id`          varchar(50) CHARACTER SET utf8mb4 NOT NULL,
    `user`        varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '?????????',
    `status`      varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????',
    `create_time` bigint(13)                        NOT NULL COMMENT '????????????',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT ='????????????';

CREATE TABLE if not exists `execution_log_details`
(
    `id`            varchar(50) CHARACTER SET utf8mb4 NOT NULL,
    `user`          varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '?????????',
    `operation`     varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????',
    `log_id`        varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????id',
    `bare_metal_id` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '?????????id',
    `out_put`       mediumtext CHARACTER SET utf8mb4 COMMENT '??????',
    `status`        varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????',
    `create_time`   bigint(13)                        NOT NULL COMMENT '????????????',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT ='??????????????????';

CREATE TABLE if not exists `workflow`
(
    `id`              varchar(50) CHARACTER SET utf8mb4 NOT NULL,
    `type`            varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT 'user' COMMENT '?????????system???user',
    `injectable_name` varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT 'workflow????????????',
    `friendly_name`   varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT 'workflow????????????',
    `event_type`      varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????workflow????????????',
    `brands`          varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '?????????????????????????????????',
    `settable`        varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????????????????payload??????',
    `default_params`  mediumtext comment '????????????????????????settable?????????',
    `status`          varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????, 1 ?????????2 ??????',
    `create_time`     bigint(13)                        NOT NULL COMMENT '????????????',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT ='???RackHD???workflow?????????';

CREATE TABLE if not exists `endpoint`
(
    `id`          varchar(50) CHARACTER SET utf8mb4 NOT NULL,
    `name`        varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????',
    `type`        varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????main_endpoint,slave_endpoint',
    `ip`          varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT 'ip??????',
    `status`      varchar(50) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '??????, 1 ?????????2 ??????',
    `create_time` bigint(13)                        NOT NULL COMMENT '????????????',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin COMMENT ='rackshift??????';