[TOC]


# 安装
```sh
docker pull elasticsearch:7.11.1
docker run --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms512m -Xmx512m" -d elasticsearch:7.11.1

# 验证是否成功
curl http://localhost:9200

# 安装 IK分词器
docker exec -it elasticsearch /bin/bash
cd /usr/share/elasticsearch/plugins/
elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.11.1/elasticsearch-analysis-ik-7.11.1.zip 
exit
docker restart elasticsearch 


# 安装kibana
docker pull kibana:7.11.1
# 启动以后可以打开浏览器输入http://ip:5601就可以打开kibana的界面
docker run --name kibana --link=elasticsearch:elasticsearch -p 5601:5601 -d kibana:7.11.1

```


# 原理

## 基础概念

* Near Realtime（NRT） 近实时。数据提交索引后，立马就可以搜索到。
* Cluster 集群，一个集群由一个唯一的名字标识，默认为“elasticsearch”。集群名称非常重要，具有相同集群名的节点才会组成一个集群。集群名称可以在配置文件中指定。
* Node 节点：存储集群的数据，参与集群的索引和搜索功能。像集群有名字，节点也有自己的名称，默认在启动时会以一个随机的UUID的前七个字符作为节点的名字，你可以为其指定任意的名字。通过集群名在网络中发现同伴组成集群。一个节点也可是集群。
* Index 索引: 一个索引是一个文档的集合（等同于solr中的集合）。每个索引有唯一的名字，通过这个名字来操作它。一个集群中可以有任意多个索引。
* Type 类型：指在一个索引中，可以索引不同类型的文档，如用户数据、博客数据。从6.0.0 版本起已废弃，一个索引中只存放一类数据。
* Document 文档：被索引的一条数据，索引的基本信息单元，以JSON格式来表示。
* Shard 分片：在创建一个索引时可以指定分成多少个分片来存储。每个分片本身也是一个功能完善且独立的“索引”，可以被放置在集群的任意节点上。
* Replication 备份: 一个分片可以有多个备份（副本）

![](..\images\es01.png)


# 查询和聚合的基础使用

## 相关字段解释
* took – Elasticsearch运行查询所花费的时间（以毫秒为单位）
* timed_out –搜索请求是否超时
* _shards - 搜索了多少个碎片，以及成功，失败或跳过了多少个碎片的细目分类。
* max_score – 找到的最相关文档的分数
* hits.total.value - 找到了多少个匹配的文档
* hits.sort - 文档的排序位置（不按相关性得分排序时）
* hits._score - 文档的相关性得分（使用match_all时不适用）

![](..\images\es-usage-3.png)

## 查询所有
```sh
GET /bank/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ]
}
```

## 分页查询(from+size)
```sh
GET /bank/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ],
  "from": 10,
  "size": 10
}
```


## 指定字段查询(match)
如果要在字段中搜索**特定字词**，可以使用match; 如下语句将查询address 字段中包含 mill 或者 lane的数据
精确到每个词，mil 无效，但大小写不敏感
```sh
GET /bank/_search
{
  "query": { "match": { "address": "mill lane" } }
}
```

## 查询段落匹配(match_phrase)
如果我们希望查询的条件是 address字段中包含 "mill lane"，则可以使用match_phrase
精确到每个词，mill lan 无效，但大小写不敏感
```sh
GET /bank/_search
{
  "query": { "match_phrase": { "address": "mill lane" } }
}
```



## 多条件查询(bool)
如果要构造更复杂的查询，可以使用bool查询来组合多个查询条件。

例如，以下请求在bank索引中搜索40岁客户的帐户，但不包括居住在爱达荷州（ID）的任何人
```sh
GET /bank/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "age": "40" } }
      ],
      "must_not": [
        { "match": { "state": "ID" } }
      ]
    }
  }
}
```


## 查询条件(query or filter)
在bool查询的子句中同时具备query/must 和 filter
两者都可以写查询条件，而且语法也类似。区别在于，query 上下文的条件是用来给文档打分的，匹配越好 _score 越高；filter 的条件只产生两种结果：符合与不符合，后者被过滤掉
```sh
GET /bank/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "state": "ND"
          }
        }
      ],
      "filter": [
        {
          "term": {
            "age": "40"
          }
        },
        {
          "range": {
            "balance": {
              "gte": 20000,
              "lte": 30000
            }
          }
        }
      ]
    }
  }
}
```



