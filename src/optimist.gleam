//// When building user interfaces, we are often faced with the question of what
//// to do while waiting for a response from a server. One common pattern is to
//// update the ui with an optimistic value - one we expect to get back if an
//// operation is successful - and then update the ui again once we get an actual
//// response.
////
//// The `Optimistic` type is a simple way to model this pattern. A value can
//// either be fully resolved or it can be an optimistic update pending resolution.
//// The functions in this module help you manage and query the state of an
//// optimistic update.
////

// TYPES -----------------------------------------------------------------------

/// A value that is either fully resolved or an optimistic update pending resolution.
/// You can access the value of an `Optimistic` by using the [`unwrap`](#unwrap)
/// function.
///
pub opaque type Optimistic(a) {
  Resolved(value: a)
  Pending(value: a, fallback: a)
}

// CONSTRUCTORS ----------------------------------------------------------------

/// Construct an `Optimistic` update from a fully resolved value.
///
pub fn from(value: a) -> Optimistic(a) {
  Resolved(value)
}

// QUERIES ---------------------------------------------------------------------

/// Determine if an `Optimistic` update is fully resolved.
///
/// **Note**: it is uncommon to need this function. The optimistic ui pattern
/// typically means we are pretending an operation succeeded before we know for
/// sure. If you want to know if some request or other async job is still in
/// progress, you probably have that information in a more direct form elsewhere
/// in your state!
///
pub fn is_resolved(optimistic: Optimistic(a)) -> Bool {
  case optimistic {
    Resolved(_) -> True
    Pending(_, _) -> False
  }
}

/// Determine if an `Optimistic` update is still pending resolution.
///
/// **Note**: it is uncommon to need this function. The optimistic ui pattern
/// typically means we are pretending an operation succeeded before we know for
/// sure. If you want to know if some request or other async job is still in
/// progress, you probably have that information in a more direct form elsewhere
/// in your state!
///
pub fn is_pending(optimistic: Optimistic(a)) -> Bool {
  case optimistic {
    Resolved(_) -> False
    Pending(_, _) -> True
  }
}

// MANIPULATIONS ---------------------------------------------------------------

/// Push an optimistic update. If the current value is already resolved, this
/// becomes a new optimistic update and the current value becomes the fallback.
/// If the current value is already an optimistic update, the value is updated
/// but the fallback remains unchanged.
///
/// ### Optimistic update of a resolved value
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let optimistic =
///     optimist.from(1)
///     |> optimist.push(2)
///     |> optimist.unwrap
///
///   optimistic |> should.equal(2)
/// }
/// ```
///
/// ### Multiple optimistic updates
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let optimistic =
///     optimist.from(1)
///     |> optimist.push(2)
///     |> optimist.push(3)
///     |> optimist.unwrap
///
///   optimistic |> should.equal(3)
/// }
/// ```
///
/// ### Rejecting multiple optimistic updates
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let optimistic =
///     optimist.from(1)
///     |> optimist.push(2)
///     |> optimist.push(3)
///     |> optimist.revert
///     |> optimist.unwrap
///
///   optimistic |> should.equal(1)
/// }
/// ```
///
pub fn push(optimistic: Optimistic(a), value: a) -> Optimistic(a) {
  case optimistic {
    Resolved(fallback) -> Pending(value, fallback)
    Pending(_, fallback) -> Pending(value, fallback)
  }
}

/// Perform an optimistic update. If the current value is already resolved, this
/// becomes a new optimistic update and the current value becomes the fallback.
/// If the current value is already an optimistic update, the value is updated
/// but the fallback remains unchanged.
///
/// ### Optimistic update of a resolved value
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let optimistic =
///     optimist.from(1)
///     |> optimist.update(int.add(_, 1))
///     |> optimist.unwrap
///
///   optimistic |> should.equal(2)
/// }
/// ```
///
/// ### Multiple optimistic updates
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let optimistic =
///     optimist.from(1)
///     |> optimist.update(int.add(_, 1))
///     |> optimist.update(int.add(_, 2))
///     |> optimist.unwrap
///
///   optimistic |> should.equal(3)
/// }
/// ```
///
/// ### Rejecting multiple optimistic updates
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let optimistic =
///     optimist.from(1)
///     |> optimist.update(int.add(_, 1))
///     |> optimist.update(int.add(_, 2))
///     |> optimist.revert
///     |> optimist.unwrap
///
///   optimistic |> should.equal(1)
/// }
/// ```
///
pub fn update(optimistic: Optimistic(a), f: fn(a) -> a) -> Optimistic(a) {
  case optimistic {
    Resolved(fallback) -> Pending(f(fallback), fallback)
    Pending(_, fallback) -> Pending(f(fallback), fallback)
  }
}

