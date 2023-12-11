visibility("//toolchain/...")

ATTRS = {
    "path": attr.string(
        doc = "The path to a binary to symlink.",
        mandatory = True,
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
    "_windows": attr.label(
        providers = [platform_common.ConstraintValueInfo],
        default = "//toolchain/constraint/os:windows",
    ),
}

def implementation(ctx):
    basename = ctx.attr.basename or ctx.label.name
    variable = ctx.attr.variable or basename.upper()
    windows = ctx.attr._windows[platform_common.ConstraintValueInfo]

    if "." not in ctx.attr.path:
        extension = None
    else:
        _, extension = ctx.attr.path.rsplit(".", 1)

    if extension in ("bat", "cmd"):
        basename = "{}.{}".format(basename, extension)
    elif not extension and "." not in basename and ctx.target_platform_has_constraint(windows):
        basename = "{}.exe".format(basename)

    executable = ctx.actions.declare_symlink("toolchain/symlink/path/{}".format(basename))
    ctx.actions.symlink(
        output = executable,
        target_path = ctx.attr.path,
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

path = rule(
    doc = """Creates a executable symlink to a binary path.

This rule can be used to symlink a executable file outside of the workspace.

The external executable become part of the Bazel target graph.

It exports the necessary providers for the target to be easily ingested by the native `toolchain` rule.

```
toolchain_type(
    name = "type",
)

toolchain_symlink_path(
    name = "gcc-local",
    path = "/usr/bin/gcc",
)

toolchain(
    name = "local",
    toolchain = ":gcc-local",
    toolchain_type = ":type",
)
```

_Commonly_, this target is not used directly and the `local.which` extension is used that looks up a binary on a path.
""",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        platform_common.TemplateVariableInfo,
        platform_common.ToolchainInfo,
        DefaultInfo,
    ],
    executable = True,
)