## 聚合查询(Aggregation)

### 简单聚合
比如我们希望计算出account每个州的统计数量， 使用aggs关键字对state字段聚合，被聚合的字段无需对分词统计，所以使用state.keyword对整个字段统计
```sh
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
```


### 嵌套聚合
计算每个州的平均结余。涉及到的就是在对state分组的基础上，嵌套计算avg(balance):
```sh
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}
```


### 对聚合结果排序
可以通过在aggs中对嵌套聚合的结果进行排序

比如承接上个例子， 对嵌套计算出的avg(balance)，这里是average_balance，进行排序
```sh
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword",
        "order": {
          "average_balance": "desc"
        }
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}
```


# 索引
## 禁止自动创建索引
如果我们需要对这个建立索引的过程做更多的控制：比如想要确保这个索引有数量适中的主分片，并且在我们索引任何数据之前，分析器和映射已经被建立好。那么就会引入两点：第一个禁止自动创建索引，第二个是手动创建索引。
可以通过在 config/elasticsearch.yml 的每个节点下添加下面的配置：
```yml
action.auto_create_index: false
```

## 手动创建索引

### 索引的格式

在请求体里面传入设置或类型映射，如下所示：
```sh
PUT /my_index
{
    "settings": { ... any settings ... },
    "mappings": {
        "properties": { ... any properties ... }
    }
}
```

* settings: 用来设置分片,副本等配置信息
* mappings: 字段映射，类型等
  * properties: 由于type在后续版本中会被Deprecated, 所以无需被type嵌套

### 索引管理

#### 创建索引
我们创建一个 user 索引 test-index-users，其中包含三个属性：name，age, remarks; 存储在一个分片一个副本上
```sh
PUT /test-index-users
{
  "settings": {
		"number_of_shards": 1,
		"number_of_replicas": 1
	},
  "mappings": {
    "properties": {
      "name": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword",
            "ignore_above": 256
          }
        }
      },
      "age": {
        "type": "long"
      },
      "remarks": {
        "type": "text"
      }
    }
  }
}
```

#### 查看索引
```sh
curl 'localhost:9200/_cat/indices?v' | grep users
```
刚创建的索引的状态是yellow的，因为我测试的环境是单点环境，无法创建副本，但是在上述number_of_replicas配置中设置了副本数是1； 所以在这个时候我们需要修改索引的配置。修改副本数量为0

```sh
PUT /test-index-users/_settings
{
  "settings": {
    "number_of_replicas": 0
  }
}
```
再次查看，状态为green

或者
```sh
GET /test-index-users/_mapping

GET /test-index-users/_settings
```


#### 打开/关闭索引

一旦索引被关闭，那么这个索引只能显示元数据信息，不能够进行读写操作。

```sh
POST /test-index-users/_close
POST /test-index-users/_open
```


#### 删除索引
```sh
DELETE /test-index-users
```

## 索引模板
* 首先创建两个索引组件模板：
```sh
PUT _component_template/component_template1
{
  "template": {
    "mappings": {
      "properties": {
        "@timestamp": {
          "type": "date"
        }
      }
    }
  }
}

PUT _component_template/runtime_component_template
{
  "template": {
    "mappings": {
      "runtime": { 
        "day_of_week": {
          "type": "keyword",
          "script": {
            "source": "emit(doc['@timestamp'].value.dayOfWeekEnum.getDisplayName(TextStyle.FULL, Locale.ROOT))"
          }
        }
      }
    }
  }
}
```

* 创建使用组件模板的索引模板
```sh
PUT _index_template/template_1
{
  "index_patterns": ["bar*"],
  "template": {
    "settings": {
      "number_of_shards": 1
    },
    "mappings": {
      "_source": {
        "enabled": true
      },
      "properties": {
        "host_name": {
          "type": "keyword"
        },
        "created_at": {
          "type": "date",
          "format": "EEE MMM dd HH:mm:ss Z yyyy"
        }
      }
    },
    "aliases": {
      "mydata": { }
    }
  },
  "priority": 500,
  "composed_of": ["component_template1", "runtime_component_template"], 
  "version": 3,
  "_meta": {
    "description": "my custom"
  }
}

```

