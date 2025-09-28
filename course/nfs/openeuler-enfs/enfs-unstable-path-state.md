# 需求

```
场景一:
1、DPC（nfs client）到存储(nfs server)某条RDMA(sunrpc）（或tcp）链路发生多次闪断（在30分钟内出现3次连接断开则设置当前物理连接为亚健康状态）
2、达到亚健康判断标准后DPC将该条链路设置为亚健康状态
3、新的主机io优先选择非亚健康状态路径下发，观察该主机上承载的业务，不出现读写io失败，文件系统读写io归零（下降超过90%）时长<=60秒
4、亚健康状态消除后（在物理或逻辑链路进入亚健康状态后，在判断链路亚健康恢复时按30分钟进行退避恢复，退避恢复时检测出现一次连接断开事件则在断开事件后重新将亚健康状态时间改成30分钟，如果30分钟末出现连接断开则消除亚健康状态）恢复该条链路下发io

场景二:
1、DPC 到存储其条RDMA(sunrpe）链路时延超过固定阈值（针对每条逻辑连接按30s一个小周期统计谈写I0 平均时延（未返回或者返回busy的也需要统计），在10分钟统计如果出现3次及3次以上 平均时延超过1s，则设置当前物理连接为亚健康状态，平均时延门限1s值为默认值，10分钟检测周期默认值为10分钟，DME可批量进行下发配置进行自定义并保存到dpc 节点上
2、达到亚健康判断标准后DPC将该条链路设置为亚健康状态
3、新的主机IO优先选择非亚健康状态路径下发，观察该主机上承载的业务，不出现读写IO失败，文件系统读写IO归零（下降超过90%）时长<=60秒
4、因亚健康隔离后，本链路不再下发读写io，无法感知是否还有大时延，因此在60分钟后只要本链路能探测通，则无条件恢复该条链路下发I0．该场景机制参考ultrapath，无退避机制
```

# 代码分析

```c
struct rpc_xprt
  connect_cookie

pm_set_path_state

struct enfs_xprt_context

enfs_alloc_xprt_ctx
  ctx = kzalloc // 初始化为0

pm_ping_routine // kthread_run(pm_ping_routine,
  enfs_get_config_path_detect_interval // 获取间隔时长
  pm_ping_loop_sunrpc_net
    pm_ping_loop_rpclnt
      rpc_clnt_iterate_for_each_xprt
        pm_ping_execute_xprt_test // fn
```

