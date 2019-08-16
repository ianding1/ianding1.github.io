---
layout: post
title: "Don't Overuse hjkl in Vim"
date: 2019-08-16
tags: [vim]
banner_image: dont-overuse-hjkl-in-vim.jpg
---

**hjkl** is a remarkable improvement over arrow keys, since they keep your
fingers in the home row. However, overusing them could be another hindrance to
an efficient use of Vim, for they only move by a character at a time, whereas
Vim provides many efficient motions that allows you to move faster.

### Go to a line

If you find yourself pressing **jjjj** or **kkkk** all the time, then you
probably should check out **\<line\>gg** (e.g. go to the 12nd line with
**12gg**).

**\<line\>G** is equivalent to **\<line\>gg**, but I find it much easier to
press g twice than holding the shift key.

### Word-based motions

Instead of holding **h** or **l**, you can use **w** and **b**; **w** moves
forward to the start of next word, and **b** moves backward. There is another
similar command **e** that moves forward to *end* of next word.

If there are too many punctuations in the line under cursor, then you might
find **w** and **b** a little annoying, since each punctuation is regarded as an
individual *word* (due to the definition that a word is a sequence of
alphabetic and digital characters, check out `:h iskeyword`).

<!--more-->

Most of the time, I find **W**, **B** and **E** more convenient than their
lowercase friends, because they regard a word as a sequence of characters
separated by *spaces*. Thus the way they move is more predictable.

### Find next character

**f\<char\>** and **F\<char\>** jump forward/backward to the next occurrence of
**\<char\>** in the current line. They are very convenient if you want to jump
between parentheses and brackets, e.g. with **f)** or **F[**.

After using **f\<char\>** and **F\<char\>**, you can use **;** and **,** to jump
forward/backward to the same character, just like how **n** and **N** work after
searching with **/**.

Another slightly different command is **t\<char\>**; it jumps to the character
*before* **\<char\>**.

A good use of **t\<char\>** is to combine it with **y**, **c**, **d**, e.g.
using **ct)** to delete all the characters before the next **)** and enter the
insert mode.

I mostly use **f** to jump to punctuations instead of letters, for it is much
easier for our eyes to distinguish punctuations from a sentence than a letter.
If you don't believe me, just try to find the previous **n** in this paragraph
and then try dot "." instead.

### Keyword searching

One of the most overlooked command in Vim is **\***; it jumps to the next
occurrence of the keyword under cursor.

After initiating a search with **\***, you can jump between all the occurrences
with **n** and **N**.

**\*** can be very efficient for jumping between different uses of a keyword in
a buffer.

It also has a companion that searches backward: **g\***.

### Should I use easymotion?

Easymotion is a very creative plugin that presents a brand new way to motion.
First you initiate a search, and then jump to the position within one or two
more keys.

However, it has some drawbacks in practice.

If you have an on-the-fly syntax checker installed in Vim, then it might mess up
with the syntax checker because it temporarily changes the content of the
buffer.

Another problem is that it lacks *predictability* -- you don't know which key to
press until the moment it prompts you. This could be a problem for muscle
memory, since it requires additional visual--muscular coordination.

Nevertheless, it's a good plugin worth a try. You can decide whether to keep it
in your Vim configuration after trying by yourself.
