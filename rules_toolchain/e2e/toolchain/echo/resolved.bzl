load("@rules_toolchain//toolchain:resolved.bzl", _ATTRS = "ATTRS", _implementation = "implementation", _rule = "macro")

ATTRS = _ATTRS

implementation = _implementation

resolved = _rule(
    toolchain = Label("//toolchain/echo:type"),
)
