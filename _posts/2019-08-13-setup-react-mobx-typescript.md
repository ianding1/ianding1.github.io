---
layout: post
title: "Setup React + MobX + TypeScript"
date: 2019-08-13
tags: [typescript,react,web]
banner_image: setup-react-mobx.jpg
---

## Create a React project

```sh
npx create-react-app my-react-mobx-app --use-npm --typescript
```

It creates a directory named *my-react-mobx-app* under the current directory,
which has the following features pre-configured out of box:

- **Webpack**: supports ES6/ES.Next features, CSS/image loaders
- **React**: in TypeScript
- **Jest**: a unit test framework
- **Eslint**: checks bad programmatic habits, but doesn't enforce any coding
  style

## Install JavaScript Standard Style (Optional)

Create-react-app doesn't enforce any coding styles, though it has eslint
installed, which is only used for checking bad programmatic habits like
*using `==` where you should actually use `===`*.

I recommend installing *standard* as the style checker, because it's configured
with a coding style adopted by many popular projects, e.g.  NodeJS, npm,
express, etc. Using a standard coding style can save a lot of time in
investigation.

Run this command to install *standard*:

```sh
npm install standard
```

Add the following lines into package.json:

```json
{
  "scripts": {
    "style": "standard src/**/*.ts src/**/*.tsx",
    "fix": "standard --fix src/**/*.ts src/**/*.tsx"
  },
  "standard": {
    "parser": "@typescript-eslint/parser",
    "plugins": [
      "@typescript-eslint/eslint-plugin"
    ]
  },
```

By adding the two commands, you can:

- check the coding style with `npm run style`
- format the code with `npm run fix`

Before formatting the code, you need to do these two modifications, for the
generated project doesn't conform completely to the standard coding style:

- Add `/* eslint-env jest */` to the beginning of `src/App.test.tsx`
- Replace `fetch` with `window.fetch` in `src/serviceWorker.ts`

Now you can run `npm run fix` to format the generated code.

## Install MobX

```sh
npm install mobx mobx-react
```

Set `experimentalDecorators` to `true` in tsconfig.json under the project
directory, which allows using decorators (an ES.Next feature) in the code:

```json
{
  "compilerOptions": {
    "experimentalDecorators": true
  }
}
```

## Install mobx-state-tree

Designing your own state management logic on vanilla MobX is prone to
errors, especially when dealing with nested structures. You need to think
carefully which properties are observable and which not. To avoid the
difficulty of manually-managed states, I recommend using *mobx-state-tree*
instead, which also copes well with TypeScript.

```sh
npx install mobx-state-tree
```

## Define stores with mobx-state-tree

First let's define a simple model that represents a todo item.

```typescript
import { types } from 'mobx-state-tree'

const Todo = types.model('Todo', {  // A: define a model
  id: types.number,
  text: types.string,
  completed: types.boolean
})).actions(self => ({    // B: define actions
  markAsCompleted () {
    self.completed = true
  }
}))
```

- **A**: defines a model named *Todo* that contains *id*, *text* and
  *completed*.
- **B**: defines the actions of the model. The only way to modify a model
  property is though an action. Modifying a model property outside of defined
  actions is **forbidden** by default.

Then let's define a slightly more complicated model named *TodoListStore* that
contains a list of *Todo* models.

```typescript
import { types, cast, flow } from 'mobx-state-tree'

let nextTodoId = 10    // Used for id allocation only

const TodoListStore = types.model('TodoListStore', {
  todos: types.array(Todo)
}).views(self => ({  // A: define computed properties
  get numCompletedTodo () {
    return self.todos.filter(todo => todo.completed).length
  },
  getTodoById (todoId: number) {
    return self.todos.find(todo => todo.id === todoId)
  }
})).actions(self => ({
  addTodo: flow(function * addTodo (text: string) { // B: define asynchronous actions
    // Replace with real interactions with the server
    const newTodo = yield Promise.resolve({ id: nextTodoId++, text, completed: false })
    self.todos.push(newTodo)
  }),
  fetchTodoList: flow(function * fetchTodoList () {
    // Replace with real interactions with the server
    const todoList = yield Promise.resolve([{ id: 1, text: 'A todo item', completed: false }])
    self.todos = cast(todoList)     // C: cast from snapshot types to model types
  })
}))
```

