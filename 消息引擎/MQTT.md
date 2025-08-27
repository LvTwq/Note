# 官网

[首页 | MQTT中文网](https://mqtt.p2hp.com/)

[仪表盘](http://192.168.112.160:18083/)

# 消息匹配规则

## **1. 单层通配符：`+`**

* **规则** ：匹配  **单一且必须存在的层级** （不能为空）。
* **特点** ：
* 占位符只能代替一层主题（对应一个 `/` 分隔的部分）。
* 同一层级中可以有多个 `+`。
* **示例说明** ：

| **订阅主题**          | **匹配的主题**                                 | **不匹配的主题**     |
| --------------------------- | ---------------------------------------------------- | -------------------------- |
| `sensors/+/temp`          | `sensors/room1/temp`<br />`sensors/kitchen/temp` | `sensors/temp`           |
| `devices/+/status/+/info` | `devices/d1/status/ok/info`                        | `devices/status/ok/info` |

---

## **2. 多层通配符：`#`**

* **规则** ：匹配  **所有后续层级的任意主题** （包括零或多个层级）。
* **特点** ：
* 必须置于主题末尾或单独使用（例如 `sensors/#` 有效，`sensors/#/temp`  *无效* ）。
* 可以匹配空层级（如 `sensors/#` 可匹配主题 `sensors`）。
* **示例说明** ：

| **订阅主题** | **匹配的主题**       | **不匹配的主题**                    |
| ------------------ | -------------------------- | ----------------------------------------- |
| `sensors/#`      | `sensors`                | 无（所有以 `sensors` 开头的主题均匹配） |
| `#`              | 所有主题（相当于全局监听） | 无                                        |

---

## **3. 使用规则和注意事项**

1. **禁止在发布消息时使用通配符** ：

* 通配符只能用于订阅（`subscribe`），不能用于发布（`publish`）。
* 若向含有 `+` 或 `#` 的主题发布消息，代理（Broker）会直接拒绝。

1. **层级分隔符为 `/`** ：

* 主题按 `/` 拆分成多个层级，例如 `home/floor1/light`。
* 空的层级（如 `//`）可能合法（取决于 Broker 实现），但应避免这种设计。

1. **优先级冲突** ：

* 若订阅了多个重叠的主题，实际收到的消息会触发所有匹配的处理器。
  （例如：订阅 `sensors/#` 和 `sensors/+/temp`，两个处理器都会被触发）

## 共享订阅

以 **$share/** 开头的主题表示这是一个共享订阅（Shared Subscription）。共享订阅允许多个客户端订阅同一个主题时，将消息负载分摊到组内的各个客户端，而不是每个客户端都收到所有消息。

共享订阅的格式通常为：

> $share/{GroupName}/{ActualTopic}

* **`$share`** ：固定前缀，声明这是一个共享订阅（ **必须保留** ，不可更名）。
* **`{GroupName}`** ：订阅组名称（例如你的 `zz`），代表消费者分组，同一分组的客户端的订阅会自动负载均衡。
* **`{ActualTopic}`** ：实际的消息 Topic（例如你的 `temp`），支持通配符。

# 核心机制

## Qos 等级

| **QoS** | 消息可靠性                | 重传机制              | 典型场景               |
| ------------- | ------------------------- | --------------------- | ---------------------- |
| 0             | 最多一次（At Most Once）  | 无                    | 实时日志（容忍丢失）   |
| 1             | 至少一次（At Least Once） | PUBACK 确认           | 设备状态更新（需可靠） |
| 2             | 恰好一次（Exactly Once）  | PUBREC/PUBREL/PUBCOMP | 支付指令（严格幂等）   |

* QoS 1：消息存储到本地队列，直到收到 PUBACK 确认。
* QoS 2：通过四次握手确保消息不重复（PUBREC → PUBREL → PUBCOMP）

## 遗嘱消息

* **作用** ：客户端异常断开时，Broker 自动发布预设消息。
* **配置参数** ：
* `Will Topic`、`Will Payload`、`Will QoS`、`Will Retain`。
* **典型场景** ：设备离线时触发告警或状态更新。

## Retained Message（保留消息）

* **机制** ：Broker 为 Topic 保存最新一条消息，新订阅者立即收到。
* **用途** ：设备首次上线时获取最新状态（如传感器最新读数）。

## 系统消息

`$SYS` 主题用于 **系统消息** ，它提供关于 **MQTT 代理（Broker）状态**的监控信息，例如客户端连接数、消息统计、主题订阅情况等。

* `$SYS` 是一个 **保留主题（Reserved Topic）** ，只能由 MQTT 代理发布， **客户端不能向 `$SYS` 主题发布消息** 。
* 订阅 `$SYS/#` 可以获取代理的所有系统信息

例如：

```
$SYS/brokers/emqx@emqx.lvmc.top/clients/#
```

* **`$SYS/brokers/`** → 表示这个主题属于代理的系统状态信息。
* **`emqx@emqx.lvmc.top/`** → 代表  **MQTT 代理实例 ID** ，通常是 `节点名称@主机名`，用于标识不同的 EMQX 代理节点。
* **`clients/`** → 关注 **客户端相关信息** 。
* **`#`** （通配符） → 订阅 `clients/` 下的所有子主题，意味着获取所有客户端的信息

如果你订阅 `$SYS/brokers/emqx@emqx.lvmc.top/clients/#`，你可能会收到以下子主题的数据：

| 主题                                                                  | 说明                                 |
| --------------------------------------------------------------------- | ------------------------------------ |
| `$SYS/brokers/emqx@emqx.lvmc.top/clients/connected`                 | 当前已连接的客户端数量               |
| `$SYS/brokers/emqx@emqx.lvmc.top/clients/disconnected`              | 断开连接的客户端数量                 |
| `$SYS/brokers/emqx@emqx.lvmc.top/clients/clientid123`               | 特定客户端 `clientid123`的状态信息 |
| `$SYS/brokers/emqx@emqx.lvmc.top/clients/clientid123/connected`     | `clientid123`是否在线              |
| `$SYS/brokers/emqx@emqx.lvmc.top/clients/clientid123/subscriptions` | `clientid123`订阅的主题列表        |

# 问题排查思路

* 看集群概览中，一共有哪些节点
* 直接用MQTTX连现场环境，监听 `$SYS/brokers/emqx@emqx.lvmc.top/clients/connected`，需要确认现场到底是单机还是集群
* 下发消息时，要看到底是发给哪个域名/IP
* 数一下总的在线设备
* 看有问题的那几台设备，订阅了哪些topic
