ATTRS = {
    "target": attr.label(
        doc = "The binary file to symlink.",
        mandatory = True,
        allow_files = True,
        executable = True,
        cfg = "exec",
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
    target = ctx.files.target[0]
    variable = ctx.attr.variable or target.basename.upper()

    executable = ctx.actions.declare_file(ctx.label.name)
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
    doc = "Creates a executable symlink to a binary target file.",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        platform_common.TemplateVariableInfo,
        platform_common.ToolchainInfo,
        DefaultInfo,
    ],
    executable = True,
)
