load("@rules_toolchain//toolchain:variable.bzl", _ATTRS = "ATTRS", _implementation = "implementation")

ATTRS = _ATTRS

implementation = _implementation

variable = rule(
    doc = "Provides template variable information for the toolchain.",
    attrs = ATTRS,
    implementation = implementation,
    incompatible_use_toolchain_transition = True,
    provides = [platform_common.TemplateVariableInfo],
    toolchains = ["//toolchain/echo:type"],
)
