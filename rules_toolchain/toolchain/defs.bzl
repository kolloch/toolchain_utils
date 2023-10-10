load("//toolchain/triplet:TripletInfo.bzl", _TripletInfo = "TripletInfo")
load("//toolchain/symlink/path:rule.bzl", _symlink_path = "path")
load("//toolchain/symlink/target:rule.bzl", _symlink_target = "target")

ToolchainTripletInfo = _TripletInfo
toolchain_symlink_path = _symlink_path
toolchain_symlink_target = _symlink_target
