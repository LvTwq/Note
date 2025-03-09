# 核心概念

* **时间序列数据** ：由指标名称（Metric Name）和标签（Labels）组成的多维数据。
* **数据模型** ：每个时间序列由 `metric_name{label1="value1",...}` 唯一标识。
* **四大组件** ：

  * Prometheus Server：抓取、存储、查询数据。
  * Exporters：暴露目标服务指标（如 Node Exporter、MySQL Exporter）。
  * Alertmanager：处理告警通知。
  * Pushgateway：临时任务的指标推送网关
* **指标类型** ：

  * **Counter** ：单调递增计数器（如请求总数）
  * **Gauge** ：瞬时波动值（如内存使用量）
* **实例（Instance）和任务（Job）**

  * **Job** ：同一类监控目标的逻辑分组（如 `api-server`）
  * **Instance** ：Job 中的具体监控端点（如 `10.0.0.1:8080`, `10.0.0.2:8080`）
* 与其它监控系统（如 Zabbix/Graphite）相比，核心优势？

  * 多维数据模型（Labels 机制）支持灵活查询
  * Pull 模型（主动拉取）适用于动态云环境

# 部署

```yml
# prometheus.yml
global:
  scrape_interval:     3s
  evaluation_interval: 15s
scrape_configs:
  - job_name: 'mysql_exporter'
    metrics_path: /metrics
    scrape_interval: 60s
    file_sd_configs:
      - files:
          - /etc/prometheus/static_conf/mysql.yml

  - job_name: 'lvmc_exporter'
    metrics_path: /actuator/prometheus
    scrape_interval: 10s
    file_sd_configs:
      - files:
          - /etc/prometheus/static_conf/lvmc.yml
rule_files:
  - "/etc/prometheus/rules/*.yml"


# *.yml
- targets: ['ip:port']
  labels:
    uuid:   'ip'
    target:   'ip'


# 告警
groups:
  - name: node_alert
    rules:
      - alert: disk_alert
        expr: (node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_free_bytes{mountpoint="/"}) / node_filesystem_size_bytes{mountpoint="/"} * 100 > 40
        #for: 5m
        labels:
          level: warning
        annotations:
          description: "instance: {{ $labels.instance }} ,cpu usage is too high ! value: {{$value}}"
          summary: "disk usage is too high"
```

控制台：

> http://ip:9101/
>
> http://ip:9100/metrics

# 架构和组件

1. **Retrieval** ：定时从 Targets（被监控端）拉取指标
2. **Storage** ：数据持久化到本地 TSDB（时间序列数据库）
3. **HTTP Server** ：提供 Web UI 和查询 API（PromQL）
4. **Alert Rules Evaluation** ：周期性检查触发告警规则


# 自定义 Exporter

1. 定义需要暴露的指标（类型和标签）
2. 使用 Prometheus Client Library 注册指标（Java/Python/Go 等）
3. 周期性或事件驱动式更新指标值（如监听日志文件）
4. 启动 HTTP Server 暴露 `/metrics` 端点
