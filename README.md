# optimist

[![Package Version](https://img.shields.io/hexpm/v/optimist)](https://hex.pm/packages/optimist)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/optimist/)

```sh
gleam add optimist@1
```

When building user interfaces, we are often faced with the question of what to do
while waiting for a response from a server. One common pattern is to update the
ui with an optimistic value - one we expect to get back if an operation is
successful - and then update the ui again once we get an actual response.

This package, `optimist`, provides a simple way to manage this pattern through an
`Optimstic` type and some functions to work with it. Let's take a quick look at
what you can do...

## 1. Start with a value

First things first, we need some value to be optimistic about!

```gleam
let wibble = optimist.from(1)
```

## 2. Update it

We have two ways to perform optimistic updates on an [`Optimistic`](https://hexdocs.pm/optimist/optimist.html#Optimistic)
value:

- [`push`](https://hexdocs.pm/optimist/optimist.html#push) a new value to replace
  the current one.

```gleam
let wobble = wibble |> optimist.push(2)
```

- [`update`](https://hexdocs.pm/optimist/optimist.html#update) the current value
  with a function that takes the current value and returns a new one.

```gleam
let wobble = wibble |> optimist.update(int.add(_, 1))
```

## 3. Do something with it

We've now performed an optimistic update and can render our value in the ui _as
if the operation has already succeeded_.

```gleam
html.p([], [
  html.text("Your value is: "),
  html.text(optimist.unwrap(wobble) |> int.to_string)
])
```

## 4. Resolve the update

We have a few different options for resolving an optimistic update depending on
the situation:

- [`resolve`](https://hexdocs.pm/optimist/optimist.html#resolve) the optimistic
  update with a new value.

```gleam
let response = Ok(2)
let resolved = wibble |> optimist.resolve(response)
```

- [`try`](https://hexdocs.pm/optimist/optimist.html#try) to resolve the
  optimistic update by applying a function to the response.

```gleam
let response = Ok(1)
let resolved = wibble |> optimist.try(response, int.add)
```

- [`reject`](https://hexdocs.pm/optimist/optimist.html#reject) the optimistic
  update and roll back to the previous value.

```gleam
let response = Error(Nil)
let resolved = wibble |> optimist.reject
```

- [`force`](https://hexdocs.pm/optimist/optimist.html#force) the optimistic
  update to resolve itself.

```gleam
let resolved = wibble |> optimist.force
```
