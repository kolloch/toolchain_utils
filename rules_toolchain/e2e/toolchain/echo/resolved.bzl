load("@rules_toolchain//toolchain:resolved.bzl", _ATTRS = "ATTRS", _implementation = "implementation")

ATTRS = _ATTRS

implementation = _implementation

resolved = rule(
    doc = "Provides resolved toolchain information.",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        platform_common.TemplateVariableInfo,
        platform_common.ToolchainInfo,
        DefaultInfo,
    ],
    toolchains = ["//toolchain/echo:type"],
)
