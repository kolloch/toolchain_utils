visibility("//toolchain/...")

DOC = """Creates a executable symlink to a binary target file.

This rule can be used to symlink a executable target and export the necessary toolchain providers.

Often used with downloaded binary targets:

```py
load("@rules_toolchain//toolchain:defs.bzl", "ToolchainTripletInfo")

toolchain_type(
    name = "type",
)

# Setup a toolchain for each downloaded binary
[
    (
        toolchain_symlink_target(
            name = "something-{}".format(triplet.value),
            target = "@downloaded-{}//:something".format(triplet),
        ),
        toolchain(
            name = triplet.value,
            toolchain = ":something-{}".format(triplet.value),
            exec_compatible_with = triplet.constraints,
        )
    )
    for triplet in (
        ToolchainTripletInfo("arm64-linux-gnu"),
        ToolchainTripletInfo("arm64-linux-musl"),
    )
]
```

`rules_download` has a `download.archive` and `download.file` extension that can help with retrieving remote binaries.
"""

ATTRS = {
    "target": attr.label(
        doc = "The binary file to symlink.",
        mandatory = True,
        allow_files = True,
        executable = True,
        cfg = "exec",
    ),
    "basename": attr.string(
        doc = "The basename for the symlink, which defaults to `name`",
    ),
    "variable": attr.string(
        doc = "The variable name for Make or the execution environment.",
    ),
    "data": attr.label_list(
        doc = "Extra files that are needed at runtime.",
        allow_files = True,
    ),
}

def implementation(ctx):
    basename = ctx.attr.basename or ctx.label.name
    variable = ctx.attr.variable or basename.upper()

    target = ctx.files.target[0]
    extension = target.extension
    if extension in ("bat", "cmd"):
        basename = "{}.{}".format(basename, extension)

    executable = ctx.actions.declare_file(basename)
    ctx.actions.symlink(
        output = executable,
        target_file = target,
        is_executable = True,
    )

    variables = platform_common.TemplateVariableInfo({
        variable: executable.path,
    })

    default = DefaultInfo(
        executable = executable,
        files = depset([executable]),
        runfiles = ctx.runfiles(ctx.attr.data + [executable]),
    )

    toolchain = platform_common.ToolchainInfo(
        variables = variables,
        default = default,
        executable = executable,
    )

    return [variables, toolchain, default]

target = rule(
    doc = DOC,
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        platform_common.TemplateVariableInfo,
        platform_common.ToolchainInfo,
        DefaultInfo,
    ],
    executable = True,
)
