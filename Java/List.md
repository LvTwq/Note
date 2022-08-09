### 1、list里面是实体，根据实体的某一字段进行去重

List\<Scjg> scjgs，根据wzdxid去重

#### 1）toMap

```java
    // key-value-有冲突就取前一个
    Map<String, Scjg> map = scjgs.stream().collect(Collectors.toMap(Scjg::getWzdxid, e -> e, (x, y) -> x));
    scjgs = (List<Scjg>) map.values();
```

#### 2）groupingBy

```java
Map<String,List<Scjg>> map1 = scjgs.stream().collect(Collectors.groupingBy(Scjg::getWzdxid));
scjgs = map1.values().stream().map(scjgList -> scjgList.get(0)).collect(Collectors.toList());
```