[toc]

# Kubernetes 是什么

![](..\images\container_evolution.svg)

* 传统部署时代
  在物理服务器上运行程序。无法限制物理服务器中运行的应用程序资源使用，会导致资源分配问题。
* 虚拟化部署时代
  虚拟化技术允许在单个物理服务器上运行多台虚拟机（VM）。虚拟化能够使用应用程序在不同的 VM 之间隔离，且能提供一定程度的安全性，因为一个应用程序的信息不能被另一程序随意访问。

  每个 VM 是一台完整的计算机，在虚拟化硬件之上运行所有组件，包括自己的操作系统
* 容器部署时代
  容器类似于 VM，但容器之间可以共享操作系统，因此更轻量。每个容器具有自己的文件系统、CPU、内存、进程空间

# 架构

![](..\images\k8s架构图1.png)
一个K8S系统，通常称为一个K8S集群（Cluster）

这个集群主要包括两个部分：

* 一个Master节点（主节点）：负责管理和控制
* 一群Node节点（计算节点）：工作负载节点，里面是具体的内容

## Master 节点

![](..\images\k8s架构图2.jpg)
API Server是整个系统的对外接口，供客户端和其它组件调用，相当于“营业厅”
Scheduler负责对集群内部的资源进行调度，相当于“调度室”
Controller manager负责管理控制器，相当于“大总管”

## Node 节点

![](..\images\k8s架构图.jpg)

Pod是Kubernetes最基本的操作单元。一个Pod代表着集群中运行的一个进程，它内部封装了一个或多个紧密相关的容器。
除了Pod之外，K8S还有一个Service的概念，一个Service可以看作一组提供相同服务的Pod的对外访问接口。
Docker，创建容器的
Kubelet，主要负责监视指派到它所在Node上的Pod，包括创建、修改、监控、删除等
Kube-proxy，主要负责为Pod对象提供代理
Fluentd，主要负责日志收集、存储与查询

# 搭建

通过rancher部署k8s集群
https://blog.csdn.net/monarch91/article/details/122763156

# yaml 语法

```yaml
#-----------user center deployment--------#
apiVersion: apps/v1
kind: Deployment
metadata:
  name: 
  labels:
    app: 
spec:
  replicas: 1
  selector:
    matchLabels:
      app: 
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  minReadySeconds: 30
  template:
    metadata:
      labels:
        app: 
    spec:
        # 指定运行node为主节点
      nodeName: ecs-9e43
      hostAliases:
        - ip: 
          hostnames:
            - 
      imagePullSecrets: #指定访问仓库使用的密码
        - name: registry-secret-name
      containers:
        - name: 
          image: 
          # 提权
          securityContext:
            privileged: true        
          volumeMounts:
            - mountPath: 
              name: 
          imagePullPolicy: Always
          ports:
          # pod 内部容器的端口，targetPort 映射到 containerPort
            - containerPort: 8400
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: 'prod'
            - name: JAVA_OPTS
      volumes:
        - name: 
          hostPath:
            path: 
            type: DirectoryOrCreate
---
#---user center 对外暴露的service------#
apiVersion: v1
kind: Service
metadata:
  name: 
spec:
  selector:
    app: 
    # 暴露服务的方式：NodePort、LoadBalane、Ingress
  type: NodePort
  ports:
  # k8s 集群内部访问service端口，通过 clusterip:port 请求某个service
    - port: 8400
    # pod 的端口，从 port 和 nodePort来的流量经过 kube-proxy 流入到后端pod的targetPort 上，最后进入容器
      targetPort: 8400
      protocol: TCP
      # 宿主机暴露给外部，外部通过 nodeip:nodePort 请求某个service
      nodePort: 30084
```

# kubectl 命令

![](..\images\kubectl命令大全.jpeg)

