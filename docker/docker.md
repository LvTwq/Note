[TOC]

# 简单介绍

## 镜像（Image）
* Docker 镜像是一种特殊的文件系统，除了提供容器运行时所需的程序、库、资源、配置等文件外，还包含一些为运行时准备的一些配置参数（如匿名卷、环境变量、用户等）
* 利用 Union FS 的技术，将其设计为分层存储的架构。 镜像实际是由多层文件系统联合组成。前一层是后一层的基础。每一层构建完就不会再发生改变，后一层上的任何改变只发生在自己这一层，docker支持的有OverlayFS,AUFS, Btrfs, CFS,ZFS 和 Device Mapper等

## 容器（Container）
![](..\images\镜像-容器.png)
* 镜像和容器的关系，就像是面向对象程序设计中的类和实例一样，镜像是**静态的定义**，容器是**镜像运行时的实体**。容器可以被创建、启动、停止、删除、暂停等
* 容器的实质是**进程**，但与直接在**宿主机**执行的进程不同，容器进程运行于属于自己的**独立的命名空间**
* 容器存储层的生命周期和容器一样，**容器消亡时，容器存储层也随之消亡**，因此，任何保存于容器存储层的信息都会随容器删除而丢失

## 仓库（Repository）
* 集中存储、分发镜像的服务
* 一个 Docker Registry 中可以包含多个仓库，每个仓库可以包含多个标签，每个标签对应一个镜像
* 通过<仓库名>:<标签>的格式来指定具体是这个软件哪个版本的镜像。如果不给出标签，将以 latest 作为默认标签

需要注意的是，在仓库服务器上执行 docker images 命令，查看的是它本地的镜像，而不是仓库里的镜像

## 为什么要使用 Docker
* 简化配置
  容器镜像打包完成后，它就是个独立的个体了，丢到哪里都能跑，而无需针对各个平台去独立配置
* 提高开发效率
  可以快速搭建开发环境、让开发环境贴近生产线
* 隔离应用
  在一台服务器上运行多个不同的应用

# 安装 docker
Docker CE 即社区免费版，Docker EE 即企业版，强调安全，但需付费使用
## 安装前置条件
* 64位CPU架构的计算机
* Linux3.8以上内核
* 内核至少支持其中一种存储驱动：Device Manager（默认）; AUFS; vfs; btrfs
* 内核必须支持并开启cgroup和namespace功能

查看 Linux 内核命令
```shell
uname -r
```


## 安装过程
```shell
yum install -y yum-utils
# 添加yum源,这里添加的是阿里云的yum源
yum-config-manager  --add-repo  http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 查看docker版本
yum list docker-ce --showduplicates | sort -r
# 您可以选择其他版本
yum  -y install docker-ce-20.10.12-3.el7
# 设置国内镜像加速，你也可以用自己的仓库镜像，这里是我申请的阿里云个人加速镜像
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://fuchp8pk.mirror.aliyuncs.com"]
}
EOF
# 导入镜像设置
systemctl daemon-reload
# 启动docker
systemctl restart docker
# 设置docker开机启动
systemctl enable docker
# 查看docker信息
docker info
```


# docker 使用


## 制作镜像
编写dockerfile

```shell
# 引用需要的基础镜像
FROM lwieske/java-8:latest

ARG TZ=Asia/Shanghai

ARG JAR_FILE=./*.jar
ENV JAVA_OPTIONS=-Xmx512m
COPY ${JAR_FILE} huaweiyun-1.0.0.jar

# 运行容器时执行
CMD java ${JAVA_OPTIONS} -jar huaweiyun-1.0.0.jar
```

## 构建镜像
在 Dockerfile 文件存放的目录下，执行构建
```shell
# 最后一个 . 表示当前路径，会将当前路径下的文件发给docker引擎
docker build -t 镜像名称:镜像标签 .

# 创建容器并运行dockerfile中的cmd命令，-v 绑定一个卷
docker run -v /home/enlink/:/home/enlink/ -p 宿主机端口:容器端口 -d 镜像名称:镜像标签

# 启动已经被停止的容器
docker start CONTAINER 

# 停止一个运行中的容器
docker stop CONTAINER

# 重启容器
docker restart CONTAINER


# 杀掉容器
docker kill -s KILL 7a6f979bc630
```


## 其他镜像命令

```shell

# 查看符合条件的镜像
docker images 镜像名称

# 删除镜像
docker rmi -f 镜像名称:标签

# 将指定镜像保存成tar归档文件
docker save -o huaweiyun.tar huaweiyun:1.0

# 导入使用 save 命令 导出的镜像
docker load --input *.tar

# 从归档文件中创建镜像，可以指定新名字
docker import *.tar 名称:tag

# 替换镜像中的jar包，然后需要重启
docker cp ensbrain-plus-server-admin-2.1.0.jar server-admin:/app.jar

# 登录到docker镜像仓库


```

## docker compose
```shell
#创建并启动
docker-compose –f docker-compose.yml up –d
#启动
docker-compose –f docker-compose.yml start
#停止
docker-compose –f docker-compose.yml stop
#删除
docker-compose –f docker-compose.yml down
docker-compose –f docker-compose.yml down --volumes
#重启
docker-compose –f docker-compose.yml restart
#指定重启某一个或多个
docker-compose –f docker-compose.yml restart mynginx

```


## [其他命令](https://www.runoob.com/docker/docker-command-manual.html)

```shell

# 查看日志，-f 跟踪日志输出
docker logs -f CONTAINER

# 标记本地镜像，将其归入仓库
docker tag docker.s.enlink.top/enucp/connector-admin-starter:1.0.0.001-SNAPSHOT 192.168.0.127:5000/enucp/connector-admin-starter:1.0.0.001-SNAPSHOT

# 推镜像，不指定仓库，默认推给官方仓库
docker push 192.168.0.127:5000/enucp/connector-admin-starter:1.0.0.001-SNAPSHOT 


# 进入容器内部执行命令
docker exec -it mariadb bash

# 获取容器/镜像的元数据
docker inspect NAME|ID NAME|ID


```

## 数据管理
### 挂载主机目录
```shell
docker run -d -P \
    --name web \
    # -v /src/webapp:/usr/share/nginx/html \
    --mount type=bind,source=/src/webapp,target=/usr/share/nginx/html \
    nginx:alpine
```
上面的命令加载主机的 /src/webapp 目录到容器的 /usr/share/nginx/html目录，使用 `inspect` 命令 查出容器信息，挂载主机目录的配置信息在`“mounts”`下：
```json
"Mounts": [
    {
        "Type": "bind",
        "Source": "/src/webapp",
        "Destination": "/usr/share/nginx/html",
        "Mode": "",
        "RW": true,
        "Propagation": "rprivate"
    }
]
```