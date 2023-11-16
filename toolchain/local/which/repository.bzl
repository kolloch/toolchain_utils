load("//toolchain:resolved.bzl", _ATTRS = "ATTRS")

visibility("//toolchain/...")

DOC = """Creates a repository that provides a binary target wrapping a local binary found on `PATH`.

The resulting repository has a `toolchain_symlink_path` target which can be used with the native `toolchain` rule to expose the local binary as a toolchain.

Assuming a repository created as `name = "echo"`, by default the `echo` binary will be search for an the nested target will be named `:echo`.

Consuming this target as a toolchain is trivial:

```py
toolchain(
    name = "local",
    toolchain = "@echo",
    toolchain_type = ":type",
)
```
"""

ATTRS = _ATTRS | {
    "program": attr.string(
        doc = "The name of the binary to find on `PATH`.",
    ),
    "target": attr.string(
        doc = "The name of the Bazel target to expose around the binary.",
    ),
    "variable": attr.string(
        doc = "The variable name for Make or the execution environment.",
    ),
    "resolved": attr.label(
        doc = "The tepmlate that is expanded into the `resolved.bzl`.",
        default = "//toolchain/resolved:resolved.tmpl.bzl",
        allow_single_file = True,
    ),
    "build": attr.label(
        doc = "The template that is expanded into the `BUILD.bazel`.",
        default = ":BUILD.tmpl.bazel",
        allow_single_file = True,
    ),
}

def implementation(rctx):
    program = rctx.attr.program or rctx.attr.name.rsplit("~", 1)[1]

    path = rctx.which(program)
    if not path:
        fail("Cannot find `{}` on `PATH`".format(program))

    rctx.template("resolved.bzl", rctx.attr.resolved, {
        "{{toolchain_type}}": str(rctx.attr.toolchain_type),
        "{{basename}}": str(rctx.attr.basename),
    }, executable = False)

    rctx.template("BUILD.bazel", rctx.attr.build, {
        "{{name}}": rctx.attr.target or program,
        "{{program}}": program,
        "{{path}}": str(path.realpath),
        "{{variable}}": rctx.attr.variable or program.upper(),
        "{{toolchain_type}}": str(rctx.attr.toolchain_type),
    }, executable = False)

which = repository_rule(
    doc = DOC,
    implementation = implementation,
    attrs = ATTRS,
    configure = True,
    environ = [
        "PATH",
    ],
)
