visibility("//toolchain/...")

ATTRS = {
    "stdout": attr.label(
        doc = """The expected standard output.

Can be set to the following values for special handling:

- `@rules_toolchain//toolchain/test:non-empty`: accept any non-empty output
- `@rules_toolchain//toolchain/test:empty`: require empty output
""",
        default = ":non-empty",
        allow_single_file = True,
    ),
    "stderr": attr.label(
        doc = """The expected standard error.

Can be set to the following values for special handling:

- `@rules_toolchain//toolchain/test:non-empty`: accept any non-empty output
- `@rules_toolchain//toolchain/test:empty`: require empty output
""",
        default = ":empty",
        allow_single_file = True,
    ),
    "template": attr.label(
        doc = """The template that is expanded into the binary.

Can be overridden to a custom script that receives the following replacements:

- `{{executable}}`: the toolchain executable path
- `{{stdout}}`: the expected standard output
- `{{stderr}}`: the expected standard error
""",
        default = ":template",
        allow_single_file = True,
    ),
}

def implementation(ctx):
    if len(ctx.attr.toolchains) != 1:
        fail("Only one toolchain can be provided")
    toolchain = ctx.attr.toolchains[0][platform_common.ToolchainInfo]

    executable = ctx.actions.declare_file("{}.{}".format(ctx.label.name, ctx.file.template.extension))

    substitutions = ctx.actions.template_dict()
    substitutions.add("{{executable}}", str(toolchain.executable.short_path))
    substitutions.add("{{stdout}}", str(ctx.file.stdout.short_path))
    substitutions.add("{{stderr}}", str(ctx.file.stderr.short_path))

    ctx.actions.expand_template(
        template = ctx.file.template,
        output = executable,
        computed_substitutions = substitutions,
        is_executable = True,
    )

    return DefaultInfo(
        executable = executable,
        files = depset([executable]),
        runfiles = ctx.runfiles([toolchain.executable, ctx.file.stdout, ctx.file.stderr]),
    )

toolchain_test = rule(
    doc = """Performs a simple test that a toolchain resolved to an executable.

- Resolves the provided toolchain binary
- Executes with the provided arguments
- Captures `stdout` and `stderr`
- Can do optional `diff` checking of the output

A common use case is to check that a toolchain can output some help text:

```
toolchain_test(
    name = "test",
    args = ["--help"],
    toolchains = [":resolved"],
)
```
""",
    attrs = ATTRS,
    implementation = implementation,
    test = True,
)

test = toolchain_test
