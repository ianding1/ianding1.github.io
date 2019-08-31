---
layout: post
title: "Bash Scripting Tutorial for Programmers: Integers and Arrays"
date: 2019-08-29
tags: [bash]
banner_image:
---

## Integers

Bash is an untyped language. It means variables are not bound to any specific
types. The type of variables is dependent on the context where it is used. If a
string is needed, the variable will be interpreted as a string. But if an
integer is needed, it will be interpreted as an integer instead.

What is different from other languages is how Bash represents numbers in other
scales. Instead of using prefixes such as **0x** or suffixes such as **h**, it
uses a prefix in the form of **radix#**, for example:

```bash
# Binary
b='2#100010'
# Octal
c='8#17'
# Hexadecimal
d='16#5A'
```

To distinguish from ordinary commands, arithmetic operations are surrounded by
`((` and `))`.

If we want to use the value of the arithmetic expression like using a variable,
we need to surround the expression with `$((` and `))`.

The syntax within the parentheses is C-like, and when using a variable, the
dollar sign before the variable is optional:

```bash
a=((16#a))     # After: a=10
((b = a + 4))  # After: b=14
((a++))        # After: a=11
c=$((a - b))   # After: c=-3
d=$((c += 3))  # After: c=0 d=0
```

The difference between `((expr))` and `$((expr))` is that `((expr))` is like a
command. It can be used wherever a command is needed. While `$((expr))` is like
using a variable. The result of the expression is used where the expression
occurs.

```bash
echo "$((3 + 5))"           # Prints 8
echo "$((3 > 2 && 5 < 10))" # Prints 1
```

In *arithmetic operations*, Bash treats zero as *false* and non-zero values as
*true*, following the convention of C. However, when handling the *exit code* of
commands, it treats **zero** as *success* (*i.e.* true) and all **non-zero**
values as *failure* (*i.e.* false). So we must be aware of the occasion where
the boolean operation is used.

## Arrays

### Create arrays

Arrays are defined as a list of words between `(` and `)`.

```bash
names=(john kavin dave)
```

We can also implicitly define an array by assigning values to its indices.

```bash
array[0]=foo
array[3]=bar
# Creates an array of two elements.
```

Arrays in Bash can have holes between indices.

### Access elements of arrays

Curly braces are required to access an element in an array, *e.g.* `${array[0]}`.

```bash
array=(1 3 10)
array[0]=foo
echo "${array[0]} ${array[1]}"
# Prints:
# foo 3
```

If the index to be accessed does not exist, Bash will return an empty string
instead.

### Get the length of arrays

The length of an array can be obtained through `${#array[@]}`.

```bash
array=(3 10 2 6)
echo "${#array[@]}"
```

### Access the whole array

There are cases when we want to access the array as a whole, *e.g.*,

1. Accessing each element in a loop;
2. Passing the array as an argument or a list of arguments to a program.

Bash provides two slightly different forms to refer to the whole array:
`${array[@]}` and `${array[*]}`. Either of them can be used with or without
double quotes. So there are in total four different forms to access the whole
array. Their effects are different.

`${array[@]}` and `${array[*]}` behave in the same way, first interpolating the
value of the array into where it is used and then do *word-splitting*. If an
element contains spaces, it will be split into multiple arguments.

`"${array[@]}"` treats each element of the array as a separate argument. In
contrary to the previous case, the argument containing spaces will still be
regarded as one argument.

`"${array[*]}"` converts the whole array into a string. It's like doing the
*join* operation on the array that many scripting languages support.

```bash
# An array
array=('foo bar' baz)

# Creates "foo", "bar" and "baz"
touch ${array[@]}
touch ${array[*]}

# Creates "foo bar" and "baz"
touch "${array[@]}"

# Creates "foo bar baz"
touch "${array[*]}"
```

### Arrays are also untyped

We already know Bash variables are untyped. It means arrays can be used like
strings, and strings can also be used like arrays, but the result may not be
what we desired.

If we have an array variable `myarray`, using it as a string such as `$myarray`
returns the **first** element of the array, equivalent to `${myarray[0]}`. It is
almost always a fault to use arrays in this way.

If we have a string variable `mystr`, using it as an array has the effect of
operating on an array containing only one argument, the string itself. Thus,
`${mystr[0]}` returns the string itself and `${#mystr[@]}` returns 1.

More array operations can be found in [Advanced Bash-Scripting
Guide: Arrays][array-doc].

[array-doc]: https://www.tldp.org/LDP/abs/html/arrays.html
