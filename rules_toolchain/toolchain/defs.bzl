load("//toolchain/triplet:TripletInfo.bzl", _TripletInfo = "TripletInfo")
load("//toolchain/local/binary:rule.bzl", _local_binary = "binary")
load("//toolchain/symlink/target:rule.bzl", _symlink_target = "target")

ToolchainTripletInfo = _TripletInfo
toolchain_local_binary = _local_binary
toolchain_symlink_target = _symlink_target
