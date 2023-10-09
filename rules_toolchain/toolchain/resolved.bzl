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

# This rule is useless by itself
# A toolchain type to resolve needs to be declared
# The `ATTRS` and `implementation` can be reused
# It is needed to work around the toolchain resolution step of Bazel[1]
# https://github.com/bazelbuild/bazel/issues/14009
resolved = rule(
    doc = "Provides template variable information for a toolchain.",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        platform_common.TemplateVariableInfo,
        platform_common.ToolchainInfo,
        DefaultInfo,
    ],
    # toolchains = ["//your/toolchain/type"],
)
