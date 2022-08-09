[TOC]



# 路由

## 一、引入 js 资源

```html
<script src="vue.min.js"></script>
<script src="vue-router.min.js"></script>
```



## 二、编写 HTML

```html
<div id="app">
    <h1>Hello App!</h1>
    <p>
        <!-- <router-link> 默认会被渲染成一个 `<a>` 标签 -->
        <!--相当于使用 
			<a href=""
		-->
        <!-- 通过传入 `to` 属性指定链接. -->
        <router-link to="/">首页</router-link>
        <router-link to="/student">会员管理</router-link>
        <router-link to="/teacher">讲师管理</router-link>
    </p>
    <!-- 路由出口，路由匹配到的组件将渲染在这里 -->
    <!-- 内容显示的位置 -->
    <router-view></router-view>
</div>
```



## 三、编写 js

```javascript
<script>
    // 1. 定义（路由）组件。
    // 复杂的组件也可以从独立的vue文件中引入
    // 定义菜单点击之后，具体显示内容，相当于定义的变量
    const Welcome = { template: '<div>欢迎</div>' }
    const Student = { template: '<div>student list</div>' }
    const Teacher = { template: '<div>teacher list</div>' }

    // 2. 定义路由对应显示内容，每个路由应该映射一个组件。
// path:  对应的是上面的 <router-link to=" ">
// component 对应的是 const Welcome           
    const routes = [
        { path: '/', redirect: '/welcome' }, //设置默认指向的路径
        { path: '/welcome', component: Welcome },
        { path: '/student', component: Student },
        { path: '/teacher', component: Teacher }
    ]

    // 3. 创建 router 实例，然后传 `routes` 配置
    const router = new VueRouter({
        routes // （缩写）相当于 routes: routes
    })

    // 4. 创建和挂载根实例，把路由创建的对象，在 vue里面初始化
    // 从而让整个应用都有路由功能
    new Vue({
        el: '#app',
        // 初始化
        router
    })

    // 现在，应用已经启动了！
</script>
```







# axios

axios是独立于vue的一个项目，可以用于浏览器和node.js中**发送ajax请求**

## 一、引入 js 资源

```html
<script src="vue.min.js"></script>
<script src="axios.min.js"></script>
```

## 二、编写 js

```javascript
<script>
    new Vue({
        el: '#app',
        // 相当于Java中的变量，设置初始值
        data: {
            memberList: []	//定义数组
        },
        // vue 中生命周期的方法，在数据显示之前执行这个方法
        // 一般都在这里面调用methods中定义的方法，得到数据
        created() {
            this.getList()
        },

        // 定义要使用的方法
        methods: {
            getList(id) {
                // 发送请求成功则执行 .then() 里面的内容，这里面能得到 Ajax返回的数据
                // response，error 是起的名字， => 是箭头函数
                // 失败则执行.catch()里面的内容
                axios.get('teacher.json')
                	// 成功回调，response是后台接口返回的数据
                    .then(response => {	
                    console.log(response)
                    this.memberList = response.data.data.items
                })
                // 失败回调，error是错误信息
                    .catch(error => {	
                    console.log(error)
                })
            }
        }
    })
</script>
```



teacher.json 构造假数据：

```json
{
    "success":true,
    "code":20000,
    "message":"成功",
    "data":{
        "items":[
            {"name":"lucy","age":20},
            {"name":"mary","age":70}
        ]
    }
}
```







## 三、HTML 渲染数据

```html
<div id="app">
    <table border="1">
        <tr>
            <td>id</td>
            <td>姓名</td>
        </tr>
        <tr v-for="item in memberList">
            <td>{{item.id}}</td>
            <td>{{item.name}}</td>
        </td>
    </tr>
</table>
</div>
```

以列表的形式展示