```shell
# 根据配置文件里面列出来的内容，升级现有的，所以yaml文件的内容可以只写需要升级的属性
kubectl apply -f **.yaml

# 先删除现有的，重新根据yaml文件生成新的，所以要求yaml文件中的配置必须是完整的
kubectl create -f **.yaml

# 删除资源，但是yaml文件不会被删除
kubectl delete -f **.yaml


# 查看所有资源
kubectl get all
# 查看pod列表
kubectl get pod

# 查看node节点列表
kubectl get node

# 查看日志
kubectl logs -f podName


# 查看pod详细信息（运行在哪个节点上）
kubectl get pod -o wide

# 查看服务详细信息，服务名称，类型，集群ip，端口，时间等信息
kubectl get  svc

# 进入pod
kubectl exec -it server-download-6765ff6bc7-qq67v -- sh -n sase

# 把pod内文件拷贝出来
kubectl cp sase/server-download-6765ff6bc7-qq67v:/home/spring/fileCenter/fileCenter.db /root/lmc/fileCenter.db

# 查看日志
kubectl logs -f --tail=222 server-download-6765ff6bc7-76cvt -n sase

# 重启
kubectl delete server-download-6765ff6bc7-qq67v -n sase
```

# 集群里的三种IP

Kubernetes集群里有三种IP地址

## Node IP

Node IP 是物理机/虚拟机的IP
每个 Service 都会在 Node 节点上开通一个端口，外部可以通过 NodeIP:NodePort 访问 Service 里的 Pod，和我们访问服务器部署的项目一样
在kubernetes查询Node IP

```shell
kubectl get nodes
kubectl describe node nodeName
```

![](..\images\k8s-nodeip.png)

## Pod IP

Pod IP 每个Pod的IP地址
它是 Docker Engine 根据 docker 网桥的 IP 地址段进行分配的，通常是一个**虚拟**的二层网络

* 同 Service 下的 pod 可以直接 PodIP相互通信
* 不同 Service 下的 pod 在集群间通信要借助 cluster ip
* pod 和集群外通信，要借助 node ip

在kubernetes查询Pod IP

```shell
kubectl get pods
kubectl describe pod podName
```

![](..\images\k8s-podip.png)

## Cluster IP

Service 的 IP地址，是**虚拟IP地址**，外部网络无法ping通，只有集群内部访问使用

```shell
kubectl get  svc
```

![](..\images\k8s-clusterip.png)

* Cluster IP 只作用于 kubernetes service 这个对象，并由 kubernetes 管理分配
* Cluster IP 无法被ping，他没有一个“实体网络对象”来响应
* Cluster IP 只能结合 Service Port 组成一个具体的通信端口，单独的 Cluster IP 不具备通信基础，并且他们属于 kubernetes 集群这样一个封闭的空间
* 在不同 Service 下的 pod 节点，在集群间相互访问可以通过 CLuster IP

## 三种 IP 网络间的通信

外部访问时，Node ➡ service ➡ pod

![](..\images\k8s网络通信.png)



# 命令

以下是 Kubernetes (`k8s`) 的常用命令分类整理，涵盖集群管理、资源操作、调试及实用技巧：

---

### **1. 集群与节点管理**

| 命令                                  | 作用                             |
| ------------------------------------- | -------------------------------- |
| `kubectl cluster-info`              | 查看集群信息（API Server 地址）  |
| `kubectl get nodes`                 | 列出所有节点及其状态             |
| `kubectl describe node <node-name>` | 查看节点的详细状态（资源、事件） |
| `kubectl top node`                  | 查看节点的资源使用（CPU/内存）   |

---

### **2. Pod 操作**

| 命令                                            | 作用                                  |
| ----------------------------------------------- | ------------------------------------- |
| `kubectl get pods`                            | 列出默认命名空间的 Pod                |
| `kubectl get pods -n <namespace>`             | 查看指定命名空间的 Pod                |
| `kubectl get pods -A` 或 `--all-namespaces` | 查看所有命名空间的 Pod                |
| `kubectl describe pod <pod-name>`             | 查看 Pod 的详细状态和事件             |
| `kubectl logs <pod-name>`                     | 查看 Pod 的日志                       |
| `kubectl logs -f <pod-name>`                  | 实时跟踪 Pod 日志（类似 `tail -f`） |
| `kubectl logs <pod-name> -c <container-name>` | 查看多容器 Pod 中指定容器的日志       |
| `kubectl exec -it <pod-name> -- /bin/sh`      | 进入 Pod 的容器执行命令（交互式）     |
| `kubectl delete pod <pod-name>`               | 删除指定 Pod                          |

---

### **3. Deployment/Service 管理**

