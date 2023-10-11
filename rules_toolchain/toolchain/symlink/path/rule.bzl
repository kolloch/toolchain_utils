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
}

def implementation(ctx):
    basename = ctx.attr.basename or ctx.label.name
    variable = ctx.attr.variable or basename.upper()

    executable = ctx.actions.declare_symlink(basename)
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
    doc = "Creates a executable symlink to a binary path.",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        platform_common.TemplateVariableInfo,
        platform_common.ToolchainInfo,
        DefaultInfo,
    ],
    executable = True,
)
