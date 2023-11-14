visibility("//...")

ATTRS = {
    "code": attr.int(
        doc = "The exit code for the test.",
        default = 0,
    ),
    "template": attr.label(
        doc = "The template script to expand.",
        allow_single_file = True,
        default = ":posix.tmpl.sh",
    ),
}

DOC = "A simple placeholder test rule."

def implementation(ctx):
    executable = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.expand_template(
        output = executable,
        template = ctx.file.template,
        substitutions = {
            "{{code}}": str(ctx.attr.code),
        },
    )

    return DefaultInfo(
        executable = executable,
        files = depset([executable]),
        runfiles = ctx.runfiles([executable]),
    )

placeholder_test = rule(
    attrs = ATTRS,
    doc = DOC,
    implementation = implementation,
    test = True,
)

test = placeholder_test
