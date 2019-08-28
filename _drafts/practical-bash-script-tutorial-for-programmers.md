---
layout: post
title: "Practical Bash Script Tutorial for Programmers"
date: 2019-08-27
tags: [bash]
banner_image:
---

Many of us must have already had experience in bash scripts. The most common
practice might be adding the root directory of a newly-installed program to
**PATH**.

Sometimes we might go one step further and put several commonly-executed
commands into a bash script so that we don't need to type the same commands over
and over again, and that's it.

If we need to do more complicated things, we might turn to other languages like
Python. Scarcely do we treat bash scripts as a *real* programming language.

The idea of avoiding using bash scripts for complex logics does make some sense,
for Bash scripts are notoriously known for its bizarre syntax.

There are historical reasons why bash scripts look so cumbersome. Its syntax is
derived from and composed of several various earlier shell scripts, even
programming languages like C; that explains why the syntax of bash scripts lacks
uniformity. Some constructs and built-ins were added long after the syntax had
been fixed, so these "new" features must not conflict with existing forms; the
flavor of the syntax is kind of odd nowadays, but actually pretty common in the
90s (it makes more sense if you compare it with that of Perl and PHP).

But we don't need to know all the peculiarities of bash scripts in order to use
it.
