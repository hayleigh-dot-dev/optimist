import gleam/int
import gleam/list
import gleeunit
import gleeunit/should
import optimist

pub fn main() {
  gleeunit.main()
}

// Test cases extracted from optimist.gleam documentation

pub fn push_resolved_value_test() {
  let optimistic =
    optimist.from(1)
    |> optimist.push(2)
    |> optimist.unwrap

  optimistic |> should.equal(2)
}

pub fn push_multiple_updates_test() {
  let optimistic =
    optimist.from(1)
    |> optimist.push(2)
    |> optimist.push(3)
    |> optimist.unwrap

  optimistic |> should.equal(3)
}

pub fn push_revert_multiple_updates_test() {
  let optimistic =
    optimist.from(1)
    |> optimist.push(2)
    |> optimist.push(3)
    |> optimist.revert
    |> optimist.unwrap

  optimistic |> should.equal(1)
}

pub fn update_resolved_value_test() {
  let optimistic =
    optimist.from(1)
    |> optimist.update(int.add(_, 1))
    |> optimist.unwrap

  optimistic |> should.equal(2)
}

pub fn update_multiple_updates_test() {
  let optimistic =
    optimist.from(1)
    |> optimist.update(int.add(_, 1))
    |> optimist.update(int.add(_, 2))
    |> optimist.unwrap

  optimistic |> should.equal(4)
}

pub fn update_revert_multiple_updates_test() {
  let optimistic =
    optimist.from(1)
    |> optimist.update(int.add(_, 1))
    |> optimist.update(int.add(_, 2))
    |> optimist.revert
    |> optimist.unwrap

  optimistic |> should.equal(1)
}

pub fn force_optimistic_update_test() {
  let optimistic =
    optimist.from(1)
    |> optimist.push(2)
    |> optimist.force
    |> optimist.unwrap

  optimistic |> should.equal(2)
}

pub fn revert_optimistic_update_test() {
  let optimistic =
    optimist.from(1)
    |> optimist.push(2)
    |> optimist.revert
    |> optimist.unwrap

  optimistic |> should.equal(1)
}

pub fn resolve_successful_update_test() {
  let result = Ok(2)
  let optimistic =
    optimist.from(1)
    |> optimist.push(2)
    |> optimist.resolve(result)
    |> optimist.unwrap

  optimistic |> should.equal(2)
}

pub fn resolve_failed_update_test() {
  let result = Error("failed")
  let optimistic =
    optimist.from(1)
    |> optimist.push(2)
    |> optimist.resolve(result)
    |> optimist.unwrap

  optimistic |> should.equal(1)
}

pub fn try_successful_update_test() {
  let history = ["hey", "hi"]
  let result = Ok("how are you?")
  let optimistic =
    optimist.from(history)
    |> optimist.update(list.prepend(_, "how are you?"))
    |> optimist.try(result, list.prepend)
    |> optimist.unwrap

  optimistic |> should.equal(["how are you?", "hey", "hi"])
}

pub fn try_unsuccessful_update_test() {
  let history = ["hey", "hi"]
  let result = Error(Nil)
  let optimistic =
    optimist.from(history)
    |> optimist.update(list.prepend(_, "how are you?"))
    |> optimist.try(result, list.prepend)
    |> optimist.unwrap

  optimistic |> should.equal(["hey", "hi"])
}
