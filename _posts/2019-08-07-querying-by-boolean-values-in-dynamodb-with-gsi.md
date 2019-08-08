---
layout: post
title: "Querying By Boolean Values in DynamoDB with GSI"
date: 2019-08-07
tags: [dynamodb,aws]
banner_image: dynamodb-gsi.jpg
---

It is a common scenario in DynamoDB that you want to query all the items by a
boolean value. e.g. you have a table that stores all the tasks, some running and
some completed. And you want to periodically fetch out all the running tasks
without scanning the whole table or separating them into two tables.

One way to do it is to use *global secondary index*. However, indexing in
DynamoDB is different from that in a relational database. Just migrating the
knowledge of MySQL indexing to DynamoDB might cause some confusions.

In DynamoDB, a *GSI* is very much like a table: It has its own partition key and
sort key. It also splits its data into partitions. You can query a GSI but you
must specify the partition key in the query operation, just like how you query a
table. In fact, you can just think of a GSI as a table, except that each time
you insert, update or delete an item, the same item gets inserted, updated or
deleted in all the GSIs, which also means, **the more GSIs you have, the slower
it can be**.

In the creation of a GSI, you can specify which fields you want to store in the
GSI, which is called *projection*. The simplest is to only store the partition
key and sort key of the item (which are required in order to refer back to the
actual item), but you can also store all the fields at the cost of writing
performance.

The primary key of a GSI has two advantages over that of the table, which makes
it possible to query by a boolean value.

1. If the partition key or sort key of the GSI is missing in the item, the item
   won't be inserted to the GSI. Or if it's already in the GSI, then it will be
   deleted from the GSI.
2. The composition of the partition key and sort key doesn't need to be unique
   in the GSI.

Making use of this feature, we can support querying by task status by creating a
GSI with this composite primary key:

- Use the task ID (or any other field whose values are distributed in a large
  value range) as the partition key;
- Use a boolean `running` field as the sort key: the **presence** of the field
  means *running* and the **absence** means *completed*. Or you can store more
  informative values in the sort key, like `runningCount`, which indicates how
  many times the task has been executed, or `runningSince`, which indicates when
  the task started.
