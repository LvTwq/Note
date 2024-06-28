[TOC]


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