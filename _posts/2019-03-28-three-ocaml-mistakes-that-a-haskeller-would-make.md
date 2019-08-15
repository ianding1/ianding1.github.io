---
layout: post
title: "Three OCaml Mistakes That A Haskeller Would Make"
date: 2019-03-28
tags: [ocaml]
banner_image: ocaml-banner.jpg
---

# OCaml is not an indented language

```ocaml
(* The wrong program. *)
let f l =
  match l with
    | [] -> Printf.printf "a"
    | [x] -> 
      match x with
        | [] -> Printf.printf "b"
        | _ -> Printf.printf "c"
    | _ -> Printf.printf "d"
in
f [[3]; [4]]
```

A Haskeller may think that the program above prints "d" to the screen, but actually it crashes because of the missing of patterns. Although most OCaml programs are written in a well-indented style, but, in essense, just like C or Java, the OCaml syntax is not indented. In the example above, the clause printing `"d"` belongs to the inner match expression, not the outer. **When writing nested match expressions, always keep in mind to use parentheses.**

<!--more-->

```ocaml
(* The correct program. *)
let f l =
  match l with
    | [] -> Printf.printf "a"
    | [l1] -> (  (* Use parentheses *)
      match l1 with
        | [] -> Printf.printf "b"
        | _ -> Printf.printf "c"
    )
    | _ -> Printf.printf "d"
in
f [[1]; [1]]
```

# OCaml has no polymorphism on currying

```ocaml
(* The wrong program. *)
let ap f x y = f x y in
let eq = ap (=) in
eq true (eq 2 2)
```

The equivalent program in Haskell runs as expected but it cannot pass the type checker of OCaml. This is known as *value restriction*.

The difference is that `eq` in Haskell is parametric polymorphic, accepting any type that is an instance of the type class `Eq`. However, `eq` in OCaml is not parametric polymorphic, whose type actually means **for some specific type 'a that I don't know yet, receiving two 'a values and returning a boolean**. It has only one concrete type.

# OCaml doesn't infer the most general types inside mutually recursive functions

```ocaml
(* The wrong program. *)
let rec id x = x
and id_bool x = id (not x)
and id_int x = id (x + 1) in
Printf.printf "%B %d" (id_bool true) (id_int 1)
```

The program above causes a compilation error because the type of `id` is not polymorphic as is seen by `id_bool` and `id_int`.

Generally, to infer the type of a function `f`, the inferer first allocates free type variables for all the expressions and generates the constraints between these type variables (e.g. `'a list = int list`) by following the structure of the program and solve the constraints by **unification** (e.g. unifying `'a list = int list` gives `'a = int`). If there are still some free type variables after unification, they are bounded in the function type and hence we have a polymorphic function (e.g. `'a -> 'a` actually means `forall 'a. 'a -> 'a`), which is called **generalization**.

Given two functions `f` and `g` that call each other, we cannot first infer `f` and then `g`. Instead, we need to infer and generalize them together, which means, from the perspective of `g`, `f` is not yet polymorphic, but a concrete type containing some free type variables.

Just like the example above, `id`, `id_bool` and `id_int` are inferred together, which means `id` has only one concrete type in the view of `id_bool` and `id_int`.

In Haskell, we frequently defines many functions in a `where` clause without caring about if they are mutually recursive. This is because, before inferring, Haskell groups them by their mutually recursive relations and infers each group individually.

In OCaml, we need to explicitly arrange the functions by nested `let` expressions. 

Therefore, the best practice is **to reduce the members of mutually recursive functions to the minimum to get the most general type.**
