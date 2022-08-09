[TOC]


# 源码

## 启动
```java
public ConfigurableApplicationContext run(String... args) {
   StopWatch stopWatch = new StopWatch();
   //设置线程启动计时器
   stopWatch.start();
   ConfigurableApplicationContext context = null;
   Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
   //配置系统属性：默认缺失外部显示屏等允许启动
   configureHeadlessProperty();
   //获取并启动事件监听器，如果项目中没有其他监听器，则默认只有EventPublishingRunListener
   SpringApplicationRunListeners listeners = getRunListeners(args);
   //将事件广播给listeners
   listeners.starting();
   try {
       //对于实现ApplicationRunner接口，用户设置ApplicationArguments参数进行封装
      ApplicationArguments applicationArguments = new DefaultApplicationArguments(
            args);
      //配置运行环境：例如激活应用***.yml配置文件      
      ConfigurableEnvironment environment = prepareEnvironment(listeners,
            applicationArguments);
      configureIgnoreBeanInfo(environment);
      //加载配置的banner(gif,txt...)，即控制台图样
      Banner printedBanner = printBanner(environment);
      //创建上下文对象，并实例化
      context = createApplicationContext();
      exceptionReporters = getSpringFactoriesInstances(
            SpringBootExceptionReporter.class,
            new Class[] { ConfigurableApplicationContext.class }, context);
      //配置SPring容器      
      prepareContext(context, environment, listeners, applicationArguments,
            printedBanner);
      //刷新Spring上下文，创建bean过程中      
      refreshContext(context);
      //空方法，子类实现
      afterRefresh(context, applicationArguments);
      //停止计时器：计算线程启动共用时间
      stopWatch.stop();
      if (this.logStartupInfo) {
         new StartupInfoLogger(this.mainApplicationClass)
               .logStarted(getApplicationLog(), stopWatch);
      }
      //停止事件监听器
      listeners.started(context);
      //开始加载资源
      callRunners(context, applicationArguments);
   }
   catch (Throwable ex) {
      handleRunFailure(context, listeners, exceptionReporters, ex);
      throw new IllegalStateException(ex);
   }
   listeners.running(context);
   return context;
}
```


## callRunners 方法
```java
private void callRunners(ApplicationContext context, ApplicationArguments args) {
    //将实现ApplicationRunner和CommandLineRunner接口的类，存储到集合中
   List<Object> runners = new ArrayList<>();
   runners.addAll(context.getBeansOfType(ApplicationRunner.class).values());
   runners.addAll(context.getBeansOfType(CommandLineRunner.class).values());
   //按照加载先后顺序排序
   AnnotationAwareOrderComparator.sort(runners);
   for (Object runner : new LinkedHashSet<>(runners)) {
      if (runner instanceof ApplicationRunner) {
         callRunner((ApplicationRunner) runner, args);
      }
      if (runner instanceof CommandLineRunner) {
         callRunner((CommandLineRunner) runner, args);
      }
   }
}

private void callRunner(CommandLineRunner runner, ApplicationArguments args) {
   try {
       //调用各个实现类中的逻辑实现
      (runner).run(args.getSourceArgs());
   }
   catch (Exception ex) {
      throw new IllegalStateException("Failed to execute CommandLineRunner", ex);
   }
}
```

关于CommandLineRunner，我们需要关注的点有两个：

* 所有CommandLineRunner的执行时间点是在SpringBoot应用的Application完全初始化工作之后(这里我们可以认为是SpringBoot应用启动类main方法执行完成之前的最后一步)。
* 当前SpringBoot应用的ApplicationContext中的所有CommandLinerRunner都会被加载执行(无论是手动注册还是被自动扫描注册到IoC容器中)。
