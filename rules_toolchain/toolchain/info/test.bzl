load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def implementation(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    info = target[platform_common.ToolchainInfo]
    asserts.true(env, "BINARY" in info.data.env)
    return analysistest.end(env)

info_test = analysistest.make(implementation)

test = info_test
