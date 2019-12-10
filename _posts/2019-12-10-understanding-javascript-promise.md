---
layout: post
title: "Understanding JavaScript Promise"
banner_image:
tags: [javascript,pl]
---

We know that in JavaScript we have three ways to write asynchronous programs: the callback style, using promises and async/await.

It takes me a long time to figure out what's the relationship between them. The truth is kind of surprising: **they are much more similar than they look like**. I would like to show you how they are related in this post.

Let's start from the traditional callback style.

In the callback style, an asynchronous function takes an additional argument -- the callback. The callback is not invoked until the operation is complete.

The callback is a function, but it's slightly different from how we normally use functions.

When we call a normal function, we care about what it returns, since we're going to use that value in the rest of the program.

But as for the callbacks, we never care about their return values. And most of the time we just return immediately after the asynchronous function returns. Here the callback *itself* represents **the rest of the program**.

<!--more-->

Let's compare it with the *synchronous* programming style. In a language with only blocking I/O, we wait for the operation to complete and then do the rest of work. The stack records where we were so that we can continue from there.

But in the **asynchronous** programming style, the stack doesn't record the rest of the program any longer. Instead, the rest of the program is *explicitly* captured by the callback.

Therefore, we call the callback **continuation**, which is nothing but a synonym for *the rest of the program*.

Since we pass continuations to functions as arguments, this style is also called **continuation-passing style**.

Though JavaScript is a dynamic language, for the purpose of this post, let's assume they are typed. And for the sake of simplicity, we will also omit the error argument in all asynchronous functions so that their types look more concise.

Now let's look at some simplified asynchronous functions and their supposed types.

```javascript
// fs.readFile is a function that takes two arguments
// and returns undefined. The first argument is a string,
// and the second is a function that takes a string and returns
// undefined.
fs.readFile : (string, string -> undefined) -> undefined

// fs.opendir is a function that takes two arguments
// and returns undefined. The first argument is a string,
// and the second is a function that takes a fs.Dir object
// and returns undefined.
fs.opendir : (string, fs.Dir -> undefined) -> undefined
```

Since we don't care about what callbacks return, let's assume they all return undefined.

We will do two more modifications on the type signatures.

First, we will turn them into the following types by *currying*:

```javascript
fs.readFile : string -> (string -> undefined) -> undefined
fs.opendir : string -> (fs.Dir -> undefined) -> undefined
```

Instead of taking two arguments, the *curried* functions take an argument and returns a new function that takes the other argument. This transformation is called *currying*. It can be easily done in JavaScript, for example:

```javascript
function curriedReadFile(path) {
  return function (callback) {
    return fs.readFile(path, callback);
  };
}
```

Also observe that since the function type is right associative, `S -> T -> U` is the same as `S -> (T -> U)`.

Let's add parentheses back to their types to make it more clear:

```javascript
fs.readFile : string -> ((string -> undefined) -> undefined)
fs.opendir : string -> ((fs.Dir -> undefined) -> undefined)
```

Continuations always have the type `T -> undefined`, so we will use `Cont<T>` to represent `T -> undefined` where *Cont* is short for *continuation*.

Now we can write their types in a much cleaner way:

```javascript
fs.readFile : string -> Cont<Cont<string>>
fs.opendir : string -> Cont<Cont<fs.Dir>>
```

Interesting things happen here.

We might notice this repetitive pattern of `Cont<Cont<T>>` in the function types. In fact, every asynchronous function (after applying the two transformations) returns some type in this form. It must mean something.

So what does `Cont<Cont<T>>` mean exactly?

`T` means just some object whose type is `T`. This is simple.

`Cont<T>` means a continuation that when we give some `T` to it, it will do the rest of the work for us. That is what it means to be *continuation*.

Now as for `Cont<Cont<T>>`, it says:

- it's a continuation;
- when we give it a continuation of type `T`, it will do the rest.

In the plain English, it means "if you tell me what you're gonna do when you get, say, a million, I'll do that for you."

Now say you tell this guy that you want to buy a Ferrari. At that moment, nothing happens. You get home and forget it. However, some days later, you magically find a Ferrari in front of your house!

That *is* exactly what asynchronous programming looks like!

We might be eager to say `Cont<Cont<T>>` is the *promise*. But it's not 100% true.

`Cont<Cont<T>>` doesn't do anything until you give it a continuation. And if you give it multiple continuations, it will execute multiple times.

To transform a `Cont<Cont<T>>` into a real promise, we need to immediately give it a continuation to *eagerly* execute the operation and store the result in an internal cache. Then, every time we give it a new continuation, we will just pass the cached result to the continuation. Or if the result is not ready yet, we will store the continuation in an internal variable so that when it becomes ready, we will know the continuations we need to execute then.

Now we can talk about `Promise<T>`.

First, if we have a `T`, it's easy to turn it into a `Promise<T>`. This function is called `resolve` in JavaScript, but let's name it `ret` here (short for *return*). Its type should be:

```javascript
ret : T -> Promise<T>
```

Second, we can build promise chains using `then` in JavaScript, but let's call it `bind` here. Its type is:

```javascript
// This function is a simplified version of `then`.
// It requires the success callback to return a new promise.
bind : Promise<T> -> (T -> Promise<U>) -> Promise<U>
```

With `ret` and `bind` we are already able to build complicated applications.

Here is an example using `ret` and `bind` and the promisified functions defined above that opens an directory whose path is given in a file:

```javascript
// openDirFromFile : string -> Promise<fs.Dir>
const openDirFromFile = (filePath) =>
  bind(fs.readFile(filePath), (fileContent) =>
    bind(fs.opendir(fileContent), (dir) =>
      ret(dir)));
```

It's easy to notice this repetitive pattern `bind(p, x => q)`. Let's invent a more readable form instead: `{x = await p; q}`. It's only a syntatic sugar whose meaning is `bind(p, x => q)`.

And also `;` here is right associative, so `{x = await p; y = await q; r}` is the same as `{x = await p; {y = await q; r}}` and its meaning is `bind(p, x => bind(q, y => r))`.

Now we can write the same program in a cleaner way:

```javascript
// openDirFromFile : string -> Promise<fs.Dir>
const openDirFromFile = (filePath) => {
  fileContent = await fs.readFile(filePath);
  dir = await fs.opendir(fileContent);
  ret(dir)
}
```

Finally we reinvent the await/async style.

And also, from this example, we know it's not a coincidence that we call it `ret` instead of `resolve`.

`Promise<T>` is not the only type that supports `ret` and `bind`. Array is another type that supports them, though the implementation is different:

```javascript
// arrayRet : T -> Array<T>
arrayRet = (x) = [x]
// arrayBind : Array<T> -> (T -> Array<U>) -> Array<U>
arrayBind = Array.prototype.flatMap
```

All the types that supports some sort of `ret` and `bind` (and two more rules) on them are called **monad**. And the style that uses `ret` and `bind` to build up complicated programs is, correspondingly, called the **monadic** style.
