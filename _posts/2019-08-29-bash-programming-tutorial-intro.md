---
layout: post
title: "Bash Programming Tutorial: Introduction"
date: 2019-08-29
tags: [bash]
banner_image: bash-programming-tutorial-intro.png
---

### Overlooked Bash

Bash is commonly used in our daily life, but scarcely do we treat it as
an interpreter of a programming language, the Bash language.

The most frequently-used bash script might be *~/.bashrc*. We edit it every
time we want to add to *PATH* the directory of a newly-installed program.

Sometimes we might go one step further and put several repetitively-used
commands into a Bash script so that we don't need to type the same commands over
and over again, and that's it.

If we need to do something more complicated, we usually turn to other script
languages like Python.

But Bash can do more than that. Let's look at an example of using Bash for data
processing.

### Example: counting occurrences

Given a text file *orders.txt*, we want to count the number of occurrences of
each customer name in the file.

```text
# ORDER-ID   CUSTOMER TIMESTAMP             PRODUCT  QUANTITY
1058531610   john     2019-07-26T14:31:51Z  10VANEF  1
2017504121   thomas   2019-07-26T15:14:23Z  AN47SAM  3
1756102147   john     2019-07-26T15:23:42Z  B9QN3QQ  2
5917191328   dave     2019-07-26T15:29:36Z  89B6ZJK  6
```

<!--more-->

The Bash command that does this job is:

```bash
cat orders.txt | grep -v '#' | tr -s ' ' | cut -f 2 -d ' ' | sort | uniq -c
```

The output of the command is:

```text
   1 dave
   2 john
   1 thomas
```

The command might look cryptic at first sight, but let's break it into multiple
lines to improve readability and explain what each program does line by line.

```bash
# read orders.txt and feed it into the next program
cat orders.txt  | \
# remove all the lines starting with "#"
grep -v '^#'    | \
# replace repeated spaces with one space
tr -s ' '       | \
# select the second column (i.e. the customer names);
# columns are separated by one space character
cut -f 2 -d ' ' | \
# sort lines alphabetically
sort            | \
# count occurrences of each unique line
uniq -c
```

As is demonstrated above, when programming in Bash, we hardly do the *real* job
by ourselves, such as sorting an array using *quicksort*. Instead, we combine
various existing tools together and use the Bash language as the *glue*. That's
where the magic of Bash programming comes from -- building up complex tools from
simple ones.

### Bizarre syntax

Scripting in Bash is hard, since the Bash language is notoriously known for
its bizarre syntax.

There are historical reasons why Bash look so cumbersome.

Its syntax is derived from and composed of several various earlier shells, even
borrowed from C. That explains why the syntax of Bash scripts lacks uniformity.

Some constructs and built-ins were added long after the syntax had been fixed,
so these "new" features must be implemented in a way not conflicting with
existing forms.

The flavor of the syntax is kind of odd nowadays, but actually pretty common in
the 90s. It looks very similar if you compare it with that of Perl and PHP.

### Our approach

The good news is that we don't need to know all of the Bash language in order to
use it.

In this tutorial, we've carefully picked a small subset of Bash syntaxes that
allow us to build up powerful tools consisting of conditional, loops and pipes.

Since it's essentially a *language* tutorial, not a *shell manual*, we
won't get into the details of text-processing tools, *e.g.* **sed**, **awk**,
**grep** and UNIX utilities, *e.g.* **sort**, **uniq**, **cut**.

We titled the tutorial as Bash *Programming* Tutorial because we want to
talk about how to use Bash in the perspective of a programmer instead of a
shell user. A programmer cares about how to define variables, conditionals,
loops, functions and how to handle errors. That's the center of this tutorial.

The tutorial is split into several parts.

- **Introduction** the reason why we learn the Bash language
- **[Variables][var]** variables, single quotes *vs.* double quotes
- **Integers and Arrays (WIP)** integers, arrays, arithmetic operations
- **Conditionals and Loops (WIP)** *if*, *case*, *for*, *while* statements
- **Reading from Users (WIP)** reading from the keyboard, command line
  arguments
- **Functions and Subprocesses (WIP)** functions, local variables,
  subprocesses
- **String Manipulations (WIP)** pattern matching, string trimming
- **Redirections and Pipes (WIP)** *stdin*/*stdout* redirection, pipes,
  composition of programs

[var]: {% post_url 2019-08-30-bash-programming-tutorial-variables %}
