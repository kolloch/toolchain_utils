load("@rules_toolchain//toolchain:defs.bzl", "ToolchainTripletInfo")

visibility("public")

TRIPLET = ToolchainTripletInfo("{{value}}")
