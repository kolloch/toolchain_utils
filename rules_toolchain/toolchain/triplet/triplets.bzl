load("@rules_toolchain//toolchain/constraint/os/linux:versions.bzl", _LINUX = "VERSIONS")
load("@rules_toolchain//toolchain/constraint/libc/gnu:versions.bzl", _GNU = "VERSIONS")
load(":TripletInfo.bzl", "TripletInfo")

UNVERSIONED = (
    TripletInfo("arm64-linux-gnu"),
    TripletInfo("amd64-linux-gnu"),
)

LINUX_GNU = tuple([
    TripletInfo("{}-{}-{}".format(cpu, os, libc))
    for cpu in ("arm64", "amd64")
    for os in ["linux.{}".format(v) for v in _LINUX]
    for libc in ["gnu.{}".format(v) for v in _GNU]
])

TRIPLETS = UNVERSIONED + LINUX_GNU