| 命令                                                                     | 作用                         |
| ------------------------------------------------------------------------ | ---------------------------- |
| `kubectl get deployments`                                              | 查看 Deployment 列表         |
| `kubectl scale deployment <deploy-name> --replicas=3`                  | 扩缩容 Deployment 副本数     |
| `kubectl rollout status deployment/<deploy-name>`                      | 查看 Deployment 的发布状态   |
| `kubectl rollout history deployment/<deploy-name>`                     | 查看 Deployment 的发布历史   |
| `kubectl rollout undo deployment/<deploy-name>`                        | 回滚到上一个版本             |
| `kubectl expose deployment <deploy-name> --port=80 --target-port=8080` | 创建 Service 暴露 Deployment |
| `kubectl get services`                                                 | 查看 Service 列表            |

---

### **4. 配置与部署**

| 命令                                                            | 作用                                 |
| --------------------------------------------------------------- | ------------------------------------ |
| `kubectl apply -f <file.yaml>`                                | 应用 YAML 配置文件（创建/更新资源）  |
| `kubectl delete -f <file.yaml>`                               | 删除 YAML 文件中定义的资源           |
| `kubectl edit deployment/<deploy-name>`                       | 直接编辑 Deployment 配置（临时调试） |
| `kubectl set image deployment/<deploy-name> nginx=nginx:1.20` | 更新 Deployment 的容器镜像           |

---

### **5. 命名空间（Namespace）**

| 命令                                                             | 作用                   |
| ---------------------------------------------------------------- | ---------------------- |
| `kubectl get ns`                                               | 查看所有命名空间       |
| `kubectl create ns <namespace>`                                | 创建命名空间           |
| `kubectl config set-context --current --namespace=<namespace>` | 切换当前操作的命名空间 |

---

### **6. 存储管理（PV/PVC）**

| 命令                                | 作用                                    |
| ----------------------------------- | --------------------------------------- |
| `kubectl get pv`                  | 查看持久卷（PersistentVolume）          |
| `kubectl get pvc`                 | 查看持久卷声明（PersistentVolumeClaim） |
| `kubectl describe pvc <pvc-name>` | 查看 PVC 的详细状态                     |

---

### **7. 网络与端口转发**

| 命令                                                    | 作用                                    |
| ------------------------------------------------------- | --------------------------------------- |
| `kubectl port-forward <pod-name> 8080:80`             | 将本地的 8080 端口转发到 Pod 的 80 端口 |
| `kubectl port-forward service/<service-name> 8080:80` | 将本地端口转发到 Service                |
| `kubectl get ingress`                                 | 查看 Ingress 规则                       |

---

### **8. 标签与选择器**

| 命令                                      | 作用                 |
| ----------------------------------------- | -------------------- |
| `kubectl get pods -l app=nginx`         | 根据标签筛选 Pod     |
| `kubectl label pod <pod-name> env=prod` | 为 Pod 添加/更新标签 |

---

### **9. 其他实用命令**

| 命令                                                           | 作用                                                  |
| -------------------------------------------------------------- | ----------------------------------------------------- |
| `kubectl api-resources`                                      | 查看所有支持的资源类型                                |
| `kubectl get events --sort-by='.metadata.creationTimestamp'` | 按时间排序查看集群事件                                |
| `kubectl explain <resource>`                                 | 查看资源的字段定义（如 `kubectl explain pod.spec`） |

---

### **10. 快速备忘**

#### **一键删除命名空间内所有资源**（谨慎使用）：

```bash
kubectl delete all --all -n <namespace>
```

#### **查看 Pod 的完整 YAML 定义**：

```bash
kubectl get pod <pod-name> -o yaml
```

#### **生成 Deployment 的模板**（避免手写 YAML）：

```bash
kubectl create deployment my-nginx --image=nginx --dry-run=client -o yaml > nginx-deploy.yaml
```

---

### **实用技巧**

1. **别名简化命令**：
   ```bash
   alias k=kubectl
   alias kgp="k get pods"
   ```
2. **自动补全**：
   在 `~/.bashrc` 或 `~/.zshrc` 中添加：
   ```bash
   source <(kubectl completion bash)
   complete -F __start_kubectl k
   ```

---

掌握这些命令后，可以覆盖 Kubernetes 80% 的日常操作场景。复杂场景建议结合 YAML 配置文件使用！
