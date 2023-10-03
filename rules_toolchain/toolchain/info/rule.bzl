load("@bazel_skylib//lib:structs.bzl", "structs")
load(":TargetInfo.bzl", "TargetInfo")
load(":DataInfo.bzl", "DataInfo")

ATTRS = {
    "binary": attr.label(
        doc = "The binary target to provide toolchain information for.",
        allow_single_file = True,
        mandatory = True,
        cfg = "exec",
        providers = [TargetInfo],
        executable = True,
    ),
}

def implementation(ctx):
    target = ctx.attr.binary[TargetInfo]
    data = DataInfo(
        target = ctx.attr.binary,
        executable = ctx.file.binary,
        **{k: v for k, v in structs.to_dict(target).items()}
    )
    return [
        platform_common.ToolchainInfo(data = data),
        data,
    ]

info = rule(
    doc = "Provides toolchain information for a local binary target.",
    implementation = implementation,
    attrs = ATTRS,
    provides = [
        platform_common.ToolchainInfo,
        DataInfo,
    ],
)
