---
layout: post
title: "Dependency Injection and Guice"
date: 2019-07-31
tags: [java]
banner_image: dependency-injection-and-guice.jpg
---

Dependency injection, in a word, is to separate the creation of objects from
its implementation.

It's not something advanced. In fact, you are very likely to have already
implemented some sort of *dependency injection* in your code.

For example, when implementing a server, you want to create a controller class
that handles business logic. It uses a data manger class to manage the data.
And the data manager in turn uses a MySQL client to manipulate the database. In
a common design without dependency injection, the business logic controller
will create an instance of the data manager in its constructor, and the data
manager do the same in its constructor to create a MySQL client as well.

However, this approach has two significant drawbacks in practice:

1. When writing unit tests, it's difficult to mock out the data manager in the
   test cases of the business logic controller, especially in static languages
   like Java and C++.
2. If one wants to customize a inner class, e.g. the URL of the database, then
   he needs to pass the URL all the way down to the data manager with the help
   of some sort of *Configuration* class.

Generally, we can solve these issues by creating the objects outside of the
constructors and then passing them into the constructors as parameters, which
could be depicted as the following Java code:

```java
MySqlClient mySqlClient = new MySqlClient(dbUrl, dbUsername, dbPassword);
DataManager dataManager = new MySqlDataManager(mySqlClient);
Controller controller = new Controller(dataManager);
```

This code snippet exactly illustrates what dependency injection is. As its name
suggests, it **injects** the **dependent objects** into the class. In this
example, the dependencies are injected through **constructor parameters**. It's
also possible to inject via Java reflection, but let's stop before going into
too much details.

The shortcoming of manually doing dependency injection is that we need to be
aware of the dependency relationship of all the objects we want to create. And
we must construct these objects in the exact topological order of the
dependency graph, which is a burden to us.

With the help of dependency injection frameworks like **[Guice][guice]**
(pronounced **juice** according to its title), we only need to **describe how
an object should be created**, and all the other things can be handed over to
the DI framework.

# Guice with `bind` and `@Inject`

Let's take a look at how we can apply Guice to our example.

```java
public class Controller {
  private final DataManager dataManager;
  @Inject
  public Controller(DataManager dataManager) {
    this.dataManager = dataManager;
  }
  // Implementations...
}

public class MyServerModule extends AbstractModule {
  @Override
  protected void configure() {
    bind(DataManager.class).to(MySqlDataManager.class);
    bind(Controller.class);
  }
}
```

`@Inject` tells Guice that this constructor is used for DI.

All the DI modules should extend `AbstractModule`, which allows us to use
`bind` method in it.

The first `bind` says that **whenever a DataManager object is needed, construct
a MySqlDataManager object**. This is used to bind an abstract class to a
concrete class.

The second `bind` says that **whenever a Controller object is needed, just
create a Controller object**. This is used when the class is concrete.

We don't explicitly specify that Controller is dependent on DataManager,
because Guice is clever enough to find out the dependency relationship between
the **classes** by itself.

When Guice finds a constructor decorated with `@Inject`, it knows that all the
parameters should be injected. In this example, when it sees the parameter of
type DataManager, it knows to inject a MySqlDataManager object here.

# Guice with `@Provides`

Sometimes, the class does not allow us to modify, like MySqlClient in the
example. In this case, we can use `@Provides` instead to tell Guice how to
create such object.

```java
public class MyServiceModule extends AbstractModule {
  @Override
  protected void configure() {
    //...
    bindConstant().annotatedWith(Names.named("dbUrl")).to(DB_URL);
    bindConstant().annotatedWith(Names.named("dbUsername")).to(DB_USERNAME);
    bindConstant().annotatedWith(Names.named("dbPassword")).to(DB_PASSWORD);
  }
  @Provides
  MySqlClient mySqlClient(
      @Named("dbUrl") String dbUrl,
      @Named("dbUsername") String dbUsername,
      @Named("dbPassword") String dbPassword) {
    return new MySqlClient(dbUrl, dbUsername, dbPassword);
  }
}
```

`bindConstant` is used to bind a constant string to a name, which can be 
referred to in injected parameters. We need to bind them with names, because
all of them are of the same type.

`@Provides` can decorate a module method, telling Guice how to create an object
of the return type. The name of the method doesn't matter. And just like
constructor parameters, the method parameters will be injected by Guice
automatically.

# How to use

Now let's create a Controller object with the module that we just defined.

```java
Injector injector = Guice.createInjector(new MyServiceModule());
Controller controller = injector.getInstance(Controller.class);
```

# Be modular

Guice allows us to group the bindings into multiple modules. e.g.

```java
Injector injector = Guice.createInject(
  new PostModule(),
  new CommentModule(),
  new AuthenticationModule()
);
```

The dependency graph is calculated on all the modules. So just like in a single
module, we don't need to care about the dependencies and are free to place
any binding in any module we like.

**All that we do need to care about is that they share the same scope, no
matter if they are in the same module, which means a class cannot have two
bindings, neither can a named binding.**

[guice]: https://github.com/google/guice
