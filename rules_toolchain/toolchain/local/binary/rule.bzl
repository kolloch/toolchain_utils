ATTRS = {
    "path": attr.string(
        doc = "The path to the local binary.",
        mandatory = True,
    ),
    "program": attr.string(
        doc = "The name of the binary to found on PATH.",
    ),
    "variable": attr.string(
        doc = "The variable name for Make or the execution environment.",
    ),
    "template": attr.label(
        doc = "The template that is expanded into the binary.",
        default = Label(":posix.tmpl.sh"),
        allow_single_file = True,
    ),
    "data": attr.label_list(
        doc = "Extra files that are needed at runtime.",
        allow_files = True,
    ),
}

def implementation(ctx):
    program = ctx.attr.program or ctx.label.name
    variable = ctx.attr.variable or program.upper()

    executable = ctx.actions.declare_file("{}.sh".format(program))
    ctx.actions.expand_template(
        template = ctx.file.template,
        output = executable,
        substitutions = {
            "{{path}}": ctx.attr.path,
        },
        is_executable = True,
    )

    variables = platform_common.TemplateVariableInfo({
        ctx.attr.variable or program.upper(): executable.path,
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

binary = rule(
    doc = "Creates a executable binary target file around a local binary path",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        platform_common.TemplateVariableInfo,
        platform_common.ToolchainInfo,
        DefaultInfo,
    ],
    executable = True,
)
