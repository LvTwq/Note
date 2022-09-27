[TOC]


# AMQP 协议
AMQP协议和前面我们介绍的JMS协议有所不同。在JMS中，有两种类型的消息通道：

* 点对点的Queue，即Producer发送消息到指定的Queue，接收方从Queue收取消息；
* 一对多的Topic，即Producer发送消息到指定的Topic，任意多个在线的接收方均可从Topic获得一份完整的消息副本。

但是AMQP协议比JMS要复杂一点，它只有Queue，没有Topic，并且引入了Exchange的概念。
当Producer想要发送消息的时候，它将消息发送给Exchange，由Exchange将消息根据各种规则投递到一个或多个Queue：

                                      ┌───────┐
                                 ┌───>│Queue-1│
                  ┌──────────┐   │    └───────┘
              ┌──>│Exchange-1│───┤
┌──────────┐  │   └──────────┘   │    ┌───────┐
│Producer-1│──┤                  ├───>│Queue-2│
└──────────┘  │   ┌──────────┐   │    └───────┘
              └──>│Exchange-2│───┤
                  └──────────┘   │    ┌───────┐
                                 └───>│Queue-3│
                                      └───────┘


JMS的Topic相比，Exchange的投递规则更灵活，比如一个“登录成功”的消息被投递到Queue-1和Queue-2，而“登录失败”的消息则被投递到Queue-3。这些路由规则称之为Binding，通常都在RabbitMQ的管理后台设置