- **A**: *views* defines computed properties of a model. Computed properties are
  derived properties of a model. They are only evaluated when re-computation is
  necessary (or try to be so).
- **B**: *flow* can be used to define an **asynchronous action**, which usually
  involves interactions with the server via Ajax. The argument passed to *flow*
  is a generator function, which works like async functions, except that it uses
  *yield* instead of *await* in the body to extract results from Promises.
- **C**: The type checker in TypeScript forbids assigning values from a narrower
  type to a broader one. So we need to convert the type of the value with *cast*
  if we want to assign a *snapshot* to a *model*.

## Integrate MobX with React

```typescript
import { observer } from 'mobx-react'

interface TodoItemProps {
  todo: typeof Todo.Type    // A: the type of the model
}

const TodoItem: React.FC<TodoItemProps> = observer(({ todo }) => (  // B: observer
  <li>
    <div onClick={() => todo.markAsCompleted()}>
      {todo.completed ? 'Done: ' : null}{todo.text}
    </div>
  </li>
))
```

- **A**: The type of a model is `typeof MyModel.Type`
- **B**: The functional component that reacts to the change of a model must be
  wrapped with *observer*.

```typescript
import { inject, observer, Provider } from 'mobx-react'

interface TodoListProps {
  todoListStore?: typeof TodoListStore.Type;   // A: the injected store property
}

@inject('todoListStore')   // B: inject the store
@observer                  // C: decorate with @observer
class TodoList extends React.Component<TodoListProps> {
  private addTodo = () => {
    const text = window.prompt('New todo')
    if (text) {
      todoListStore.addTodo(text)
    }
  }

  componentDidMount () {
    todoListStore.fetchTodoList()
  }

  render () {
    const store = this.props.todoListStore!  // D: assert it's not undefined
    return (
      <ul>
        {store.todos.map(todo => <TodoItem todo={todo} key={todo.id} />)}
        <li><button onClick={this.addTodo}>Add Todo</button></li>
      </ul>
    )
  }
}

const App: React.FC = () => {
  return (
    <Provider todoListStore={todoListStore}>   // E: provide the store
      <TodoList />
    </Provider>
  )
}
```

- **A**, **B**, **D**, **E**: Injection frees you from passing the store all the
  way down to the components that access it. To use injection, first
  wrap all the components that might access the store in a *Provider*. Then
  *inject* the store to the components that actually access it. Since the store
  property is omitted where *TodoList* is used, we need to declare it as
  optional. And as a result, we use `!` to assert that its value is never
  undefined when accessing the store.
- **C**: decorate the React component that reacts to the
  change of the store with `@observer`.

## Logging

You can add listeners to snapshot changes and actions, e.g. logging snapshot
changes and actions to the console:

```typescript
import { onSnapshot, onAction } from 'mobx-state-tree'

if (process.env.NODE_ENV === 'development') {
  onSnapshot(todoListStore, snapshot => console.log('todoListStore:\n', snapshot))
  onAction(todoListStore, action => console.log('action on todoListStore:\n', action))
}
```

This code will only enable logging in the development environment (when you
start the server with `npm start`), but not in the testing or production
environment (e.g. `npm test` and `npm run build`).

The reason why you can access the environment variable is that Babel will
replace all the occurrences of `process.env.NODE_ENV` in the code with
`'development'`, `'test'` or `'production'` in compile time according to the
environment value *NODE\_ENV*, which is explained in detail [here][envvar].

## Use the interface of the model

The interface of the model can be obtained with `SnapshotIn<>`.  e.g. define an
action that accepts a *Todo* snapshot directly:

```typescript
import { types, SnapshotIn } from 'mobx-state-tree'

const TodoListStore = types.model('TodoListStore', {
  todos: types.array(Todo)
})).actions(self => ({
  addTodo (todo: SnapshotIn<typeof Todo>) {
    self.todos.push(todo)
  }

  // It doesn't work.
  // addTodo (todo: typeof Todo.Type) {
  //   self.todos.push(todo)
  // }
}))
```

The reason why we cannot use `typeof Todo.Type` is that **`typeof Todo.Type`
also includes the action and computed members, but `SnapshotIn<typeof Todo>`
only includes the model property members**.

[envvar]: https://create-react-app.dev/docs/adding-custom-environment-variables
