load("//toolchain/local/select:resolve.bzl", resolve = "value")
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
    "mandatory": attr.bool(
        doc = "Determines if the tool must exist locally",
        default = False,
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
    "stub": attr.label_keyed_string_dict(
        doc = "An executable to use when the local binary is not found on `PATH`.",
        default = {
            ":stub.sh": "//conditions:default",
        },
        allow_files = [".bat", ".sh"],
        allow_empty = False,
        cfg = "exec",
    ),
    "entrypoint": attr.label_keyed_string_dict(
        doc = "An executable entrypoint template for hermetic rulesets.",
        default = {
            ":entrypoint.tmpl.sh": "//conditions:default",
        },
        allow_files = [".bat", ".sh"],
        allow_empty = False,
        cfg = "exec",
    ),
}

def implementation(rctx):
    program = rctx.attr.program or rctx.attr.name.rsplit("~", 1)[1]
    basename = rctx.attr.basename or program
    stub = resolve(rctx.attr.stub)
    entrypoint = resolve(rctx.attr.entrypoint)

    path = rctx.which(program)
    if not path:
        if rctx.attr.mandatory:
            fail("Cannot find `{}` on `PATH`".format(program))
        path = rctx.path(stub)

    rctx.template("resolved.bzl", rctx.attr.resolved, {
        "{{toolchain_type}}": str(rctx.attr.toolchain_type),
        "{{basename}}": basename,
    }, executable = False)

    rctx.template("entrypoint", entrypoint, {
        "{{path}}": str(path.realpath),
    }, executable = True)

    rctx.template("BUILD.bazel", rctx.attr.build, {
        "{{name}}": rctx.attr.target or program,
        "{{program}}": program,
        "{{basename}}": basename,
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
