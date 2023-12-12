# `rules_toolchain`

> A Bazel ruleset to enable concise toolchain registration.

## Getting Started

Add the following to `MODULE.bazel`:

```py
which = use_repo_rule("@rules_toolchain//toolchain/local/which:defs.bzl", "toolchain_local_which")
which(
    name = "echo",
    toolchain_type = "//toolchain/echo:type",
)
```

Create a `toolchain/echo/BUILD.bazel` with the following:

```py
load("@rules_toolchain//toolchain/test:defs.bzl", "toolchain_test")

# The `toolchain/echo:type` for registration
toolchain_type(
    name = "type",
    visibility = ["//visibility:public"],
)

# Register the `local` binary as a toolchain
# No `exec_compatible_with` constraints are needed as a local binary is always compatible with the execution platform
toolchain(
    name = "local",
    toolchain = "@echo//:echo",
    toolchain_type = ":type",
)

# Run the resolved toolchain with:
#   bazel run -- //toolchain/echo:resolved
alias(
    name = "resolved",
    actual = "@echo//:resolved",
)

# Performs a execution test of the binary
# Validates it works on the current platform
toolchain_test(
    name = "test",
    args = ["Hello, world!"],
    stdout = ":hello-world.txt",
    toolchains = [":resolved"],
)
```

To create a hermetic toolchain from a built target:

```py
load("@rules_toolchain//toolchain/symlink/target:defs.bzl", "toolchain_symlink_target")

# Assumes that `:echo` points to a Bazel built `echo` binary
toolchain_symlink_target(
    name = "built",
    target = ":echo"
)

# Register the hermetic toolchain
toolchain(
    name = "hermetic",
    toolchain = ":built",
    toolchain_type = ":type",
)
```

To create a hermetic toolchain from a downloaded target:

```py
load("@rules_toolchain//toolchain/symlink/target:defs.bzl", "toolchain_symlink_target")

# Create the necessary toolchain providers around the downloaded target
toolchain_symlink_target(
    name = "echo-arm64-linux-gnu",
    target = ":downloaded-echo-arm64-linux-gnu"
)

# Register with the correct contraints
toolchain(
    name = "arm64-linux",
    toolchain = ":echo-arm64-linux-gnu",
    toolchain_type = ":type",
    # Use constraints to signify what host machines the toolchain is compatible with
    exec_compatible_with = [
        "@rules_toolchain//toolchain/constraint/cpu:arm64",
        "@rules_toolchain//toolchain/constraint/os:linux",
        # Bazel _assumes_ `glibc` for Linux
        # "@rules_toolchain//toolchain/constraint/libc:gnu",
    ],
)
```

## Usage

### Toolchain

Declare the usage of the toolchain in a rule definition:

```py
def implementation(ctx):
    toolchain = ctx.toolchains["//toolchain/echo:type"]
    print(toolchain.executable)
    print(toolchain.default.files)
    print(toolchain.default.runfiles)

example = rule(
    implementation = implementation,
    toolchains = ["//toolchain/echo:type"],
)
```

### Variable

Pass the resolved toolchain to a rule that supports variables:

```py
genrule(
    toolchains = ["//toolchain/echo:resolved"]
)
```

[resolved]: https://github.com/bazelbuild/bazel/issues/14009
