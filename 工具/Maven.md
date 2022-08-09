[TOC]



# 一、打包

### 1、命令行：

mvn clean package -DskipTests -Pwar：打包成 jar/war

jar 包里 BOOT-INF->classes->  查看



### 2、IDEA：

```xml
<!--这个插件，可以将应用打包成一个可执行的jar包-->
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

然后点击 Lifecycle 中的 package



# 二、groupid和artifactId

GroupId（俗称：包结构）、ArtifactId（俗称：项目名）

groupid 和 artifactId被统称为“坐标”是为了保证项目唯一性而提出的，如果你要把你项目弄到maven本地仓库去，你想要找到你的项目就必须根据这两个id去查找。　　

groupId一般分为多个段，这里我只说两段，第一段为域，第二段为公司名称。

域又分为org、com、cn等等许多，其中org为非营利组织，com为商业组织。

举个apache公司的tomcat项目例子：这个项目的groupId是org.apache，它的域是org（因为tomcat是非营利项目），公司名称是apache，artigactId是tomcat。

比如我创建一个项目，我一般会将groupId设置为cn.snowin，cn表示域为中国，snowin是我个人姓名缩写，artifactId设置为testProj，表示你这个项目的名称是testProj。

依照这个设置，包结构最好是cn.snowin.testProj打头的，如果有个StudentDao，它的全路径就是cn.snowin.testProj.dao.StudentDao