# DSL 查询
## 复合查询

### bool query(布尔查询)

Bool查询语法有以下特点：
* 子查询可以任意顺序出现
* 可以嵌套多个查询，包括bool查询
* 如果bool查询中没有must条件，should中必须至少满足一条才会返回结果。

bool查询包含四种操作符，分别是must,should,must_not,filter。他们均是一种数组，数组里面是对应的判断条件。
* must： 必须匹配。贡献算分
* must_not：过滤子句，必须不能匹配，但不贡献算分
* should： 选择性匹配，至少满足一条。贡献算分
* filter： 过滤子句，必须匹配，但不贡献算分


```sh
POST _search
{
  "query": {
    "bool" : {
      "must" : {
        "term" : { "user.id" : "kimchy" }
      },
      "filter": {
        "term" : { "tags" : "production" }
      },
      "must_not" : {
        "range" : {
          "age" : { "gte" : 10, "lte" : 20 }
        }
      },
      "should" : [
        { "term" : { "tags" : "env1" } },
        { "term" : { "tags" : "deployed" } }
      ],
      "minimum_should_match" : 1,
      "boost" : 1.0
    }
  }
}
```

### boosting query(提高查询)
不同于bool查询，bool查询中只要一个子查询条件不匹配那么搜索的数据就不会出现。而boosting query则是降低显示的权重/优先级（即score)
```sh
POST /test-dsl-boosting/_bulk
{ "index": { "_id": 1 }}
{ "content":"Apple Mac" }
{ "index": { "_id": 2 }}
{ "content":"Apple Fruit" }
{ "index": { "_id": 3 }}
{ "content":"Apple employee like Apple Pie and Apple Juice" }

GET /test-dsl-boosting/_search
{
  "query": {
    "boosting": {
      "positive": {
        "term": {
          "content": "apple"
        }
      },
    #   对匹配pie的做降级显示处理
      "negative": {
        "term": {
          "content": "pie"
        }
      },
      "negative_boost": 0.5
    }
  }
}
```

### constant_score（固定分数查询）
查询某个条件时，固定的返回指定的score；显然当不需要计算score时，只需要filter条件即可，因为filter context忽略score

```sh
POST /test-dsl-constant/_bulk
{ "index": { "_id": 1 }}
{ "content":"Apple Mac" }
{ "index": { "_id": 2 }}
{ "content":"Apple Fruit" }

GET /test-dsl-constant/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "term": { "content": "apple" }
      },
      "boost": 1.2
    }
  }
}
```


### dis_max(最佳匹配查询）
分离最大化查询（Disjunction Max Query）指的是： 将任何与任一查询匹配的文档作为结果返回，但只将最佳匹配的评分作为查询的评分结果返回 。

假设有个网站允许用户搜索博客的内容，以下面两篇博客内容文档为例：

```sh
POST /test-dsl-dis-max/_bulk
{ "index": { "_id": 1 }}
{"title": "Quick brown rabbits","body":  "Brown rabbits are commonly seen."}
{ "index": { "_id": 2 }}
{"title": "Keeping pets healthy","body":  "My quick brown fox eats rabbits on a regular basis."}
```
用户输入词组 “Brown fox” 然后点击搜索按钮。事先，我们并不知道用户的搜索项是会在 title 还是在 body 字段中被找到，但是，用户很有可能是想搜索相关的词组。用肉眼判断，**文档 2 的匹配度更高**，因为它同时包括要查找的两个词：

现在运行以下 bool 查询，文档1的分数却更高

```sh
GET /test-dsl-dis-max/_search
{
    "query": {
        "bool": {
            "should": [
                { "match": { "title": "Brown fox" }},
                { "match": { "body":  "Brown fox" }}
            ]
        }
    }
}
```


