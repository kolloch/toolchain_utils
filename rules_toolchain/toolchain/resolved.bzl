PROVIDES = (
    platform_common.TemplateVariableInfo,
    platform_common.ToolchainInfo,
    DefaultInfo,
)

ATTRS = {
    "toolchain": attr.label(
        doc = "The toolchain type to resolve and forward on providers.",
        mandatory = True,
    ),
}

def implementation(ctx):
    toolchain = ctx.toolchains[ctx.attr.toolchain.label]

    executable = ctx.actions.declare_file("toolchain-resolved-{}".format(ctx.label.name))
    ctx.actions.symlink(
        output = executable,
        target_file = toolchain.executable,
        is_executable = True,
    )

    files = depset([executable], transitive = [toolchain.default.files])
    runfiles = ctx.runfiles()
    runfiles = runfiles.merge(toolchain.default.default_runfiles)

    default = DefaultInfo(
        executable = executable,
        files = files,
        runfiles = runfiles,
    )

    return [
        toolchain,
        toolchain.variables,
        default,
    ]

def macro(*, toolchain):
    """
    Provides template variable information for a toolchain.

    When creating a toolchain, to provide the resolved toolchain create a `resolved.bzl` file:


        load(
            "@rules_toolchain//toolchain:resolved.bzl",
            _ATTRS = "ATTRS",
            _implementation = "implementation"
            _rule = "macro",
        )

        ATTRS = _ATTRS

        implementation = _implementation

        resolved = _rule(
            toolchain = Label("//coreutils/toolchain/cp:type"),
        )

    This rule can then be used to provide the resolved toolchain:

        load(":resolved.bzl", "resolved")

        toolchain_type(
            name = ":type",
        )

        # Some `toolchain` rules that are registered

        resolved(
            name = "resolved",
            toolchain = ":type",
        )

    The resolved target is runnable with `bazelisk run`.

    [1]: https://github.com/bazelbuild/bazel/issues/14009
    """
    return rule(
        doc = """Resolved toolchain information for the `{toolchain}` toolchain.

This target is runnable via:

    bazelisk run -- {toolchain} <args>
""".format(toolchain = toolchain),
        attrs = ATTRS,
        implementation = implementation,
        provides = PROVIDES,
        toolchains = [toolchain],
        executable = True,
    )
