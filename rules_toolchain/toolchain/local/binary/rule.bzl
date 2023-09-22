load(":BinaryInfo.bzl", "BinaryInfo")

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
}

def implementation(ctx):
    program = ctx.attr.program or ctx.label.name
    info = BinaryInfo(
        program = program,
        path = ctx.attr.path,
        variable = ctx.attr.variable or program.upper(),
    )

    output = ctx.actions.declare_file(info.program)
    ctx.actions.expand_template(
        template = ctx.file.template,
        output = output,
        substitutions = {
            "{{path}}": info.path,
        },
        is_executable = True,
    )

    default = DefaultInfo(
        executable = output,
        files = depset([output]),
        runfiles = ctx.runfiles([output]),
    )

    return [info, default]

binary = rule(
    doc = "Creates a executable binary target file around a local binary path",
    attrs = ATTRS,
    implementation = implementation,
    provides = [BinaryInfo],
    executable = True,
)
