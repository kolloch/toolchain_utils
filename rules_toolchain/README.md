# `rules_toolchain`

> A Bazel ruleset to enable concise toolchain registration.

## Getting Started

### Local Tool

Add the following to `MODULE.bazel`:

```py
local = use_extension("@rules_toolchain//toolchain:extensions.bzl", "local")
local.which("echo")
use_repo(local, "echo")
```

The `echo` tool will be found on the `PATH`.

A repository with the `@echo//:echo` target will be created.

### Downloaded Tool

Use `rules_download` to provide a hermetic, pre-built binary in `MODULE.bazel`

```py
download = use_extension("@rules_download//download:extensions.bzl", "download")
download.archive(
    name = "coreutils-arm64-linux-gnu",
    srcs = ["coreutils"],
    integrity = "sha256-mlmkbeabyu4+5+cFiUSL6Ki4KFNqWu48gTjFc3NS43g=",
    strip_prefix = "coreutils-0.0.21-aarch64-unknown-linux-gnu",
    urls = ["https://github.com/uutils/coreutils/releases/download/0.0.21/coreutils-0.0.21-aarch64-unknown-linux-gnu.tar.gz"],
)
use_repo(download, "coreutils-arm64-linux-gnu")
```

A repository with the `@coreutils-arm64-linux-gnu//:coreutils` target will be created.

### Toolchains

Create a `toolchain/echo/BUILD.bazel` with the following:

```py
load("@rules_toolchain//toolchain:defs.bzl", "toolchain_symlink_target", "toolchain_test")

# Custom rule, described in the next section
load(":resolved.bzl", "resolved")

# The `toolchain/echo:type` for registration
toolchain_type(
    name = "type",
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
resolved(
    name = "resolved",
    toolchain_type = ":type",
)
```

#### Resolved

To work around a [quirk in Bazel][resolved], the resolution of the toolchain must be defined in a separate rule.

`@rules_toolchain` provides the necessary building blocks for this rule.

Create `toolchain/echo/resolved.bzl` to provide the `resolved` rule that is used above:

```py
load("@rules_toolchain//toolchain:resolved.bzl", _resolved = "export")

DOC = _resolved.doc

ATTRS = _resolved.attrs

implementation = _resolve.implementation

resolved = _resolved.rule(
    toolchain = Label("//toolchain/echo:type"),
)
```

### Run

The `resolved` target allows toolchain that is compatible with the current machine to be executed:

```py
bazelisk run -- //toolchain/echo:resolved "Hello, world!"
```

If the machine is compatible with the downloaded toolchain constraints, that will be used. Otherwise, it will fallback
to finding the toolchain on the local `PATH`.

[resolved]: https://github.com/bazelbuild/bazel/issues/14009
