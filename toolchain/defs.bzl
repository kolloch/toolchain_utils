load("//toolchain/triplet:TripletInfo.bzl", _TripletInfo = "TripletInfo")
load("//toolchain/symlink/path:rule.bzl", _symlink_path = "path")
load("//toolchain/symlink/target:rule.bzl", _symlink_target = "target")
load("//toolchain/test:rule.bzl", _test = "test")
load("//toolchain/local/which:repository.bzl", _local_which = "which")
load("//toolchain/local/select:repository.bzl", _local_select = "select")

visibility("public")

ToolchainTripletInfo = _TripletInfo
toolchain_symlink_path = _symlink_path
toolchain_symlink_target = _symlink_target
toolchain_test = _test
toolchain_local_which = _local_which
toolchain_local_select = _local_select
