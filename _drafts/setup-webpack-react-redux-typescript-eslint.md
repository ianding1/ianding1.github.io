---
layout: post
title: "Setup Webpack + React + Redux + TypeScript + ESLint + Jest"
date: 2019-08-08
tags: [web,typescript,react]
banner_image:
---

1. `npx create-react-app my-app-name --typescript --use-npm`

`--typescript` generates a typescript app instead of javascript.

`--use-npm` use npm rather yarn.

It will create a directory named *my-app-name* in the current directory and use
npm as the package manager (otherwise, it will use yarn).

What create-react-app provides?

- typescript/css/image loading, all in src/

2. Whether to use eject?

Mostly, no. Coding style consider using **standard**.

eslintConfig not working if not ejected.

3. What is **standard**?

`npm install standard`
A pre-configured eslint set.

3. `npm install` vs `npm install -D`

don't -D. since its frontend framework, all the deployed code are compiled and
bundled before deployed.

4. How to install **standard**.

`npm install standard @typescript-eslint/parser @typescript-eslint/eslint-plugin`
(why not use --dev, since its frontend)


Add to *package.json*:

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

Run `npm run style` to check style, run `npm run fix` to fix style issues.

Run `npm run style` once.

Why I don't want semicolons?

function myFunc() {
// should not have semicolon
}

const myFunc = () {
// should have semicolon
};

5. Hint:

at the beginning of jest test file, add

    /* eslint-env jest */

src/serviceWorker.ts: fetch not found

use window.fetch instead. Use window for all global objects instead, not just
for fetch.


6. Redux:

please also check out mobx.

npm install redux react-redux @types/react-redux redux-thunk @types/redux-thunk

Read how to use typescript in redux:

[official tutorial](https://redux.js.org/recipes/usage-with-typescript)
[good practice](https://medium.com/@matthewgerstman/redux-with-code-splitting-and-type-checking-205195aded46)

props:

7. Testing with redux

```shell
npm install redux-mock-store @types/redux-mock-store
```

Create mock store:

```typescript
import thunk from 'redux-thunk'
import configureStore from 'redux-mock-store'
import { AppState } from './types'

export const generateMockStore = (state: AppState) => {
  const mockStore = configureStore<AppState, ThunkDispatch<AppState, null, AnyAction>>([thunk])
  return mockStore(state)
}
```

```typescript
describe('myAsyncActionCreator', () => {
  let store: ReturnType<typeof generateMockStore>

  beforeEach(() => {
    store = generateMockStore(INITIAL_APP_STATE)
  })

  it('should process the handle', async () => {
    await store.dispatch(myAsyncActionCreator(request))
    const actions = store.getActions()
    expect(actions.length).toEqual(1)
    expect(actions[0]).toEqual(EXPECTED_ACTION)
  })
})
```

8. Type-checked mocking modules in testing

jest shipped with mocking module.

```typescript
impot { myOperation } from './myModule'

jest.mock('./myModule');

const 

// some-test-helper.ts
function mocked<T>(val: T): T extends (...args: any[]) => any ? jest.MockInstance<ReturnType<T>, Parameters<T>>: jest.Mocked<T> {
  return val as any;
}
```
