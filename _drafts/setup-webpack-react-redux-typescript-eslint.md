---
layout: post
title: "Setup Webpack + React + Redux + TypeScript + ESLint + Jest"
date: 2019-08-08
tags: [web,typescript,react]
banner_image: setup-webpack-react.jpg
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
styles than the hyphen form like *my-awesome-project*.

Explanations on the options:

- `--typescript`: uses TypeScript rather than JavaScript.
- `--use-npm`: uses *npm* rather than *yarn*.

The reason that we use create-react-app to set up the project is that it
provides good build tools out of box, including:

- Webpack configured with CSS/image loader, code compressor, etc.
- React with TypeScript
- HTML index file
- jest
- eslint

**A common question is whether to eject the build tools into your project?**

create-react-app hides all the build tools and configurations behind the package
named *react-scripts* to allow for easy upgrades and cleaner dependencies, which,
on the other hand, makes it impossible to customize them, one of which you might
want to customize is eslint rules.

For those who want more fine-grained control over the build tools, `npm run
eject` can expand the build tools and configurations into your project and gives
you full control over them. However, by doing this, you will not be able to
easily upgrade the build tool by modifying the package version of
*react-scripts* in package.json to the newest. 

## Set up the style checker

The project you created comes with an eslint configuration, but it's used for
**detecting bad programming habits, not coding style**, since style checking by
itself is not essential in the building process. However, it's easy for us to
set up a style checker, which I recommend using *standard* rather than manually
configuring eslint rules.

The following sections are copied and pasted from [its homepage][standardjs],
explaining the reason why I recommend it:

> **Why should I use JavaScript Standard Style?**
>
> Adopting standard style means ranking the importance of code clarity and
> community conventions higher than personal style. This might not make sense
> for 100% of projects and development cultures, however open source can be a
> hostile place for newbies. Setting up clear, automated contributor
> expectations makes a project healthier.
>
> **I disagree with rule X, can you change it?**
>
> No. The whole point of standard is to save you time by avoiding bikeshedding
> about code style. There are lots of debates online about tabs vs. spaces, etc.
> that will never be resolved. These debates just distract from getting stuff
> done. At the end of the day you have to 'just pick something', and that's the
> whole philosophy of standard -- its a bunch of sensible 'just pick something'
> opinions. Hopefully, users see the value in that over defending their own
> opinions.

If you decided to also use standard, you could install it with this command:

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
    "style": "standard \"src/**/*.ts\" \"src/**/*.tsx\"",
    "fix": "standard \"src/**/*.ts\" \"src/**/*.tsx\" --fix"
  }
}
```

Now you can use `npm run style` to check style, and use `npm run fix` to format
your code.

The boilerplate code that create-react-app generates does not conform to
*standard*, so you need to run `npm run style` once to first format the
generated code, and you also need to manually fix two style violations that
cannot be automatically fixed:

1. Add `/* eslint-env jest */` at the beginning of `src/App.test.tsx`
2. Replace `fetch` with `window.fetch` in `src/serviceWorker.ts`

The first tells eslint that all the jest functions are accessible in the test
file. And the second is a general programming advice that is always using
`window.someFunc` rather than `someFunc`, since the global function can be
shadowed by a local variable with the same name.

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
action creators rely on. But it's kind of tricky to do it in a type-safe way.
After some researching, I found a function that can safely do the
type-conversion and also make autocompletion work out of box as well.

```typescript
// some-test-helper.ts
export function mocked<T>(val: T): T extends (...args: any[]) => any
  ? jest.MockInstance<ReturnType<T>, Parameters<T>> & T
  : jest.Mocked<T> {
  return val as any
}

// myActionCreators.test.js
impot { myAsyncOperation } from './myModule'

jest.mock('./myModule')

const mockedMyAsyncOperation = mocked(myAsyncOperation)

// Use the mock.
mockedMyAsyncOperation.mockResolvedValue({data: [1,2,3]})
```

[redux-typescript-doc]: https://redux.js.org/recipes/usage-with-typescript
[standardjs]: https://standardjs.com