不使用 bool 查询，可以使用 dis_max 即分离 最大化查询（Disjunction Max Query） 。
分离（Disjunction）的意思是 或（or） ，这与可以把结合（conjunction）理解成 与（and） 相对应。分离最大化查询（Disjunction Max Query）指的是： 将任何与任一查询匹配的文档作为结果返回，但只将最佳匹配的评分作为查询的评分结果返回 ：

```sh
GET /test-dsl-dis-max/_search
{
    "query": {
        "dis_max": {
            "queries": [
                { "match": { "title": "Brown fox" }},
                { "match": { "body":  "Brown fox" }}
            ],
            "tie_breaker": 0
        }
    }
}
```


### function_score(函数查询）
简而言之就是用自定义function的方式来计算_score。
可以ES有哪些自定义function呢？

* script_score 使用自定义的脚本来完全控制分值计算逻辑。如果你需要以上预定义函数之外的功能，可以根据需要通过脚本进行实现。
* weight 对每份文档适用一个简单的提升，且该提升不会被归约：
* 当weight为2时，结果为2 * _score。
* random_score 使用一致性随机分值计算来对每个用户采用不同的结果排序方式，对相同用户仍然使用相同的排序方式。
* field_value_factor 使用文档中某个字段的值来改变_score，比如将受欢迎程度或者投票数量考虑在内。
* 衰减函数(Decay Function) - linear，exp，gauss


## 全文搜索
### Match 类型

#### 单个词
```sh
PUT /test-dsl-match
{ "settings": { "number_of_shards": 1 }} 

POST /test-dsl-match/_bulk
{ "index": { "_id": 1 }}
{ "title": "The quick brown fox" }
{ "index": { "_id": 2 }}
{ "title": "The quick brown fox jumps over the lazy dog" }
{ "index": { "_id": 3 }}
{ "title": "The quick brown fox jumps over the quick dog" }
{ "index": { "_id": 4 }}
{ "title": "Brown fox brown dog" }

GET /test-dsl-match/_search
{
    "query": {
        "match": {
            "title": "QUICK!"
        }
    }
}
```
执行这个match查询的步骤：
1. 检查字段类型
   标题 title 字段是一个 string 类型（ analyzed ）已分析的全文字段，这意味着查询字符串本身也应该被分析。
2. 分析查询字符串
   将查询的字符串 QUICK! 传入标准分析器中，输出的结果是单个项 quick 。因为只有一个单词项，所以 match 查询执行的是单个底层 term 查询。
3. 查找匹配文档
   用 term 查询在倒排索引中查找 quick 然后获取一组包含该项的文档，本例的结果是文档：1、2 和 3 。
4. 为每个文档评分
   用 term 查询计算每个文档相关度评分 _score ，这是种将词频（term frequency，即词 quick 在相关文档的 title 字段中出现的频率）和反向文档频率（inverse document frequency，即词 quick 在所有文档的 title 字段中出现的频率），以及字段的长度（即字段越短相关度越高）相结合的计算方式。

#### 多个词

```sh
GET /test-dsl-match/_search
{
    "query": {
        "match": {
            "title": "BROWN DOG"
        }
    }
}
```
因为 match 查询必须查找两个词（ ["brown","dog"] ），它在内部实际上先执行两次 term 查询，然后将两次查询的结果合并作为最终结果输出。为了做到这点，它将两个 term 查询包入一个 bool 查询中，所以上述查询的结果，和如下语句查询结果是等同的
```sh
GET /test-dsl-match/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "term": {
            "title": "brown"
          }
        },
        {
          "term": {
            "title": "dog"
          }
        }
      ]
    }
  }
}
```


上面等同于should（任意一个满足），是因为 match还有一个operator参数，默认是or, 所以对应的是should。所以上述查询也等同于
```sh
GET /test-dsl-match/_search
{
  "query": {
    "match": {
      "title": {
        "query": "BROWN DOG",
        "operator": "or"
      }
    }
  }
}
```

