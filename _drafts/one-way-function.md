---
layout: post
title: "One Way Function"
banner_image:
tags: [cryptography]
---

The one-way function is one of the most fundamental concept in cryptography. It is the basis of the construction of other crypographic algorithms.

Informally, if $f$ is a one-way function, then it's easy to compute $f(x)$ from $x$, but it's hard to guess $x$ from $f(x)$.

### Formal Definition

The formal definition is that:

**\\(f:D\to R\\) is a one-way function (OWF) if, for any *probabilistic polynomial time* (PPT) adversary \\(A\\), and for any \\(x\\) uniformly randomly sampled from \\(D\\), the probability that \\(f(A(y))=y\\) is *negligible*, where \\(y=f(x)\\).**

The definition can be written in the math language as: For all PPT \\(A\\),
\\[Pr[x\xleftarrow{$}D, y=f(x), x'=A(y): f(x')=f(x)] \le negl(n)\\]

The **adversary** is an algorithm that aims at inverting the one-way function. It can be **probabilistic** (i.e. not deterministic). But the running time must be bound to polynomial time. We demand the one-way function not to be secure against *some* adversaries, but *all* adversaries.

<!--more-->

Why must the computation power of the adversary be bound to **polynomial time**?

If the advesary has unbound computation power, then it can easily invert any one-way function by enumerating all the values in the domain and testing if the result is the same as the given \\(y\\).

**Negligible** means that the success probability must be asymptotically smaller than \\(\frac{1}{p(n)}\\) where \\(p\\) is any polynomial function and \\(n\\) is the *security parameter*. Another way to say it is that the reciprocal must grow faster than any polynomial function.

The **security parameter** determines how secure the algorithm is. For example, if the domain is \\({\\{0,1\\}}^n\\), then the security parameter is \\(n\\). The larger \\(n\\) is, the harder inverting \\(f\\) is.

Here are some negligible functions: \\(\frac{1}{2^n}\\), \\(\frac{1}{1.0001^n}\\).

From the definition of one-way function, we know that **for any PPT adversary, we can always make it almost impossible to invert the one-way function by increasing $n$ to a large enough number**.

The condition that decides if the adversary succeeds is $f(A(y))=y$, which means the adversary succeeds as long as it finds a pre-image $x'$ such that $f(x')=f(x)$. The pre-image $x'$ can be different from the original $x$.

The reason why we don't demand $A$ to find the exact $x$ is because we want to rule out those trivially "one-way" functions such as $f(x)=0$. They are "perfectly one-way" but not useful.

### Information Leaking

The definition of one-way function says **nothing about information leaking**. In fact, we can construct a one-way function that leaks half of the pre-image yet still secure.

Here is an information-leaking OWF:

**Given some secure one-way function $f$, we can construct $g(x)=(f(x_1),x_2)$ where $x_1$ is the first half of $x$ and $x_2$ the second half.**

It always leaks the second half, but it is secure by definition.

### 1-1 One-way Function

If the one-way function is *injective* (if $f(x_1)=f(x_2)$, then $x_1=x_2$), then we say it is an injective one-way function, or more commonly, **1-1 one-way function**.

We can construct 1-1 one-way functions from a known one-way function by appending more information to the image.

Assuming we want to construct 1-1 OWF $g$ from a known OWF $f$, the construction usually looks like $g(x)=(f(x),signal(x))$, where $signal(x)$ is a function that generates a **signal string** from $x$, whose purpose is to ensure there is no other pre-image producing the same image. The signal string usually *leaks some information of x*.

### Construction From Factoring

We can construct a OWF from the *factoring* problem.

The **factoring** problem says, given the product $pq$ of two primes $p$ and $q$, it is hard to compute $p$ and $q$.

So the domain of our OWF is $D=\\{(p,q) \| p, q \in P\\}$ where $P$ is the set of $n$-bit prime numbers. The range is $R=\\{pq \| p, q \in P\\}$.

Let $f(p,q)=pq$.

By the factoring assumption, we know $f$ is indeed one-way.

However, $f$ is not injective, since $f(p,q)=f(q,p)$.

To make it a 1-1 OWF, we let $f(p,q)=(pq,I_{p<q})$ where $I_{p<q}$ is 1 if $p<q$, 0 otherwise.

Observe that $I_{p<q}$ leaks some information about the pre-image (i.e. which one is larger), but the information is insufficient for an adversary to invert the function.

### General Construction Possible?

We can construct one-way functions from *some* assumptions, but can we construct a one-way function from no assumptions? This is still an open question. But it might still remain open for a long time, because we have shown that **if $P=NP$, then there exists no one-way function**. That being said, if we constructed a one-way function from nowhere, we would essentially prove that $P\not=NP$.
