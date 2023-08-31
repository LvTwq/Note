[TOC]


# 命令行
1、查看当前正在运行的进程

tasklist | findstr

2、强制杀死映像名称为imagename的进程，映像名称可通过任务管理器或tasklist命令查看

taskkill /im imagename -f

3、强制杀死PID为processid的进程，PID可通过tasklist查看

taskkill /pid processid -f

4、刷新DNS
ipconfig /flushdns
