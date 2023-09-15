ATTRS = {
    "toolchain": attr.label(
        doc = "The toolchain type to gather the template variable information for.",
        mandatory = True,
    ),
}

def implementation(ctx):
    toolchain = ctx.toolchains[ctx.attr.toolchain.label]
    return [
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.data.env),
        DefaultInfo(
            files = toolchain.data.target.files,
            runfiles = toolchain.data.target.default_runfiles,
        ),
    ]

# This rule is useless by itself as the specific toolchain type needs to be defined
# Derive a toolchain specific rule and specify the correct toolchain
# The `ATTRS` and `implementation` can be reused
variable = rule(
    doc = "Provides template variable information for a toolchain.",
    attrs = ATTRS,
    implementation = implementation,
    incompatible_use_toolchain_transition = True,
    provides = [platform_common.TemplateVariableInfo],
    # toolchains = ["//your/toolchain/type"],
)
