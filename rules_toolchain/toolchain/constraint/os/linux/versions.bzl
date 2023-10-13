load("@local//:triplet.bzl", "TRIPLET")
load("@bazel_skylib//lib:sets.bzl", "sets")

LOCAL = TRIPLET.os.version and TRIPLET.os.version.value

# TODO: figure out a way to generate Linux versions
# Manually updating from https://en.wikipedia.org/wiki/Linux_kernel_version_history
# Only need the _latest_ patch version for each
LTS = (
    "4.4.302",
    "4.14.325",
    "4.19.294",
    "5.4.256",
    "5.10.194",
    "5.15.131",
)

def _versions(value):
    major, minor, patch = value.split(".")
    return ["{}.{}.{}".format(major, minor, p) for p in range(int(patch))]

VERSIONS = tuple(sets.to_list(sets.make([
    v
    for v in list(LTS) +
             [x for v in LTS for x in _versions(v)] +
             [LOCAL]
    if v != None
])))
