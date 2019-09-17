---
layout: post
title: "Bash Programming Tutorial"
date: 2019-08-30
tags: [bash]
banner_image: bash-programming-tutorial-intro.png
---

{::options toc_levels="1,2" /}

- Table of content
{:toc}

## Variables

### Define variables

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

If there are many spaces in the argument, *e.g.* "foo bar baz", we need to
escape all of them. The result can be really unreadable:

```bash
touch foo\ bar\ baz
```

Instead, Bash allows us to escape *a range of characters* with single quotes,
treating all the spaces surrounded by the pair of single quotes as ordinary
characters.

```bash
touch 'foo bar baz'
```

Surprisingly, these single quotation marks can indeed appear anywhere, even in
the middle of arguments, as long as they show up in pairs. This is very
different from other scripting languages such as Python, in which we use single
quotation marks as delimiters of string literals.

```bash
# This is essentially equivalent to
# touch 'foo bar baz'
touch foo' 'bar' b'az
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

<!--more-->

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

## Conditionals

### Truth values of exit codes

All processes terminate with an exit code. In Bash, the exit code of the last
command is written to the special variable `$?`.

But very counter-intuitively, when dealing with exit codes, Bash treats **0**
as true and all **non-zero** values as false. This makes sense in this
particular scenario, since we can use different non-zero values to represent
different failure reasons. But we must keep in mind that it's contrary to how it
deal with integers as booleans in arithmetic operations, *i.e.* between `((` and
`))`.

### &&, || and !

In a programming language that supports primitive boolean values, `&&` is
usually the logical-AND operator and `||` logical-OR. But Bash is slightly
different from it, since it doesn't have built-in boolean values. Instead of
returning either 0 or 1, it returns one of the exit codes of the two commands.

`CMD1 && CMD2` first executes *CMD1*. If the exit code of
*CMD1* is non-zero (*i.e.* false), then it returns that value immediately
without executing *CMD2*. Otherwise, it executes *CMD2* and returns its exit
code.

*e.g.* Execute `apt update` if *apt* is installed (`command -v PROG` is used to
test if *PROG* can be found in regard to **PATH**).

```bash
command -v apt > /dev/null && apt update
```

`CMD1 || CMD2` first executes *CMD1*. If the exit code of *CMD1* is zero (*i.e.*
true), then it returns 0 immediately without executing *CMD2*. Otherwise, it
executes *CMD2* and returns its exit code.

*e.g.* Create *~/.cache* if the directory does not exist (the `[[` command will
be explained later):

```bash
[[ -d "~/.cache" ]] || mkdir ~/.cache
```

In practice, we usually use `CMD1 && CMD2` to represent executing *CMD2* only if
*CMD1* succeeds, and `CMD1 || CMD2` executing *CMD2* only if *CMD1* fails.

`!CMD` is used to flip the zero exit code to 1 and all non-zero exit codes to
0.

### The *if* statement

The form of *if* statements is:

```bash
if TEST ; then
  COMMANDS
elif TEST ; then
  COMMANDS
else
  COMMANDS
fi
```

The *elif* and *else* clauses are optional.

We can use any commands in the place of *TEST*. But we need to remember that
Bash treats zero exit code as true and all non-zero exit codes as false.

We are also allowed to use arithmetic expressions here, such as `(( val > 3 ))`,
but we need to keep in mind that if the *value* of the parethesized expression
is non-zero, the *exit code* of the command will be 0 (both representing *true*
in their own contexts), and vice versa.

### The `[[` command

A very useful command that can be used as a test condition is `[[`, the
*extended test command*.

Here are some judgements that `[[` supports:

```bash
# string equal
[[ "$str1" = "$str2" ]]

# string not equal
[[ "$str1" != "$str2" ]]

# string less-than alphabetically
[[ "$str1" < "$str2" ]]

# string greater-than alphabetically
[[ "$str1" > "$str2" ]]

# integer equal
[[ "$num1" -eq "$num2" ]]

# integer not equal
[[ "$num1" -ne "$num2" ]]

# integer less-than
[[ "$num1" -lt "$num2" ]]

# integer less-than-or-equal-to
[[ "$num1" -le "$num2" ]]

# integer greater-than
[[ "$num1" -gt "$num2" ]]

# integer greater-than-or-equal-to
[[ "$num1" -ge "$num2" ]]

# string is empty
[[ -z "$str" ]]

# string not empty
[[ -n "$str" ]]

# regular file exists
[[ -f "$filepath" ]]

# directory exists
[[ -d "$dirpath" ]]

# file exists and readable
[[ -r "$filepath" ]]

# file exists and writable
[[ -w "$filepath" ]]

# file exists and executable
[[ -x "$filepath" ]]

# compound tests
[[ "$str1" > "$str2" && -z "$filepath" ]]
[[ "$str1" > "$str2" || -z "$filepath" ]]
[[ ! "$str1" > "$str2" ]]
[[ ("$str1" > "$str2" || -z "$filepath") && (-d "$dirpath") ]]
```

The complete supported tests can be found [here][bash-cond-expr].

Strangely, `[[` only supports string less-than and greater-than, but not
no-less-than or no-greater-than.

Here is an example that first test if *~/.bashrc* exists, and if so, execute the
commands in the file:

```bash
if [[ -f "~/.bashrc" ]] ; then
  source ~/.bashrc
fi

# A more concise form as a one-line command
[[ -f "~/.bashrc" ]] && source ~/.bashrc
```

### The *case* statement

The syntax of *case* is:

```bash
case "$value" in
  PATTERN)
    COMMANDS
    ;;
  PATTERN1 | PATTERN2)  # Matches either pattern
    COMMANDS
    ;;
esac
```

A pattern is a string that contains some special characters, for example:

- `*` matches any string.
- `?` matches any single character.
- `[...]` matches any single character between the brackets.

*e.g.* Match any string that starts with *--mypath=* with `--mypath=*`.

A full description can be found [here][bash-pat-match].

## Loops

### The *for* loop

The *for* loop takes a list of arguments and executes the loop body by
assigning each of the arguments to the loop variable. The interpretation of the
arguments follows the general rule of parsing command arguments, first
interpolating variables and then splitting words.

The syntax of the *for* loop is:

```bash
for var in ARG1 ARG2 .. ; do
  COMMANDS
done
```

For example, if we want to iterate a list of words:

```bash
words='apple banana strawberry'
for fruit in $words ; do
  echo $fruit
done
```

We can also iterate a range of integers using the *range* construct:

```bash
# Prints 0 1 .. 9
for i in {0..9} ; do
  echo $i
done
```

The *range* construct doesn't support using variables in it; it means something
such as `{0..${end}}` doesn't work. We can use the C-like *for* loop to do this
job:

```bash
end=10
# Prints 0 1 .. 9
for ((i = 0; i < end; i++)) ; do
  echo $i
done
```

The dollar sign is optional for variables occurring between `((` and `))`.

### The *while* loop

The *while* loop takes a testing command, executing the loop body as long as the
test command exits with zero.

```bash
while TEST ; do
done
```

We can also use arithmetic expressions as test commands, but we need to notice
what it means for the expression to *exit* with zero.

```bash
i=0
while ((i < 10)) ; do
  echo $i
  ((i = i + 1))
done
```

## Command line arguments

The first argument passed to a bash script is in the variable `$1`, the second
in `$2`, and so on.

The entire list of arguments can be accessed via `$@` and `$*`. To recap what we
have learned in the section of arrays:

1. `$@` and `$*` respects the general rule of argument parsing, first string
   interpolation and then word-splitting.
2. `"$@"` treats each element as an individual arguments, equivalent to `"$1"
   "$2" ..`
3. `"$*"` treats the whole array as an argument, equivalent to `"$1 $2 .."`

We can use `$#` to get the length of the argument list.

The `shift [N]` command is useful in parsing command line arguments. It removes
the first N arguments from the list and moves all other arguments ahead. In the
example below, we use a *while* loop to iterate the arguments and use a *case*
statement to do pattern matching on each argument.

```bash
USAGE='myprog --help --verbose --file [file]'

while (("$#")) ; do
  case $1 in
    --help|-h)
      echo "$USAGE"
      exit 1
      ;;
    --verbose|-v)
      verbose=1
      shift   # N is 1 when omitted
      ;;
    --file|-f)
      file=$2
      shift 2
      ;;
    *)
      echo "Unrecognized option: $1"
      exit 1
      ;;
  esac
done
```

## Reading from the user

The built-in command to read from the user is `read`.

### Read a line

```bash
read varname
```

Read a line from standard input and store it in variable *varname*. The
newline character is not saved in *varname*.

### Display prompts

```bash
read -p "Enter your name: " username
```

Display the prompt and then read a line from standard input.

### Read passwords without echoing

```bash
read -s password
```

Read a line without echoing. It can be used to read passwords from the user.

### Read into multiple variables

```bash
read name gender
```

If the input is `Thomas Male`, then after reading the input, *name* will be
`Thomas` and *gender* will be `Male`.

The rule is that the input string is split into words with **IFS** (which is
whitespaces and tabs by default), assigning each word to each variable in order,
and assigning the rest to the last variable.

Backslashes can be used to escape IFS characters, *e.g.*, `foo\ bar` is
considered as a word.

### Read into an array

```
read -a arrayname
```

Read a line and store it as an array. If the input is `foo bar`, then the array
will contains two elements, one is `foo` and the other `bar`.

### Process line by line

```bash
while read line ; do
  echo "$line"
done
```

Read line by line from standard input until reaching end of file or the user
presses `Ctrl-D`.

### Read from redirected input

```bash
cat orders.txt | while read customer product ; do
  echo "$customer purchased $product"
done
```

Process *orders.txt* line by line. standard input can be redirected to the
output of another command.

## Functions

Functions are like embedded scripts in Bash scripts, but not exactly, since
functions are run in the same process (compared to subprocesses, which are run
in a separate process).

The example below defines a function called *compress* that runs the **tar**
command to compress files and directories.

```bash
compress () {
  local target=$1
  local source=$2
  tar -cjvf "${target}.tar.bz2" "${source}"
}
```

Local variables in a function should be declared with the **local** keyword. If
the variable is not declared with **local**, it will be treated as a global
variable. Assigning to a variable not declared with **local** might overwrite
the value of a global variable with the same name.

The function body can access function arguments in the same way that the script
access command-line arguments, *e.g.*, via `$1`, `$2` and `$@`.

A function is also invoked in the same manner as a command. For example, to
  compress directory *foo* into *foobar.tar.bz2*:

```bash
compress foobar foo
```

standard input and output of a function can be redirected as well. The
following example redirects the output of the function to a file.

```bash
get_password () {
  local result
  read -s -p "Password: " result
  echo "$result"
}

get_password > password.txt
```

Functions can have return values. The return value can be used in the *if*
statement, for example:

```bash
trivial () {
  return 0
}

if trivial ; then
  echo "It's trivially true"
fi
```

## Subprocesses

Instead of running commands in the current process, we can run some commands in
a separate subprocess. The way we run commands in a separate process is to
surround the commands between `(` and `)`, for example:

```bash
# The cd command doesn't change the working directory of the parent process.
(cd foo ; make)
```

There are several reason why we want to run commands in a subprocess:

1. What happens in the subprocess won't affect the parent process. In the
   example above, the change of the working directory only has an influence on
   the command in the subprocess itself, *i.e.*, the **make** command.
2. If the subprocess exits prematurely, it won't terminate the parent process.
3. We can capture the output of the subprocess into a variable. See the example
   below that captures the output of **ls -al** and saves it into variable
   *res*:

```bash
res=$(ls -al)
```

## Environment Variables

All Bash variables are not environment variables.

If we only define a Bash variable `MY_ENV=3` without exporting it, it won't be
passed down to subprocesses.

To make a Bash variable an environment variable, we need to **export** it at
least once.

Although it's common to assign an environment variable while exporting it, doing
so is not necessary.

```bash
# Approach 1
export MY_ENV=3

# Equivalent Approach 2
MY_ENV=3
export MY_ENV
```

If we want to specify an environment variable for only one command, we can embed
the assignment of the environment variable in that command. For example:

```bash
NODE_ENV=test node app.js
```

## Redirections

There are three standard files opened at the start of every command: *standard
input*, *standard output* and *standard error*, corresponding to file descriptor
0, 1, and 2.

By default, standard input is the keyboard, and standard output/error is the
screen. But we can redirect them to disk files, named pipes, and even other
processes via pipes.

### Redirect standard input

```bash
mycmd < input.txt
```

Redirect standard input to *input.txt*.

### Redirect standard output

```bash
mycmd > output.log
```

Redirect standard output to *output.log*. If the file exists, clear the
content of the file first.

### Appending to a file

```bash
mycmd >> output.log
```

Redirect standard output to *output.log*, appending to the file.

### Redirect standard error

```bash
mycmd 2> error.log
```

Redirect standard error to *error.log*.

### Redirect standard error to standard output

```bash
mycmd 2>&1
```

Redirect standard error to standard output.

## Pipes

Besides redirecting standard input/output to disk files, Bash also supports
redirecting standard output of a command to standard input of another via the
pipe operator `|`. This allows us to connect multiple simple commands together
to do complex jobs.

The following example prints the lines containing "ERR" in file *myprog.log* and
saves the result to another file *errors.txt*:

```bash
cat myprog.log | grep "ERR" > errors.txt
```

The exit code of the whole pipeline is the exit code of the last command. This
has the problem that even if an intermediate command fails, the whole pipeline
is still regarded as being executed successfully.

To make our Bash script less prone to mistakes, we can have the whole pipeline
fail if any of the commands fails by adding the line below to our script:

```bash
set -o pipefail
```

[Writing Safe Shell Scripts][safe-shell] introduces many practical advices that
avoid potential errors in Bash programming.

[bash-cond-expr]: https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html
[bash-pat-match]: https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html
[safe-shell]: https://sipb.mit.edu/doc/safe-shell/
