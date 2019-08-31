---
layout: post
title: "Bash Programming Tutorial: Variables"
date: 2019-08-30
tags: [bash]
banner_image: bash-programming-tutorial-variables.jpg
---

## Variables

### Define a variable

Variables in Bash are defined with a equal sign:

```bash
var='the value'
```

There is **no space** before and after the equal sign. The reason is simple --
Bash cannot distinguish a variable assignment from a program with arguments if
there are spaces around the equal sign:

```bash
# Does it mean assigning 'nick' to a variable named cat, or
# executing the program /bin/cat with two arguments, namely,
# '=' and 'nick'?
cat = 'nick'
```

### Use a variable

To use a variable, we need to put a dollar sign before the variable:

```bash
name=John
echo "Hello, $name"
```

We can also use braces to surround the variable. It's equivalent to the form
without braces with an exception:

```bash
echo "Hello, ${name}"

# Without braces, the variable becomes $namefoo
echo "Hello, ${name}foo"
```

<!--more-->

We can assign a variable to another:

```bash
name=John
greeting="Hello, ${name}"
```

## Single quotes vs. double quotes

### Quote a string

In the examples above, we sometimes use single quotes, sometimes double quotes,
sometimes without quoting at all.

To explain which quote we should use, we need to know how arguments are
split in a Bash command. Let's look at this example.

Here we use */usr/bin/touch* to create a file named *foo*:

```bash
touch foo
```

If we want to create a file named *foo bar*, we cannot simply use `touch foo
bar`, since it will be interpreted as two separate arguments, *foo* and *bar*.
The reason lying behind is that Bash splits arguments by *space*.

To prevent Bash from treating spaces as delimiters, we need to escape them with
backslashes:

```bash
touch foo\ bar
```

If there are many spaces in the argument, *e.g.* "foo bar   baz", we need to
escape all of them. The result can be really unreadable:

```bash
touch foo\ bar\ \ \ baz
```

Instead, Bash allows us to escape *a range of characters* with single quotes,
treating all the spaces surrounded by the pair of single quotes as ordinary
characters.

```bash
touch 'foo bar   baz'
```

Surprisingly, these single quotation marks can indeed appear anywhere, even in
the middle of arguments, as long as they show up in pairs. This is very
different from other scripting languages such as Python, in which we use single
quotation marks as delimiters of string literals.

```bash
# This is essentially equivalent to
# touch 'foo bar   baz'
touch foo' 'bar'   b'az
```

We can also use double quotes to prevent Bash from splitting the argument.

The difference between single quotes and double quotes is that all the
characters in single quotes are interpreted *literally*, even backslashes.  It
means **there is no way to escape any character in single quotes, even the
single quotation mark itself**.

```bash
# WRONG! Backslashes don't work between single quotes
# touch 'foo\'bar'

# OK: escape single quotation marks outside of the
# single quote
touch 'foo'\''bar'

# OK: use single quotation marks in a double quote
touch 'foo'"'"'bar'
```

### Quote a variable

Variables in single quotes will be interpreted *literally* instead of being
replaced with the value of the variable.

```bash
name=Joe
echo 'Hello, ${name}'
# Prints:
# Hello, ${name}
```

On the other hand, double quotes allow *escaping* and *string interpolations*
(*i.e.* replacing variables with their values).

```bash
# \t will be interpreted as a tab character
echo "A\tB"

# Variables will be replaced with their values.
name=Joe
echo "Hello, ${name}"
# Prints:
# Hello, Joe
```

### Always double-quote variables

When it comes to using variables in a string, the advice is to always
double-quote the variables. Otherwise, the variable might be accidentally
interpreted as two arguments or even omitted.

The way that Bash parses a command is kind of counter-intuitive. It first
replaces references of variables with their values, and then splits arguments.

Due to this peculiar ordering, If a variable contains spaces, then after
replacing the variable with its value, Bash will split the value into two
separate arguments.

Even worse, if the variable is empty (its value is ''), then the argument simply
vanishes, causing all the remaining arguments to shift one position to the left.

```bash
name='foo bar'
touch ${name}
# Will touch two files: "foo" and "bar"
```

To avoid this unhappiness from happening, it's safest to always double-quote
variables.

However, there are cases when variable-interpolation before word-splitting can
be helpful.

By intentionally not quoting a variable, Bash allows us to *unpack* arguments.
It's useful when we want to combine two lists of arguments together, *e.g.* in
compiling. Here is a very common use of argument unpacking:

```bash
CFLAGS='-Wall -Wextra'
LDFLAGS='-lm -lz'
gcc -o foo foo.c ${CFLAGS} ${LDFLAGS}
```
