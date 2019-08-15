---
layout: post
title: "React State Management In 2019"
date: 2019-08-14
tags: [react,web]
banner_image:
---

Since the first day we learned React, we have been told not to *overuse* states
in React. We are also encouraged to use *stateless* functional components over
*stateful* class components. These suggestions easily lead to an apparent
conclusion for beginners that *we shouldn't use states at all*, but rather, when
we do need them, seek for some independent state management libraries like
Redux.

Good news is this is no longer true.

<!--more-->

The reasons why vanilla states were so widely hated can be summed up as follows:

1. When the project gets larger, it soon becomes untrackable for the local
   states scattering in various different components.
2. State sharing between components can be painful.
3. Passing a prop from an outer component to a deeply nested component where the
   prop is used can also be painful; it's called **prop
   drilling** ([this article][prop-drilling] discussed prop drilling in detail).
4. The stateful logic is usually mixed together with the UI renderer, which in
   turn cause troubles in testing the stateful logic separately or reusing it in
   other components.
5. Class components are harder to be optimized than functional components during
   compilation.

Technically, the third item is not an issue of states, but rather a high-level
design question, which is usually caused by too many unnecessary decoupling of
components. Nevertheless, it does cause troubles to day-to-day programming in
React, and prevalent state management libraries usually present a proper
solution to it.

Redux, a most popular state management library, alleviates the pain
by separating the state from the UI and managing it in a central store. However,
it also brings troubles. One of what people usually disapprove of is that it
requires too much boilerplate code to set up the whole thing. Adding a new
state, for example, usually involves modifications in a great many files and,
when reading others' code, you need to constantly jump between multiple files to
figure out how the stateful logic works.

Just like any other open questions in the programming world, there is no silver
bullet for state management. It is determined by the complexity of the business
logic, the scale of the application and various factors in practice.

In this article, we will look at several state management approaches in 2019 and
discuss briefly the pros and cons.

## Vanilla React

In the past, React provided two different kinds of components: one is class
components, supporting states and hooks (i.e. componentDidMount, etc.), the
other functional components, not supporting these features.

If we wanted to take advantage of functional component as well as maintaining
app states, the only way was to turn to state management libraries like Redux.

This is no longer true after React added *Context API* and *Hooks*. By making a
proper use of these two new APIs, you probably don't need to use Redux in your
new projects any more. Since they are officially part of the React framework, I
would recommend at least take notice of them before deciding to use a
third-party state management library instead.

### React Hooks

React hooks are a way to **use states in functional components**. It seems very
contradictory at first sight since *functional* to some extent means
*stateless*. But let's put aside the relationship between them for the moment
and focus on its role as a *design pattern*.

Compared to class components, functional components have a more concise form and
less boilerplate code. It's more readable, and for compilers easier to
analyze and optimize.

However, forbidding using states in functional components can be really
troublesome: introducing a state as negligible as a boolean forces us to
rewrite the whole functional component in a class.

React hooks saves us from this dilemma by allowing us to use states in a
functional component. Moreover, it also allows us to separate the *stateful
logic* from the *rendering logic* and *reuse* it in other components.
For example, we can write a custom hook called *useTodoList* that manages the
todo list state (i.e. creation, update and deletion of todo items) and use it in
various components.

That being said, **everywhere setState is used, we can use React hooks
instead**. It has a comprehensive improvement over setState by dividing the
whole state of a component into smaller reusable parts and encouraging function
components over class components.

However, the philosophy of React hooks is very different from that of Redux,
which means you don't have to decide between the two. The former encourages
*small local reusable* state components, while the latter *large centralized
hierarchical* store. Since they are created for different use cases, we can use
them together in a project.

Although it's a design decision to which extent we should manage states in
Redux, I would recommend **globalizing a state only when necessary**, since
prematurely introducing the centralized store usually causes the whole project
hard to maintain very soon.

### React Context API

React Context API was created earlier than React hooks. But it aims at a
different state management problem: *state sharing* and *prop drilling*.

It might remind you of the purpose of Redux, but React Context API actually
discourages from using it for maintaining a centralized store like Redux:

> Context is primarily used when some data needs to be accessible by many
> components at different nesting levels. Apply it sparingly because it makes
> component reuse more difficult.

The philosophy behind React Context API is the same as that of React hooks, i.e.
**avoiding state sharing as much as possible**.

Typical scenarios that React Context API is suitable for include:

- User login information;
- UI themes;
- Locale preferences.

By properly combining React Context API with React hooks, we can manage app
states **without using Redux at all**.

## Redux


## MobX

[prop-drilling]: https://kentcdodds.com/blog/prop-drilling
