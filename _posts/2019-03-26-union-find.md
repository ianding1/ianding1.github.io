---
layout: post
title: "Union Find"
date: 2019-03-26
tags: [algorithm]
banner_image: union-find-banner.jpg
---

Assume that you have some nodes, each of which belongs to a group. How can you effectively check if two nodes are in the same group or merge two groups? UnionFind is a very fast algorithm to solve this problem. In this post, we first address how the UnionFind problem raises in a graph problem, then present the UnionFind algorithm, and analyze its time complexity in the end (which is optional).

<!--more-->

First, let's look at the minimum spanning tree problem.

{% include image_caption.html imageurl="/images/posts/unionfind-mst.png" title="MST" caption="A Graph and Its Minimum Spanning Tree" %}

Assume that you are given a graph of n nodes. Each edge in the graph has a weight. You want to find a subset of the edges such that it connects all the nodes into a tree and the sum of the edge weights should be as small as possible. We know that, in order to connect all the n nodes without forming a circle, we need exactly n-1 edges. This can be proved by an induction on the number of nodes.

Now the question is: how should we choose these n-1 edges from all the edges? Kruskal's algorithm tells us that we can sort all the edges by their weights from the smallest to the largest and try adding each of them to the result edge set in order. At first, every nodes belongs to a tree that contains only itself. If the two endpoints of the edge we are now looking at belong to different trees, we add this edge to the result edge set and connect the two trees into one. Otherwise we discard the edge. When we have n-1 edges in the result edge set, we get the minimum spanning tree of the graph.

Let's put aside why this algorithm works and, instead, look at how UnionFind is used in the algorithm. In this algorithm, we constantly check if two nodes are in the same tree and merge two trees. This is exactly what UnionFind is used for.

{% include image_caption.html imageurl="/images/posts/unionfind-find.png" title="Find" caption="The Find Operation" %}

Here is how UnionFind works. UnionFind contains two operations: `FIND(x)`, which returns the group ID of node x, and `UNION(x,y)`, which combines the group of node x and that of node y.

Each group is represented as a tree and each node stores the ID of its parent node (the root node stores its own ID). The group ID is the root node ID. **`FIND(x)` works by following the path until the root node, setting the parents of all the accessed nodes along the path to the root node and return the root ID. `UNION(x, y)` works by first finding the two roots and then making one root be the child of the other.**

Here comes the question. Given two roots, which should be the new parent? The motivation is to keep the tree depths as small as possible. However, calculating tree depths requires traversing the tree, which is slow. To solve this problem, each node is assigned a rank, an approximation of tree depths. **Initially, all the ranks are 0. When connecting two roots, we always make the one with the smaller rank be the child. If the two roots have the same rank, we can choose either of the two to be the child and increase the rank of the parent by one.**

This algorithm is fast, because during the `FIND` operation, we connect all the passed nodes to the root, making the whole tree very flat. A simple analysis on tree depths gives us the worst time complexity of `FIND` being `O(log n)` (that of `UNION` is also `O(log n)`, obviously, since it contains two find operations). But we can in further show that the amortized time complexity of `FIND` is `O(log* n)`, which is a *very* slowly-growing function.

We can look at a few examples to feel how slowly it grows. `log* n` is a function asking "how many times do you need to apply `log2` to reduce n to 1?" We can see that `log* 2 = 1`, `log* 4 = 2`, `log* 16 = 3`, `log* 65536 = 4`... It gives us a sense that it grows almost like a constant function in the programming world.
