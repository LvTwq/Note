[TOC]

# 一、Synchronized 简介

## 1. Synchronized 的作用

能够保证在**同一时刻**最多只有**一个**线程执行该代码，以达到保证并发安全的效果。

示例一：两个线程执行完的最后结果不为 20000

```java
public class DisappearRequest1 implements Runnable {

    static DisappearRequest1 instance = new DisappearRequest1();

    static int i = 0;

    public static void main(String[] args) throws InterruptedException {
        // 这两个线程用的是同一个实例，所以共用这个实例里的方法
        Thread t1 = new Thread(instance);
        Thread t2 = new Thread(instance);
        t1.start();
        t2.start();

        // 为了保证是在线程执行完才输出，可以让线程等待
        t1.join();
        t2.join();
        System.out.println(i);

    }

    @Override
    public void run() {
        for (int j = 0; j < 10000; j++) {
            i++;
        }
    }
}
```

原因：i++ 包含了3个操作：

1）读取 i

2）将 i 加一

3）将 i 的值写入到内存中

当 i=9时，t1将i+1，但还没来得及写入到内存中，t2读取i时，i 还是9，执行+1操作，两个线程一起将他写入到内存中，i=10。

将这种行为称为线程不安全。



## 2. Synchronized 的用法

### 2.1 对象锁

1）同步代码块锁（自己指定锁对象）

```java
public class SynchronizedObjectCodeBlock2 implements Runnable {

    static SynchronizedObjectCodeBlock2 instance = new SynchronizedObjectCodeBlock2();

    @Override
    public void run() {
        // 以一个整体执行
        synchronized (this) {
            System.out.println("我是对象锁的代码块形式，我叫：" + Thread.currentThread().getName());
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() + "运行结束。");
        }
    }

    public static void main(String[] args) {
        Thread t1 = new Thread(instance);
        Thread t2 = new Thread(instance);
        t1.start();
        t2.start();
        while (t1.isAlive() || t2.isAlive()) {
        }
        System.out.println("finished");
    }
}
```

**补充**：利用IDEA查看线程状态

![](..\images\查看线程状态.png)



```java
    Object lock1 = new Object();
    Object lock2 = new Object();

    @Override
    public void run() {
        // 以一个整体执行
        synchronized (lock1) {
            System.out.println("我是lock1，我叫：" + Thread.currentThread().getName());

            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() + "，lock1运行结束。");
        }

        synchronized (lock2) {
            System.out.println("我是lock2，我叫：" + Thread.currentThread().getName());

            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() + "lock2运行结束。");
        }
    }
```



2）普通方法锁（默认锁对象为this当前实例对象）

```java
public class SynchronizedObjectMethod3 implements Runnable{

    static SynchronizedObjectMethod3 instance = new SynchronizedObjectMethod3();


    @Override
    public void run() {
        method();
    }

    public synchronized void method(){
        System.out.println("我是对象锁的方法修饰符形式，我叫：" + Thread.currentThread().getName());
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName() + "运行结束。");
    }


    public static void main(String[] args) {
        Thread t1 = new Thread(instance);
        Thread t2 = new Thread(instance);
        t1.start();
        t2.start();

        while (t1.isAlive() || t2.isAlive()) {
        }
        System.out.println("finished");
    }
}
```





### 2.2 类锁

Java 类可能有很多个对象，但是只有一个Class对象，所以类锁就是**Class对象**的锁，类锁只能在同一时刻被**一个对象**拥有。

这就和对象锁不同：不同的实例创建出来，锁之间是不影响的，可以同时运行。

1）修饰静态的方法

```java
public class SynchronizedClassStatic4 implements Runnable {

    static SynchronizedClassStatic4 instance1 = new SynchronizedClassStatic4();
    static SynchronizedClassStatic4 instance2 = new SynchronizedClassStatic4();


    public static synchronized void method() {
        System.out.println("我是类锁的第一种形式：static形式，我叫：" + Thread.currentThread().getName());
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName() + "运行结束。");
    }

    public static void main(String[] args) {
        Thread t1 = new Thread(instance1);
        Thread t2 = new Thread(instance2);
        t1.start();
        t2.start();

        while (t1.isAlive() || t2.isAlive()) {
        }
        System.out.println("finished");
    }

    @Override
    public void run() {
        method();
    }
}
```



2）指定锁为Class对象

共用同一个对象，即便是不同的实例，也会串行执行

```java
public class SynchronizedClassClass5 implements Runnable {

    static SynchronizedClassClass5 instance1 = new SynchronizedClassClass5();
    static SynchronizedClassClass5 instance2 = new SynchronizedClassClass5();


    public static void main(String[] args) {
        Thread t1 = new Thread(instance1);
        Thread t2 = new Thread(instance2);
        t1.start();
        t2.start();

        while (t1.isAlive() || t2.isAlive()) {
        }
        System.out.println("finished");
    }


    private void method() {
        synchronized (SynchronizedClassClass5.class) {
            System.out.println("我是类锁的第二种形式：(.class)形式，我叫：" + Thread.currentThread().getName());
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() + "运行结束。");
        }
    }

    @Override
    public void run() {
        method();
    }
}
```