那么我们如果是需要and操作呢，即同时满足呢？
```sh
GET /test-dsl-match/_search
{
  "query": {
    "match": {
      "title": {
        "query": "BROWN DOG",
        "operator": "and"
      }
    }
  }
}
```
等同于
```sh
GET /test-dsl-match/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "title": "brown"
          }
        },
        {
          "term": {
            "title": "dog"
          }
        }
      ]
    }
  }
}
```

#### 控制match的匹配精度
如果用户给定 3 个查询词，想查找至少包含其中 2 个的文档，该如何处理？
将 operator 操作符参数设置成 and 或者 or 都是不合适的。
match 查询支持 minimum_should_match 最小匹配参数，这让我们可以指定必须匹配的词项数用来表示一个文档是否相关。我们可以将其设置为某个具体数字，更常用的做法是将其设置为一个百分数，因为我们无法控制用户搜索时输入的单词数量：
```sh
GET /test-dsl-match/_search
{
  "query": {
    "match": {
      "title": {
        "query":                "quick brown dog",
        "minimum_should_match": "75%"
      }
    }
  }
}
```
当给定百分比的时候， minimum_should_match 会做合适的事情：在之前三词项的示例中， 75% 会自动被截断成 66.6% ，即三个里面两个词。无论这个值设置成什么，至少包含一个词项的文档才会被认为是匹配的。
等同于
```sh
GET /test-dsl-match/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "title": "quick" }},
        { "match": { "title": "brown"   }},
        { "match": { "title": "dog"   }}
      ],
      "minimum_should_match": 2 
    }
  }
}
```

#### 其它match类型
##### match_pharse
在前文中我们已经有了解，我们再看下另外一个例子。
```sh
GET /test-dsl-match/_search
{
  "query": {
    "match_phrase": {
      "title": {
        "query": "quick brown f"
      }
    }
  }
}
```
这样的查询是查不出任何数据的，因为前文中我们知道了match本质上是对term组合，match_phrase本质是连续的term的查询，所以f并不是一个分词，不满足term查询，所以最终查不出任何内容了。

##### match_pharse_prefix
那有没有可以查询出quick brown f的方式呢？ELasticSearch在match_phrase基础上提供了一种可以查最后一个词项是前缀的方法，这样就可以查询quick brown f了
```sh
GET /test-dsl-match/_search
{
  "query": {
    "match_phrase_prefix": {
      "title": {
        "query": "quick brown f"
      }
    }
  }
}
```
prefix的意思不是整个text的开始匹配，而是最后一个词项满足term的prefix查询而已

##### match_bool_prefix
```sh
GET /test-dsl-match/_search
{
  "query": {
    "match_bool_prefix": {
      "title": {
        "query": "quick brown f"
      }
    }
  }
}
```
它们两种方式有啥区别呢？
match_bool_prefix本质上可以转换为：
```sh
GET /test-dsl-match/_search
{
  "query": {
    "bool" : {
      "should": [
        { "term": { "title": "quick" }},
        { "term": { "title": "brown" }},
        { "prefix": { "title": "f"}}
      ]
    }
  }
}
```
所以这样你就能理解，match_bool_prefix查询中的quick,brown,f是无序的。


##### multi_match
如果我们期望一次对多个字段查询，怎么办呢？ElasticSearch提供了multi_match查询的方式
```sh
{
  "query": {
    "multi_match" : {
      "query":    "Will Smith",
      "fields": [ "title", "*_name" ] 
    }
  }
}
```


### query string 类型
#### query_string



#### query_string_simple



### Interval 类型
Intervals是时间间隔的意思，本质上将多个规则按照顺序匹配。比如：
```sh
GET /test-dsl-match/_search
{
  "query": {
    "intervals" : {
      "title" : {
        "all_of" : {
          "ordered" : true,
          "intervals" : [
            {
              "match" : {
                "query" : "quick",
                "max_gaps" : 0,
                "ordered" : true
              }
            },
            {
              "any_of" : {
                "intervals" : [
                  { "match" : { "query" : "jump over" } },
                  { "match" : { "query" : "quick dog" } }
                ]
              }
            }
          ]
        }
      }
    }
  }
}
```


# 分词

## 分词器测试
```sh
POST /_analyze
{
  "analyzer":"standard",
  "text":"小米手机性价比很高"
}
```