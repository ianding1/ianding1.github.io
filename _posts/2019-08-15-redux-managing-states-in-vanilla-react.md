---
layout: post
title: "Redux or not: Managing States in Vanilla React"
date: 2019-08-15
tags: [react,web]
banner_image: redux-managing-states-in-vanilla-react.jpg
description: Redux, a most popular state management library, alleviates the pain
  of state management in React applications, but also introduces its own
  problems. On the other hand, with the development of new React APIs like
  React hooks and Context API, it has become practical to manage states without
  Redux at all.
---

Since the first day we learned React, we have been told not to *overuse* states
in React. We are also encouraged to use *stateless* functional components over
*stateful* class components.

These suggestions easily lead to an apparent conclusion for beginners that *we
shouldn't use states at all*, but rather, when we do need them, seek for some
independent state management libraries like Redux.

There were several reasons why we hated vanilla states so much:

1. When the project gets larger, it soon becomes untrackable for the local
   states scattering in various different components.
2. State sharing between components can be painful.
3. Passing a prop from an outer component to a deeply nested component where the
   prop is used can also be painful; it's called **prop drilling**.
4. The stateful logic is usually mixed together with the UI renderer, making
   itself hard to test or reuse.
5. Class components are harder to be optimized than functional components during
   compilation.

<!--more-->

Strictly, prop drilling is not an issue of states, but rather a design
defect; it is usually caused by too many unnecessary encapsulations.

## The Pros and Cons of Redux

Redux, a most popular state management library, alleviates the pain
by separating the state from the UI and managing it in a central store.

The whole architecture is simple yet powerful. We can illustrate the mechanism
behind Redux in a *unidirectional* flow:

{% include image_caption.html imageurl="/images/posts/redux-mechanism.svg" alt="Redux mechanism" %}

Apart from the store itself, all the other components are *pure*, i.e. the
result of the function *solely* depends on the function arguments and nothing
else.

A pure function is easier to test, understand and debug. By enforcing this
*functional* paradigm, Redux reduces the load of maintaining the stateful logic
behind the application.

However, it also brings its own troubles. One of what people usually disapprove
of is that it requires too much boilerplate code to set up the whole thing.

This is especially troublesome for small projects. Adding a new action usually
requires us to define a new action, add a new action creator, modify reducers,
edit containers, and etc. We need to jump between several different files in
order to get things done, expanding a simple task within 5 lines into more than
20 lines.

It's also debatable whether we should use a centralized store, just like whether
we should use global variables.

Compared to local states, global states are harder to reuse. Refactoring of a
global state might cause unintended breaks in the code. And an inadequate use of
Redux containers might also lead to performance issues.

React, on the other hand, has made a great effort to ease the management of
states in these years by introducing **Context API** and **Hooks**.

## Vanilla React

React has two different kinds of components: *class components*, which supports
states and hooks (i.e. componentDidMount, etc.), and *functional components*,
which not but much simpler.

In the past, if we wanted to take advantage of functional components as well as
managing an internal state, the only way was to turn to state management
libraries like Redux.

This is no longer true after React added Context API and hooks.

Since they are officially part of the React framework, I would recommend at
least take notice of them before deciding to use a third-party state management
library instead.

### React Hooks

React hooks API provides a way to **use states in functional components**.

It seems very contradictory at first sight, since *functional* to some extent
means *stateless*. But let's put aside the relationship between them for the
moment and focus on its role as a *design pattern*.

Compared to class components, functional components have more concise forms and
less boilerplate code. It's more readable, and for compilers easier to
analyze and optimize.

However, forbidding using states in functional components can be really
troublesome: introducing a state as negligible as a boolean forces us to
rewrite the whole functional component in a class.

React hooks API saves us from this dilemma by allowing us to use states in a
functional component. Moreover, it also allows us to separate the *stateful
logic* from the *rendering logic* and *reuse* it in other UI components.

Here is a very simple example showing how to use React hooks in a functional
component:

```tsx
import React, { useState } from 'react'

const Counter: React.FC = () => {
  const [counter, setCounter] = useState(0)
  return (
    <div>
      <p>Counter: {counter}</p>
      <button onClick={() => setCounter(counter + 1)}>
        Increment
      </button>
    </div>
  )
}
```

**useState** returns the current state and a function that can be used to update
the state. The argument is the initial state. The first time it is called, it
initialize the internal state of the component. And later it returns the
internal state instead.

The state is **local to the component** and not shared between two instances of
the same component class.

We can call useState multiple times in a functional component. React hooks API
encourages us to decompose a complex state into smaller reusable states.

We can go further and encapsulate the stateful logic in a separate function
(i.e. **custom hook**) so that we can reuse it in different React
components:

```tsx
import React, {useState} from 'react'

// A custom hook
const useCounter = (initial: number) => {
  const [counter, setCounter] = useState(initial)

  return {
    counter,
    increment () {
      setCounter(counter + 1)
    },
    reset () {
      setCounter(initial)
    }
  }
}

const Counter: React.FC = () => {
  const { counter, increment, reset } = useCounter(0)
  return (
    <div>
      <p>Counter: {counter}</p>
      <button onClick={increment}>
        Increment
      </button>
      <button onClick={reset}>
        Reset
      </button>
    </div>
  )
}
```

**Everywhere setState is used, we can use React hooks instead**, since it has a
comprehensive improvement over setState by dividing the whole state of a
component into smaller reusable parts and encouraging function components over
class components.

### React Context API

React Context API was created earlier than React hooks. But it aims at a
different state management problem: *state sharing* and *prop drilling*.

It might remind you of the purpose of Redux, but React Context API actually
discourages from using it for maintaining a gigantic centralized store:

> Context is primarily used when some data needs to be accessible by many
> components at different nesting levels. Apply it sparingly because it makes
> component reuse more difficult.

The philosophy behind React Context API is the same as that of React hooks, i.e.
**avoiding state sharing as much as possible**.

Typical scenarios that React Context API is suitable for include:

- User login information;
- UI themes;
- Locale preferences.

For example, we can avoid passing the UI theme explicitly by wrapping it in a
Context:

```tsx
import React, { useContext } from 'react'

const ThemeContext = React.createContext('light')

const UserComponent: React.FC = () => {
  const theme = useContext(ThemeContext)
  return (
    <div>
      Current theme: {theme}
    </div>
  )
}

const App: React.FC = () => {
  return (
    <ThemeContext.Provider value="dark">
      <UserComponent />
    </ThemeContext.Provider>
  )
}

```

By properly combining React Context API with React hooks, we can manage
application states **without using Redux at all**.

However, just like any other open questions in the programming world, there is
no silver bullet for state management. It is determined by the complexity of the
business logic, the scale of the application and various factors.

We should choose the most suitable in practice. And my preference is using React
Context API and React hooks as a start, only employing Redux when it becomes
necessary.
