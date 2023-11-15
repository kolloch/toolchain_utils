load("@rules_toolchain//toolchain:resolved.bzl", _resolved = "export")

DOC = _resolved.doc

ATTRS = _resolved.attrs

implementation = _resolved.implementation

resolved = _resolved.rule(
    toolchain_type = Label("{{toolchain_type}}"),
)
