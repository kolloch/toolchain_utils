# `rules_toolchain`

> A Bazel ruleset to enable concise toolchain registration.

## Getting Started

### Local Tool

Add the following to `MODULE.bazel`:

```py
which = use_repo_rule("@rules_toolchain//toolchain:defs.bzl", "toolchain_local_which")
which(
    name = "echo",
    toolchain_type = "//toolchain/echo:type",
)
```

The `echo` tool will be found on the `PATH`.

A repository with the `@echo//:echo` target will be created.

### Downloaded Tool

Use `rules_download` to provide a hermetic, pre-built binary in `MODULE.bazel`

```py
archive = use_repo_rule("@rules_download//download:defs.bzl", "download_archive")
archive(
    name = "coreutils-arm64-linux-gnu",
    srcs = ["coreutils"],
    integrity = "sha256-mlmkbeabyu4+5+cFiUSL6Ki4KFNqWu48gTjFc3NS43g=",
    strip_prefix = "coreutils-0.0.21-aarch64-unknown-linux-gnu",
    urls = ["https://github.com/uutils/coreutils/releases/download/0.0.21/coreutils-0.0.21-aarch64-unknown-linux-gnu.tar.gz"],
)
```

A repository with the `@coreutils-arm64-linux-gnu//:coreutils` target will be created.

### Toolchains

Create a `toolchain/echo/BUILD.bazel` with the following:

```py
load("@rules_toolchain//toolchain:defs.bzl", "toolchain_symlink_target", "toolchain_test")

# The `toolchain/echo:type` for registration
toolchain_type(
    name = "type",
    visibility = ["//visibility:public"],
)

# Register the `local` binary as a toolchain
# No `exec_compatible_with` constraints are needed as a local binary is always compatible with the execution platform
toolchain(
    name = "local",
    toolchain = "@echo",
    toolchain_type = ":type",
)

# Create a toolchain binary from the downloaded `coreutils`
toolchain_symlink_target(
    name = "coreutils-arm64-linux-gnu",
    target = "@coreutils-arm64-linux-gnu//:coreutils",
)

# Create a symlink to the multi-call binary
toolchain_symlink_target(
    name = "echo-arm64-linux-gnu",
    basename = "echo",
    target = ":coreutils-arm64-linux-gnu",
)

# Register the hermetic toolchain
# Use constraints to signify what host machines the toolchain is compatible with
toolchain(
    name = "arm64-linux",
    toolchain = ":echo-arm64-linux-gnu",
    toolchain_type = ":type",
    exec_compatible_with = [
        "@rules_toolchain//toolchain/constraint/cpu:arm64",
        "@rules_toolchain//toolchain/constraint/os:linux",
        # Bazel _assumes_ `glibc` for Linux
        # "@rules_toolchain//toolchain/constraint/libc:gnu",
    ],
)

# Provide a resolved toolchain target
alias(
    name = "resolved",
    actual = "@echo//:resolved",
)
```

### Run

The `resolved` target allows the toolchain that is compatible with the current machine to be executed:

```py
bazelisk run -- //toolchain/echo:resolved "Hello, world!"
```

If the machine is compatible with the downloaded toolchain constraints, that will be used. Otherwise, it will fallback
to finding the toolchain on the local `PATH`.

[resolved]: https://github.com/bazelbuild/bazel/issues/14009
