---
layout: post
title: "Setup Webpack + React + Redux + TypeScript + ESLint + Jest"
date: 2019-08-08
tags: [web,typescript,react]
banner_image:
---

This tutorial aims to help you setup a React + TypeScript project quickly. At
the end of this tutorial, you will have:

- Webpack + a development server + production build
- React + Redux with *TypeScript*
- Testing with *jest*
- Loading *CSS* and *images* with `import` statement
- Linting with *eslint*
- Code formatting with *standard*

## Create a project

```sh
npx create-react-app my-app-name --typescript --use-npm
```

It will create a directory named *my-app-name* in the current directory and use
npm as the package manager. Note that it prevents you from using other naming
styles than the hyphen form like `my-awesome-project`.

An explanation on the options:
- `--typescript`: uses TypeScript rather than JavaScript.
- `--use-npm`: uses npm rather than yarn.

The reason that we use create-react-app to set up the project is that it
provides good build tools out of box, and in further you project will only have
a single *build tool dependency* on react-scripts in package.json, which allows
you to upgrade to newer build tools easily. (The library dependencies like react
and typescript will still be managed in package.json, though)
 
The build tools that it comes with include:

- Webpack with CSS/image loader, code compressor, etc.
- jest
- eslint

A common question is whether to eject the build tools into your project?

create-react-app hides all the build tools and configurations behind the package
called react-scripts to allow for easy upgrades and cleaner dependencies, which,
on the other hand, makes it impossible to customize them, one of which you might
want to customize is eslint rules.

For those who wants more fine-grained control over the build tools, `npm run
eject` expands the build tools and configurations into your project and gives
you full control over them. However, it also makes it But I just find it unnecessary, since the
default is good enough for most cases.

**If you want a style checker in your project, it's best not to eject, rather
use *standard*, which will be introduced later.**

## Set up the style checker

create-react-app comes with eslint, but it's used for *potential programmatic
errors*, not style enforcement, since style checking by itself is not essential
in the build process. But it's easy for us to set up a style checker, which I
recommend using *standard*.

The following sections are copied and pasted from its homepage, explaining the
reason why I recommended it:

> **Why should I use JavaScript Standard Style?**
> Adopting standard style means ranking the importance of code clarity and
> community conventions higher than personal style. This might not make sense
> for 100% of projects and development cultures, however open source can be a
> hostile place for newbies. Setting up clear, automated contributor
> expectations makes a project healthier.
>
> **I disagree with rule X, can you change it?**
> No. The whole point of standard is to save you time by avoiding bikeshedding
> about code style. There are lots of debates online about tabs vs. spaces, etc.
> that will never be resolved. These debates just distract from getting stuff
> done. At the end of the day you have to 'just pick something', and that's the
> whole philosophy of standard -- its a bunch of sensible 'just pick something'
> opinions. Hopefully, users see the value in that over defending their own
> opinions.

If you decided to also use standard, you could install it by these steps:

```sh
npm install standard @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

And add the following lines into package.json:

```json
{
  "standard": {
    "parser": "@typescript-eslint/parser",
    "plugins": ["@typescript-eslint/eslint-plugin"]
  },
  "scripts": {
    /* Following existing scripts */
    "style": "standard \"src/**/*.ts\" \"src/**/*.tsx\"",
    "fix": "standard \"src/**/*.ts\" \"src/**/*.tsx\" --fix"
  }
}
```

Now you can run `npm run style` to check style, and run `npm run fix` to format
your code.

Run `npm run style` once to format the boilerplate code.


## Set up Redux

```sh
npm install redux react-redux @types/react-redux redux-thunk @types/redux-thunk
```

Redux provides an official tutorial on how to integrate Redux with TypeScript,
please check it out [here][redux-typescript-doc].

## Testing

redux-mock-store is essential for you to test asynchronous action creators.

```shell
npm install redux-mock-store @types/redux-mock-store
```

The following code example shows how to write tests on asynchronous action
creators:

```typescript
// some-test-helpers.ts
import thunk, {ThunkDispatch} from 'redux-thunk'
import configureStore from 'redux-mock-store'
import {AnyAction} from 'redux'
import {AppState} from './types'    // Replace with your app state interface

export const generateMockStore = (state: AppState) => {
  const mockStore = configureStore<AppState, ThunkDispatch<AppState, null, AnyAction>>([thunk])
  return mockStore(state)
}

// myActionCreators.test.js
describe('myAsyncActionCreator', () => {
  let store: ReturnType<typeof generateMockStore>

  beforeEach(() => {
    store = generateMockStore(MY_INITIAL_APP_STATE)
  })

  it('should do something', async () => {
    await store.dispatch(myAsyncActionCreator(request))
    const actions = store.getActions()
    expect(actions.length).toEqual(1)
    expect(actions[0]).toEqual(EXPECTED_ACTION)
  })
})
```

## Type-safe mocking

When testing action creators, it's common to mock out the modules that the
action creators import. But it's kind of tricky to do it in a type-safe way,
which apparently is not a problem in JavaScript. After some researching, I find
a function that can safely do the type-conversion and make autocompletion tools
work out of box.

```typescript
// some-test-helper.ts
function mocked<T>(val: T): T extends (...args: any[]) => any
  ? jest.MockInstance<ReturnType<T>, Parameters<T>> & T
  : jest.Mocked<T> {
  return val as any
}

// myActionCreators.test.js
impot { myAsyncOperation } from './myModule'

jest.mock('./myModule')

const mockedMyAsyncOperation = mocked(myAsyncOperation)

// An example of returning a resolved promise.
mockedMyAsyncOperation.mockResolvedValue({data: [1,2,3]})
```

[redux-typescript-doc]: https://redux.js.org/recipes/usage-with-typescript