/// Take an `Optimistic` update and force it to be resolved. This will erase the
/// fallback value and commit to whatever value is currently stored.
///
/// ### Forcing an optimistic update
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let optimistic =
///     optimist.from(1)
///     |> optimist.update(2)
///     |> optimist.force
///     |> optimist.unwrap
///
///   optimistic |> should.equal(2)
/// }
/// ```
///
pub fn force(optimistic: Optimistic(a)) -> Optimistic(a) {
  case optimistic {
    Resolved(_) -> optimistic
    Pending(value, _) -> Resolved(value)
  }
}

/// Take an `Optimistic` update and revert it back to its initial value if it is
/// still pending.
///
/// ### Reverting an optimistic update
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let optimistic =
///     optimist.from(1)
///     |> optimist.update(2)
///     |> optimist.revert
///     |> optimist.unwrap
///
///   optimistic |> should.equal(1)
/// }
/// ```
///
pub fn revert(optimistic: Optimistic(a)) -> Optimistic(a) {
  case optimistic {
    Resolved(_) -> optimistic
    Pending(_, fallback) -> Resolved(fallback)
  }
}

/// Take a `Result` and use it to resolve an optimistic update. If the result is
/// `Ok` that value becomes a new resolved value. If the result is an `Error` and
/// an optimistic update is pending, the fallback value is used to resolve the
/// update.
///
/// ```gleam
/// case result {
///   Ok(value) -> optimist.from(value)
///   Error(_) -> optimist.revert(optimistic)
/// }
/// ```
///
/// ### Resolving a successful optimistic update
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let result = Ok(2)
///   let optimstic =
///     optimist.from(1)
///     |> optimistic.update(2)
///     |> optimist.resolve(result)
///     |> optimist.unwrap
///
///   optimistic |> should.equal(2)
/// }
/// ```
///
/// ### Rejecting a failed optimistic update
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let result = Error("failed")
///   let optimistic =
///     optimist.from(1)
///     |> optimistic.update(2)
///     |> optimist.resolve(result)
///     |> optimist.unwrap
///
///   optimistic |> should.equal(1)
/// }
/// ```
///
pub fn resolve(optimistic: Optimistic(a), result: Result(a, _)) -> Optimistic(a) {
  case result {
    Ok(value) -> Resolved(value)
    Error(_) -> revert(optimistic)
  }
}

/// Take a `Result` and use it to resolve an optimistic update. If the result is
/// `Ok` that provided callback is run using either the value of an already-resolved
/// optimistic update, or the **fallback value** of a pending update.
///
/// ### Resolving a successful optimistic update
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let history = ["hey", "hi"]
///   let result = Ok("how are you?")
///   let optimistic =
///     optimist.from(history)
///     |> optimist.update(list.prepend(_, "how are you?"))
///     |> optimist.try(result, list.prepend)
///     |> optimist.unwrap
///
///   optimistic |> should.equal(["how are you?", "hey", "hi"]
/// }
/// ```
///
/// ### Resolving an unsuccessful optimistic update
///
/// ```gleam
/// import gleeunit/should
/// import optimist
///
/// pub fn example() {
///   let history = ["hey", "hi"]
///   let result = Error(Nil)
///   let optimistic =
///     optimist.from(history)
///     |> optimist.update(list.prepend(_, "how are you?"))
///     |> optimist.try(result, list.prepend)
///     |> optimist.unwrap
///
///   optimistic |> should.equal(["hey", "hi"]
/// }
/// ```
///
pub fn try(
  optimistic: Optimistic(a),
  result: Result(b, _),
  f: fn(a, b) -> a,
) -> Optimistic(a) {
  case result, optimistic {
    Ok(a), Resolved(value) -> Resolved(f(value, a))
    Ok(a), Pending(_, fallback) -> Resolved(f(fallback, a))
    Error(_), _ -> revert(optimistic)
  }
}

// CONVERSIONS -----------------------------------------------------------------

/// Unwrap an `Optimistic` value and return the underlying value.
///
pub fn unwrap(optimistic: Optimistic(a)) -> a {
  optimistic.value
}
