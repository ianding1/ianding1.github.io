---
layout: post
title: "Multi-file Search and Replace in Vim"
date: 2019-08-22
tags: [vim]
banner_image: multi-file-search-and-replace-in-vim.jpg
---

**Ferret** is a Vim multi-file search plugin. Compared to ack.vim, ferret
asynchronously does the search job. It also has several improvements in
integrating with quickfix windows, allowing for easier multi-file substitutions.

Installing ferret is easy. In vim-plugged, put the following line in the vimrc
file to install it:

```vim
Plug 'wincent/ferret'
```

Ferret uses **ripgrep**, **ag** or **ack** in the background. Make sure you have
any of them installed in your system.

### Settings

Default ferret mappings are not very easy to remember. Instead, I setup my own
key mappings in vimrc, resembling Vim's own searching commands like **\*** and
**/**:

<!--more-->

```vim
" Don't bind ferret commands.
let g:FerretMap = 0

" Don't hide cursor line in quickfix.
let g:FerretQFOptions = 0

" Bind our own Ferret commands.
nmap <leader>/ <Plug>(FerretAck)
nmap <leader>* <Plug>(FerretAckWord)
```

### How to search

```vim
:Ack [0-9]{1,3}
```

1. The pattern is parsed as if `\v` is given (i.e. *very magic*).
2. The only character needed to be escaped in the pattern is **whitespaces**,
   e.g.  `:Ack my\ keyword`

### How to replace

The search result is inserted into the quickfix window.

To replace all the occurrences, execute:

```vim
:Acks /\v[0-9]{1,3}/foo/g
```

In contrast to `:Ack`, the argument of `:Acks` is passed to `:s` **literally**.
It means `\v` is not given by default.

If you only want to replace some of the occurrences, use `dd` to delete the
lines that you don't want to substitute.
