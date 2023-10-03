load("@bazel_skylib//lib:sets.bzl", "sets")

TRIPLETS = sets.make((
    "arm64-linux-gnu",
    "amd64-linux-gnu",
))
