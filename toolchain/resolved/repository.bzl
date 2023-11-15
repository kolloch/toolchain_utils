visibility("//toolchain/...")

DOC = """Creates a repository that provides a toolchain resolution rule.

Due to a [quirk] in Bazel, a custom rule needs to be created for each toolchain type.

```py
toolchain_resolved(
    name = "echo",
    toolchain_type = "@rules_abc//abc/toolchain/cli:type",
)
```

[quirk]: https://github.com/bazelbuild/bazel/issues/14009
"""

ATTRS = {
    "toolchain_type": attr.label(
        doc = "The toolchain type to resolve.",
        mandatory = True,
    ),
    "resolved": attr.label(
        doc = "The template that is expanded into the `resolved.bzl`.",
        default = Label(":resolved.tmpl.bzl"),
        allow_single_file = True,
    ),
    "build": attr.label(
        doc = "The template that is expanded into the `BUILD.bazel`.",
        default = Label(":BUILD.tmpl.bazel"),
        allow_single_file = True,
    ),
}

def implementation(rctx):
    substitutions = {
        "{{toolchain_type}}": str(rctx.attr.toolchain_type),
    }
    rctx.template("resolved.bzl", rctx.attr.resolved, substitutions, executable = False)
    rctx.template("BUILD.bazel", rctx.attr.build, substitutions, executable = False)

resolved = repository_rule(
    doc = DOC,
    implementation = implementation,
    attrs = ATTRS,
)
