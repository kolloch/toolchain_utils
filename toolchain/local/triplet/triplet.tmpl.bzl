load("@rules_toolchain//toolchain/triplet:defs.bzl", "ToolchainTripletInfo")

visibility("public")

TRIPLET = ToolchainTripletInfo("{{value}}")
