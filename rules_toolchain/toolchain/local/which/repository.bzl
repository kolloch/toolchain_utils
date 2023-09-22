ATTRS = {
    "program": attr.string(
        doc = "The name of the binary to find on `PATH`.",
    ),
    "target": attr.string(
        doc = "The name of the Bazel target to expose around the binary.",
    ),
    "variable": attr.string(
        doc = "The variable name for Make or the execution environment.",
    ),
    "template": attr.label(
        doc = "The template that is expanded into the `BUILD.bazel`.",
        default = Label(":BUILD.tmpl.bazel"),
        allow_single_file = True,
    ),
}

def implementation(rctx):
    program = rctx.attr.program or rctx.attr.name.rsplit("~", 1)[1]

    path = rctx.which(program)
    if not path:
        fail("Cannot find `{}` on `PATH`".format(program))

    rctx.template("BUILD.bazel", rctx.attr.template, {
        "{{name}}": program or rctx.attr.target,
        "{{program}}": program,
        "{{path}}": str(path.realpath),
        "{{variable}}": rctx.attr.variable or program.upper(),
    })

which = repository_rule(
    doc = "Creates a repository that provides a binary target wrapping a local binary found on `PATH`.",
    implementation = implementation,
    attrs = ATTRS,
    configure = True,
    environ = [
        "PATH",
    ],
)
