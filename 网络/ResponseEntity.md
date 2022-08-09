## ResponseEntity

标识整个HTTP响应：状态码，头部信息以及响应体内容，因此可以使用 ResponseEntity 设置http响应内容。

如果需要使用 ResponseEntity，必须在请求点返回，ResponseEntity 是通用类型，因此可以使用任意类型作为响应体：

```java
@GetMapping("/hello")
ResponseEntity<String> hello() {
    return new ResponseEntity<>("Hello World!", HttpStatus.OK);
}
```

可以指定响应状态，根据不同场景返回不同状态

```java
@GetMapping("/age")
ResponseEntity<String> age(
  @RequestParam("yearOfBirth") int yearOfBirth) {

    if (isInFuture(yearOfBirth)) {
        return new ResponseEntity<>(
          "Year of birth cannot be in the future", 
          HttpStatus.BAD_REQUEST);
    }

    return new ResponseEntity<>(
      "Your age is " + calculateAge(yearOfBirth), 
      HttpStatus.OK);
}
```

设置响应头

```java
@GetMapping("/customHeader")
ResponseEntity<String> customHeader() {
    HttpHeaders headers = new HttpHeaders();
    headers.add("Custom-Header", "foo");

    return new ResponseEntity<>(
      "Custom header set", headers, HttpStatus.OK);
}
```

ResponseEntity提供了两个内嵌的构建器接口: HeadersBuilder 和其子接口 BodyBuilder。因此我们能通过ResponseEntity的静态方法直接访问。

最简单的情况是响应包括一个主体及http 200响应码：

```java
@GetMapping("/hello")
ResponseEntity<String> hello() {
    return ResponseEntity.ok("Hello World!");
}
```

大多数常用的http 响应码，可以通过下面static方法：

```java
BodyBuilder accepted();
BodyBuilder badRequest();
BodyBuilder created(java.net.URI location);
HeadersBuilder<?> noContent();
HeadersBuilder<?> notFound();
BodyBuilder ok();
```

