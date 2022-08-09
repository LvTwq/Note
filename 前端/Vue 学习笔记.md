[TOC]

## 1、Vue 初体验

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>

<body>
    <!-- 由于div已经被vue管理，所以语法会被解析，会在data中找message -->
    <!-- 可以在F12控制台通过app.message='' 来修改值，所以vue被称为响应式，即
                数据发生改变，界面会自动响应 -->
    <div id="app">
        <h2>{{message}}</h2>
    </div>
    <div>{{message}}</div>

    <script src="../js/vue.js"></script>
    <script>
        // let(变量) const(常量)
        // 由于vue.js 中定义了一个Vue对象，所以这里可以直接new一个实例出来
        // 编程范式：声明式编程
        const app = new Vue({
            // el和data都是属性，el用于挂载要管理的元素，让vue来管理这个div
            el: '#app',
            // 定义数据
            data: {
                message: '你好啊，汤老师',
                name: 'coderwhy'
            }
        })
    </script>
</body>

</html>
```

![](..\images\vue01.png)

在 vue 的index.js 中，export default Vue，导出了一个 Vue 对象



## 2、Vue 列表展示

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>

<body>
    <!-- 由于div已经被vue管理，所以语法会被解析，会在data中找 movies -->
    <!-- 可以在F12控制台通过app.movies.push('海王') 来添加值，所以vue被称为响应式，即
                数据发生改变，界面会自动响应 -->
    <div id="app">
        {{movies}}
        <ul>
            <li v-for="item in movies">{{item}}</li>
        </ul>
    </div>


    <script src="../js/vue.js"></script>
    <script>
        // let(变量) const(常量)
        // 由于vue.js 中定义了一个Vue变量，所以这里可以直接new一个实例出来
        // 编程范式：声明式编程
        const app = new Vue({
            // el和data都是属性，el用于挂载要管理的元素，让vue来管理这个div
            el: '#app',
            // 定义数据
            data: {
                movies: ['星际穿越', '虫师', '末代皇帝']
            }
        })
    </script>
</body>

</html>
```

![](..\images\vue02.png)



## 3、案例-计数器

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>

<body>
    <!-- 由于div已经被vue管理，所以语法会被解析，会在data中找message -->
    <!-- 可以在F12控制台通过app.movies.push('海王') 来添加值，所以vue被称为响应式，即
                数据发生改变，界面会自动响应 -->
    <div id="app">
        <h2>当前计数：{{counter}}</h2>
        <button @click="add">+</button>
        <button @click="sub">-</button>
    </div>


    <script src="../js/vue.js"></script>
    <script>
        // let(变量) const(常量)
        // 由于vue.js 中定义了一个Vue变量，所以这里可以直接new一个实例出来
        // 编程范式：声明式编程
        const app = new Vue({
            // el和data都是属性，el用于挂载要管理的元素，让vue来管理这个div
            el: '#app',
            // 定义数据
            data: {
                counter: 0
            },

            methods: {
                add: function () {
                    console.log('add被执行');
                    // 直接写counter是找不到的，因为这样会去找一个全局的counter，但是没有定义
                    // counter
                    // add() 整个方法都是在app这个对象里，所以要用this，表示当前对象
                    this.counter++
                },
                sub: function () {
                    console.log('sub被执行');
                    this.counter--
                }
            }
        })
    </script>
</body>

</html>
```



![](..\images\vue03.png)



## 4、mvvm

![](..\images\vue04.png)



## 5、Vue 的 options 选项

![](..\images\vue05.png)



## 6、生命周期

生命周期（钩子hook函数）：事物从诞生到消亡的整个过程



## 7、v-once

![](..\images\vue06.png)



## 8、v-bind

![](..\images\vue07.png)

## 9、计算属性

![](..\images\vue08.png)



## 10、let/var

![](..\images\vue09.png)



## 11、const

![](..\images\vue10.png)

```javascript
// 常量的含义是指向的对象不能修改，但是可以改变对象内部属性
const obj = {
    name: 'why',
    age: 18,
    height: 1.88
}
// 错
obj = {};
// 正确：
obj.name = '111';
obj.age = 40;
obj.height = 1.87;
```



## 12、对象增强写法

![](..\images\vue11.png)



## 13、v-on

![](..\images\vue12.png)

![](..\images\vue13.png)



## 14、v-if

![](..\images\vue14.png)



## 15、v-for

![](..\images\vue15.png)



## 16、v-model

获取用户输入的数据，表单元素和数据的双向绑定

![](..\images\vue16.png)





修饰符

![](..\images\vue18.png)



## 17、组件化开发

![](..\images\vue19.png)

![](..\images\vue20.png)

![](..\images\vue21.png)

![](..\images\vue22.png)



![](..\images\vue23.png)

![](..\images\vue24.png)

![](..\images\vue25.png)



在父组件中拿到子组件的对象，直接操作子组件里的一些东西

![](..\images\vue26.png)

## 18、插槽

![](..\images\vue27.png)

