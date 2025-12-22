---
title: What is Boba?
description: Boba is a best-of-all-worlds runtime typechecker for Luau.
---

Boba is a best-of-all-worlds runtime typechecker for Luau.

## Why?

Type mismatch bugs are notoriously hard to debug. Static typechecking helps, but
it can’t protect you from data that arrives at runtime, especially across
network boundaries or from user input.

That’s where Boba shines.

Boba is especially useful for network communication and user-generated content,
such as the Welcome To Hell Tower Kit. In these cases, incoming data can’t be
statically verified, so it must be checked at runtime. Traditionally, this means
manually validating every invariant and then coercing the value into a usable
static type.

With Boba, the runtime checks you write and the static types you get
are always kept in sync, eliminating an entire class of bugs.

Boba also excels at defining schemas. For example, in Welcome To Hell, users
can define Mechanics for their towers. With Boba, Welcome To Hell can enforce
specific instance types and attribute constraints while still exposing a clean,
statically typed API.
