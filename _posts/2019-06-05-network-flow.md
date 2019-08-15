---
layout: post
title: "Network Flow"
date: 2019-06-05
banner_image: network-flow-banner.jpg
tags: [algorithm]
---

{% include image_caption.html imageurl="/images/posts/network-flow-max-flow-example.svg" %}

Given a directed graph `G` that has a single source `s` and target `t`, where
each edge has a non-negative **integer** capacity (the maximum of flow that can
be passed through this edge), what is the maximum flow that can be passed from
the source to the target?

This problem is known as **max flow**.

<!--more-->

# Max flow

The idea of solving a max flow problem is that each time we find a path from the
source to the target and push some flow onto it. We iterate this process until
we cannot find such path. The sum of all the flows that we have pushed is the
max flow.

This algorithm is called Ford-Folkerson algorithm. It works in the following
steps:

1. First we **find a path from the source to the target with a capacity greater
   than zero** (the capacity of a path is the smallest capacity of the edges on
   the path). This can be done by BFS from the source to the target.
2. Then we **push some flows on this path**, which equals to the capacity of the
   path. By pushing this flow, we **subtract the capacity of each edge on the
   path by the flow**, since the remaining capacity is reduced, and **add the
   capacity of each reversed edge on the path by the flow** (explained later).
   e.g. for an edge `(u, v)`, we subtract `capacity(u, v)` by the flow, and add
   `capacity(v, u)` by the flow (if there is no edge `(v, u)`, we add such an
   edge with zero capacity first). 
3. Go to step 1 until we cannot find such path.

The following graph is the **residual graph** after pushing 3 units. Notice the
**red** reversed edges that we created just now.

{% include image_caption.html imageurl="/images/posts/network-flow-max-flow-example-residual-graph.svg" %}

This is the final residual graph where you cannot push any more flows onto it.
The max flow is 6.

{% include image_caption.html imageurl="/images/posts/network-flow-max-flow-example-final-graph.svg" %}

The trick of this algorithm is **to increase the capacity of the reversed edges.** 

Here is how we understand it: let's focus on a specific edge `(u, v)`. 

Assume that we have already pushed 2 units from `u` to `v`. Later we decide to
push 2 units from `v` to `u`. By pushing equal units from opposite directions,
we actually **cancel them out altogether**, i.e. we didn't push anything in
effect.

In fact, We can think of pushing in the opposite direction as **undoing what we
have done**.

In order to undo our work, we need to record how many units we can undo at most.
This is exactly reflected in the capacity of the reversed edges.

Back to the algorithm, we said that we need to **find a path** from the source
to the target. Obviously, how we find the path significantly influences the time
we need to run the algorithm. In the worst case, we always find the path of the
smallest capacity, in which case we need to increase the flow bit by bit.

We can estimate the time complexity of Ford-Folkerson by this:

1. Each iteration requires `O(m)` to find a path and modify the capacity on the
   path (`m` is the number of edges).
2. In the worst case, we increase the flow by one in each iteration. Assuming
   the maximum flow is `F`, the number of iterations is `O(F)`.
3. The above two gives us the upper bound of `O(mF)`.

Unfortunately, the running time of this simple algorithm is exponential to the
input size. Assuming that max flow is represented in `f` bits, the time
complexity is in fact `O(m*2^f)`.

Thankfully, with minor modifications, we will have a polynomial algorithm. One
approach is called **Edmond-Karp** algorithm. In this algorithm, **we choose the
shortest path from the source to the target in each iteration**. It gives an
upper bound of `O(m^2*n)`.

The magic is that Edmond-Karp algorithm guarantees that the number of iterations
is at most `O(mn)`. Since in each iteration we run a BFS in `O(m)`, the total
time is `O(m^2*n)`.

# Min cut

An interesting fact about network flow is that the algorithm can be used to
solve a comletely different problem called **min cut**.

A cut is a set of edges in the graph such that, if we removed them from the
graph, there would be no path from the source to the target: that being said,
**it splits the graph into two disjoint parts, one connected to the source and
the other to the target**. We define the capacity of the cut to be the sum of
the capacities of the edges in the set.

Trivially, the set of all edges is a cut. But the capacity of that set is too
large. We are more intereseted in finding the cut with the minimum capacity,
that is, **the min cut**.

Here (the red edges) is a min cut of the example at the beginning.

