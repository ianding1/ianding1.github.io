---
layout: post
title: "Use Emacs as Your Terminal"
date: 2018-10-18
banner_image: use-emacs-as-your-terminal.jpg
tags: [emacs]
---

If there is anything that Emacs can do but Vim can't, eshell must be one of them. What eshell distinguishes itself from an external terminal is that it is so deeply integrated into Emacs that you can do many things otherwise difficult. As a gentle start, all that you need to do is to run this command:

{% highlight bash %}
M-x eshell
{% endhighlight %}

If you are new to eshell, be sure to check the following features that make eshell worth a trial:

- You can run Emacs command directly; e.g. opening a file by `find-file`.
{% highlight bash %}
find-file foo.txt
{% endhighlight %}
- You can redirect the output to an Emacs buffer; e.g. redirecting the output of `grep` to a buffer called "result".
{% highlight bash %}
grep -R foo > #<buffer result>
{% endhighlight %}
- You can press `Up` or `M-p` to retrieve the last command. If you have already entered some characters, it will search for the latest command with that given prefix.
- You can press `Tab` to trigger the auto completion.
- You can define aliases (`$*` means zero or more arguments).
{% highlight bash %}
alias ll 'ls -l $\*'
alias la 'ls -al $\*'
{% endhighlight %}
- You can undefine an alias by not giving the second part.
{% highlight bash %}
alias ll
{% endhighlight %}
- The alias will be stored permanently in file.

But before you start venturing into eshell, you have to know what it **cannot** do. Most importantly, **eshell is not a real terminal**.

Unlike Vim8, which spawns an internal terminal in the background, eshell is written purely in Emacs Lisp. 

If the program you run in eshell wants to do some fancy stuff, it is likely to fail. For example, **top** is one of the programs that you cannot run in eshell. Nor can you use **ssh** . 

Many users who want to run `git` in eshell will see the error message saying *the terminal is not fully functional*. Although it is always encouraged to use the unprecedented [Magit](https://magit.vc), you may just want to do some simple stuff with git in eshell, in which case you should run `git --no-pager ...` instead. 

Alternatively, you can define an alias to save your figures.

{% highlight bash %}
alias git 'git --no-pager $*'
{% endhighlight %}

To start an internal terminal in Emacs, you should use `M-x term`. If you find your program does not work even in term, it is time that you should use a real terminal. Emacs is not almighty after all. 

In order to save your time potentially, I should tell you that I never succeed in running the fully functioning Vim in Emacs :-) So don't waste your time on it.

Nevertheless, eshell covers 80% of my demands on shell, which makes it worth learning.
