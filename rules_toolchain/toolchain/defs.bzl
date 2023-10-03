load("//toolchain/triplet:TripletInfo.bzl", _TripletInfo = "TripletInfo")
load("//toolchain/local/binary:rule.bzl", _local_binary = "binary")
load("//toolchain/info:rule.bzl", _info = "info")

ToolchainTripletInfo = _TripletInfo
toolchain_local_binary = _local_binary
toolchain_info = _info
