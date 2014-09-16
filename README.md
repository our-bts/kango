kango
=====

REST API for mongo

## API Pattern

Kango提供了几种API访问方式

* GET
    * `/kango/:db/:col` -- 复杂查询，通过query string传递查询条件
    * `/kango/:db/:col/:id` -- 通过primary key查询
* PUT
    * `/kango/:db/:col` -- 新增或修改数据。如果primary key已存在则修改，否则新增。
* POST
    * `/kango/:db/:col/batch-insert` -- 批量插入数据。如果primary key已存在则插入失败。
* DELETE
    * `/kango/:db/:col/:id` -- 通过primary key删除数据。
    
    
## Admin API

Kango提供一些管理的API

* GET
    * `/kango/db` -- 列出当前Mongo所有的database
    * `/kango/:db/collection` -- 列出指定database下的所有collection
    * `/kango/:db/status` -- 查询指定database的状态
    * `/kango/:db/:col/status` -- 查询指定database和collection的状态
    * `/kango/:db/:col/index` -- 查询指定database和collection的index信息
    * `/kango/replset-status` -- 查询当前mongo实例的replication set信息
    * `/kango/server-status` -- 查询当前server状态
* PUT
    * `/kango/dbInfo` -- 注册新的Database
    * `/kango/schema` -- 注册新的Collection以及Collection的index、primary key

## 如何使用

### 注册database

```PUT``` http://localhost:8401/kango/dbInfo

```js
{
    "DB": "sample",
    "IsRemove": false,
    "Status": "Active"
}
```

### 注册collection

```js
{
    "DB": "sample",
    "Schema": "employee",
    "IsRemove": false,
    "Fields": [
        {
            "FieldName": "id",
            "IsIndex": true,
            "IsPrimaryKey": true
        },
        {
            "FieldName": "EmployeeNumber",
            "IsIndex": true,
            "IsPrimaryKey": false
        }
    ]
}
```

那么该collection可以使用如下地址进行数据访问和操作：

* http://localhost:8401/kango/sample/employee
* http://localhost:8401/kango/sample/employee/:id


### 插入一条数据

```PUT``` http://localhost:8401/kango/sample/employee

使用如下request data：

```js
{
"Id": 110000,
"EmployeeNumber": 9527,
"Note": "This is demo employee",
"FirstName": "Beautiful",
"LastName": "Day",
"Email": "Beautiful.Day@abc.com",
"Birthday": "1990-03-15T00:00:00",
"IsActive": true
}
```


### 查询单笔记录

```GET``` http://localhost:8401/kango/sample/employee/110000


### 修改单笔记录

```PUT``` http://localhost:8401/kango/sample/employee

修改和新增是相同的接口，Kango会根据数据的Primary Key去判断，如果存在就是更新，否则就是插入。

我们还是修改刚才插入的数据，为了便于区分，我们加入一个字段__Description__，使用如下request

```js
{
"Id": 110000,
"EmployeeNumber": 9527,
"Note": "This is demo employee",
"Description": "This is added when update",
"FirstName": "Beautiful",
"LastName": "Day",
"Email": "Beautiful.Day@abc.com",
"Birthday": "1990-03-15T00:00:00",
"IsActive": true
}
```


我们仍然可以使用单笔查询进行验证操作是否成功。

### 复杂查询

系统支持有限的一些复杂查询，所有的查询都是通过queryString的方式进行传递。

复杂查询，系统默认都会返回分页的结果，默认的pageSize是10。

```GET``` http://localhost:8401/kango/sample/employee

从结果可以看到，默认的PageIndex是第一页，PageSize是10，Total_Rows是所有符合查询条件的记录数，Rows是查询结果。

pageIndex和pageSize都是可以加入到查询条件上的。

其他关于分页的查询还支持：
* sortField：排序字段
* sort：desc or asc，默认是asc
* fields：数组，查询结果只返回的属性列表。

所有对字段的查询条件都需要满足格式：```f_{fieldName}={value}```

如果value是一个string，那么默认表示对该field进行一个equal操作，如```?f_EmployeeNumer=9527```。

如果value是一个JSON的object，那么格式为：```{"$operator": "parameter"}```

第一个属性的属性名为操作符的名称，属性值为带入操作的参数值

* 使用In操作符：```f_EmployeeNumber={"$in":[9527, 9528]}```
* 使用NotIn操作符：```f_EmployeeNumber={"$nin":[9527, 9528]}```
* 使用Greater操作符：```f_EmployeeNumber={"$gt":9527}```
* 使用GreaterEqual操作符：```f_EmployeeNumber={"$gte":9527}```
* 使用Less操作符：```f_EmployeeNumber={"$lt":9527}```
* 使用LessEqual操作符：```f_EmployeeNumber={"$lte":9527}```
* 使用GreaterAndLess操作符：```f_EmployeeNumber={"$gt":9527, "$lt": 9528}```
* 使用Between操作符：```f_EmployeeNumber={"$gte":9527, "$lte": 9528}```

下面我们做一个查询的示例，我们将会查询Id为80000到89999，生日大于2005年1月1日的所有员工信息，并按照EmployeeNumber进行倒序排序。

```GET``` http://localhost:8401/kango/sample/employee?f_id={"$gte":80000,"$lte":89999}&f_Birthday={"$gt":"2005-01-01"}&sortField=EmployeeNumber&sort=desc


### 批量插入

```POST``` http://localhost:8401/kango/sample/employee/batch-insert

为了方便大量数据插入，我们提供了批量插入数据的接口，和PUT操作不同，考虑到性能问题，系统不会对数据的Primary Key进行检查，所以请确保插入的数据的Primary Key不重复，否则有可能导致插入失败或者是部分失败。

和PUT稍有不同的是，Request Body是一个数组，而不是单个数据实体，这里就不做demo了。
