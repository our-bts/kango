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
