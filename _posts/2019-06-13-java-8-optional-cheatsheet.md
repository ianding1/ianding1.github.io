---
layout: post
title: "Java 8 Optional Cheatsheet"
date: 2019-06-12
tags: [java]
banner_image: java-8-optional-cheatsheet.jpg
---

### 1. I have an `A a`, how can I get an `Optional<A>` containing `a`?

```java
Optional.of(a)    // a cannot be null
```

### 2. I have an `A aOrNull` which can be `null`, how can I get an `Optional<A>`?

```java
Optional.ofNullable(aOrNull)
```

**This is extremely useful to convert the traditional nullable reference to an
`Optional` object.**

<!--more-->

### 3. How can I get an empty `Optional<A>`?

```java
Optional.empty()
```

### 4. How can I know if an `Optional<A> maybeA` contains any object?

```java
maybeA.isPresent()    // Returns true if it is not empty
```

This method should be **rarely** used. If you find you use it frequently, see if
you use `if` statements too much (or the notorious `?:` operator). Take a look
at Item 6 and Item 7 for a better approach.

### 5. I have an `Optional<A> maybeA`, how can I get the instance in it?

You have four ways to get it:

```java
maybeA.get()    // Throws NoSuchElementException if empty

maybeA.orElse(anotherObject)    // Returns anotherObject if empty

maybeA.orElseGet(() -> makeAnotherObject())  // Call the function if empty

maybeA.orElseThrow(() -> throw new MyException())   // Throw if empty
```

You usually only need to use them on the boundary of your method.

### 6. I have an `Optional<A> maybeA` and a function `B process(A a)`, how can I get an `Optional<B>`?

```java
maybeA.map(a -> process(a))
```

It means if `maybeA` is empty, return an empty `Optional<B>`. Otherwise, return an
`Optional<B>` containing `process(a)`.

Use `Optional.map` to replace these `if` statements:

```java
// Bad, because we cannot use the final modifier!
Optional<B> maybeB = Optional.empty();   

if (maybeA.isPresent()) {
    A a = maybeA.get();
    B b = process(a);
    maybeB = Optional.of(b);
}
```

```java
// Good
final Optional<B> maybeB = maybeA.map(a -> process(a));
```


### 7. I have an `Optional<A> maybeA` and a function `Optional<B> process(A a)`, how can I get an `Optional<B>`?

```java
maybeA.flatMap(a -> process(a))
```

It means if `maybeA` is empty, return an empty `Optional<B>`. Otherwise, return
`process(a)`.

Use `Optional.flatMap` to replace these `if` statements:

```java
// Bad, because we cannot use the final modifier!
Optional<B> maybeB = Optional.empty();

if (maybeA.isPresent()) {
    A a = maybeA.get();
    maybeB = process(a);
}
```

```java
// Good
final Optional<B> maybeB = maybeA.flatMap(a -> process(a));
```

### 8. I have `Optional<A> maybeA` and `Optional<B> maybeB` and a function `C process(A a, B b)`, how can I get an `Optional<C>`?

```java
maybeA.flatMap(a ->
    maybeB.map(b ->
        process(a, b)))
```

What if the function has three arguments? Easy.

```java
maybeA.flatMap(a ->
    maybeB.flatMap(b ->
        maybeC.map(c ->
            process(a, b, c))))
```

If you have a Haskell background, you must have figured out that I'm just
reinventing the `do` notation in Java.
