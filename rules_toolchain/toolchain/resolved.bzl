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

    files = depset([executable])
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

# This rule is useless by itself
# A toolchain type to resolve needs to be declared
# The `ATTRS` and `implementation` can be reused
# It is needed to work around the toolchain resolution step of Bazel[1]
# https://github.com/bazelbuild/bazel/issues/14009
resolved = rule(
    doc = """Provides template variable information for a toolchain.

This rule is useless by itself and is a workaround for Bazel toolchain resolution[1].

When creating a toolchain, to provide the resolved toolchain create a `resolved.bzl` file:


    load(
        "@rules_toolchain//toolchain:resolved.bzl",
        _ATTRS = "ATTRS",
        _implementation = "implementation"
    )

    ATTRS = _ATTRS

    implementation = _implementation

    resolved = rule(
        doc = "Resolved toolchain information for a `xxx` toolchain.",
        attrs = ATTRS,
        implementation = implementation,
        provides = [
            platform_common.TemplateVariableInfo,
            platform_common.ToolchainInfo,
            DefaultInfo,
        ],
        toolchains = ["//yyy/toolchain/xxx:type"],
        executable = True,
    )

This rule can then be used to provide the resolved toolchain:

    load(":resolved.bzl", "resolved")

    toolchain_type(
        name = ":type",
    )

    # Some `toolchain` rules

    resolved(
        name = "resolved",
        toolchain = ":type",
    )

[1]: https://github.com/bazelbuild/bazel/issues/14009
""",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        platform_common.TemplateVariableInfo,
        platform_common.ToolchainInfo,
        DefaultInfo,
    ],
    executable = True,
    # toolchains = ["//your/toolchain/type"],
)
