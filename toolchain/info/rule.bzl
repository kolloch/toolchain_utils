visibility("//toolchain/...")

DOC = """Provides toolchain information and Make variables around a target.

Often used with downloaded binary targets:

```py
load("@toolchain_utils//toolchain/triplet:defs.bzl", "ToolchainTripletInfo")

toolchain_type(
    name = "type",
)

# Setup a toolchain for each downloaded binary
[
    (
        toolchain_info(
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
    "variable": attr.string(
        doc = "The variable name for Make or the execution environment. Defaults to `name.upper()`",
    ),
    "_windows": attr.label(
        providers = [platform_common.ConstraintValueInfo],
        default = "//toolchain/constraint/os:windows",
    ),
}

def implementation(ctx):
    basename = ctx.label.name
    variable = ctx.attr.variable or basename.upper()
    windows = ctx.attr._windows[platform_common.ConstraintValueInfo]

    target = ctx.executable.target
    extension = target.extension
    if extension in (".bat", ".cmd"):
        basename = basename + extension
    elif extension in ("bat", "cmd"):
        basename = "{}.{}".format(basename, extension)
    elif not extension and "." not in basename and ctx.target_platform_has_constraint(windows):
        basename = "{}.exe".format(basename)

    executable = ctx.actions.declare_file("{}/{}".format(ctx.label.name, basename))
    ctx.actions.symlink(
        output = executable,
        target_file = target,
        is_executable = True,
    )

    variables = platform_common.TemplateVariableInfo({
        variable: ctx.executable.target.path,
    })

    runfiles = ctx.runfiles([executable, ctx.executable.target])
    runfiles = runfiles.merge(ctx.attr.target.default_runfiles)

    default = DefaultInfo(
        executable = executable,
        files = depset([executable]),
        runfiles = runfiles,
    )

    toolchain = platform_common.ToolchainInfo(
        variables = variables,
        default = ctx.attr.target[DefaultInfo],
        executable = ctx.executable.target,
        run = ctx.attr.target.files_to_run or ctx.executable.target,
    )

    return [variables, toolchain, default]

toolchain_info = rule(
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

info = toolchain_info