{% include image_caption.html imageurl="/images/posts/network-flow-min-cut.svg" %}

The min cut is also 6, which is the max flow of the graph. This is not a
coincidence. In fact, we can prove that for any flow graph, its min cut is equal
to the max flow, even for fractional capacities.

# How to use max flow and min cut

Generally, if we want to use network flow to solve a problem, we first convert
the problem into a flow graph. And then:

1. if the problem asks us to **maximize** some value, then we should use max
   flow;
2. otherwise, if the problem asks us to **minimize** some value, we should
   probably use min cut.

The key to solving problems with network flow is to find the correspondence
between the original problem and a flow graph. Let's look at two examples.

## Example one: chess on board

**Given a MxN board, we are asked to place some chess onto it. There are two
sorts of cells on the board. One is white, where we can place chess, and the
other is gray, where we cannot place chess. We are allowed to place at most one
chess on each row and each column. The question is: how many chess can we place
at most on the board?**

Since the question asks about a maximum value, we should probably think of max
flow. Here is how we build the flow graph.

First we introduce a source and a target. For each row, we create a node that
connects to the source, the capacity of the edge being 1. Then for each column,
we create a node that connects to the target, the capacity of the edge being 1,
too.

Now **if we are allowed to place chess on row i and column j**, we create an
edge from row node i to column node j on the flow graph with capacity one.

Here is an example of the flow graph of a chess board:

{% include image_caption.html imageurl="/images/posts/chess-board-flow-graph.svg" %}

Assume that we have a flow to the graph. If the flow from row i to column j is
one, we place a chess on the intersection of row i and column j. By the flow
constraints, we know that:

1. we can place at most one chess on the white cell;
2. we cannot place chess on the gray cell;
3. we can place at most one chess on each row;
4. we can place at most one chess on each column.

Thus, the flow graph gives us a valid solution to the original problem. And in
reverse, we can show that any valid placement corresponds to a flow on the
graph. Therefore, we can conclude that the max flow is the optimal solution to
the problem.

## Example two: doing homework

**Given M chapters and N problems, each chapter has a time cost that we need to
pay to read it, and each problem has some points that we can get if we solve
it. Each problem is related to some chapters, so that if we want to solve it, we
must read all these chapters. The question is: what is the best benefit we can
achieve (defined as the points we get minus the cost we pay)?**

Instead of maximizing the benefit, we consider minimizing **the total points of
the problems that we don't solve + the cost we pay**. 

By this transformation, we can use min cut to solve it.

The flow graph is relatively straightforward to construct:

- First we create a source and a target;
- Each chapter corresponds to a node that connects to the source, the capacity
  being the cost of reading the chapter;
- Each problem corresponds to a node that connects to the target, the capacity
  being the points of solving it;
- If Problem j requires reading Chapter i, we add an edge from Chapter i to
  Problem j with **infinite** capacity. (You can think the infinite capacity as
  a very large integer.)

Now pay attention to the correspondence between a cut and a solution:

1. Since the cut has a finite capacity, it MUST NOT include any edges in
   between.
2. Each left edge represents that we read that chapter.
3. Each right edge represents that we DON'T solve the problem.

{% include image_caption.html imageurl="/images/posts/network-flow-chapter-problems.svg" %}

The cut above means that we read c1 and c2 and don't solve p2, p3 and p4 (a.k.a
solve p1).

Given a cut, let's prove that reading those chapters and not solving those
problems is a valid solution.

For each problem that we solve, since the edge from the problem to the target is
not included in the cut, the edge from the source to any of the chapters
connected to the problem must be included. Otherwise, we would have a path from
the source to the target and it would not be a cut. That means: we read all the
required chapters. Thus, we can conclude that the solution is valid.

In reverse, for each solution, we construct such an edge set. And now we want to
show that the edge set is actually a cut. How?

For each path from the source to the target, if we solve the problem on the
path, then we must read the chapter on the path. In this case, the edge from the
source to the chapter must be included in this edge set. If we don't solve the
problem, then the edge from the problem to the target must be included in this
edge set, which means, all the paths must go through this edge set. Thus, it is
a cut.

This is how we use min cut to solve problems. Generally, it is very different
from max flow. And constructing flow graph for min cut is usually harder than
max flow. But what is interesting is that both of them can be solved with the
same algorithm.
