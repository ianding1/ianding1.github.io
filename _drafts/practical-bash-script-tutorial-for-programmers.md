---
layout: post
title: "Practical Bash Script Tutorial: Introduction"
date: 2019-08-27
tags: [Bash]
banner_image:
---
Bash scripts are commonly used in our daily life, but scarcely do we treat it as
a *real* programming language.

The most common practice might be adding to *PATH* the directory of a
newly-installed program.

Sometimes we might go one step further and put several commonly-executed
commands into a Bash script so that we don't need to type the same commands over
and over again, and that's it.

If we need to do something more complicated, we usually turn to other script
languages like Python.

The idea of avoiding using Bash scripts for complex logics does make some sense,
since Bash scripts are notoriously known for its bizarre syntax.

There are historical reasons why Bash scripts look so cumbersome.

Its syntax is derived from and composed of several various earlier shell
scripts, even borrowed from C. That explains why the syntax of Bash scripts
lacks uniformity.

Some constructs and built-ins were added long after the syntax had been fixed,
so these "new" features must be implemented in a way not conflicting with
existing forms.

The flavor of the syntax is kind of odd nowadays, but actually pretty common in
the 90s. It looks very similar if you compare it with that of Perl and PHP.

But we don't need to know all of Bash scripts in order to use it.

In this tutorial, we've carefully picked a small subset of Bash script
syntaxes that allow us to build up powerful tools consisting of conditional,
loops and pipes. In my opinion, pipes are a feature in which Bash scripts are
still superior than Python even now.

Since it's essentially a *language* tutorial, not a *shell manual*, we
won't get into the details of line-processing programs, *e.g.* **sed**, **awk**,
**grep** and UNIX utilities, *e.g.* **sort**, **uniq**, **cut**.

We've split the tutorial into several parts.

### Introduction

The reason why we learn Bash scripts.

### [Variables][chap1]

1. How to define variables
2. Single quotes *vs.* double quotes, and which we should
   use
3. How to read and print

### [Data Types][chap2]

1. How to define integers, arrays and associated arrays and use them
2. How to do arithmetic operations

### [Conditionals and Loops][chap2]

1. How to use conditionals
2. How to use loops

### [Functions and Subprocesses][chap3]

1. How to define functions and local variables
2. How to spawn a subprocess and what's the different from a function

### [String Manipulations][chap4]

1. How to do pattern matching
2. How to trim strings

### [Redirections and Pipes][chap5]

1. How to redirect *stdin*, *stdout*, and *stderr*
2. How to connect various programs through *pipes* and make them work together

[chap1]: #
[chap2]: #
[chap3]: #
[chap4]: #
[chap5]: $
