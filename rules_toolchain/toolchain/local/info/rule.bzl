load("//toolchain/local/binary:BinaryInfo.bzl", "BinaryInfo")
load("//toolchain/info:DataInfo.bzl", "DataInfo")

ATTRS = {
    "binary": attr.label(
        doc = "The binary target to provide toolchain information for.",
        allow_single_file = True,
        mandatory = True,
        cfg = "exec",
        providers = [BinaryInfo],
    ),
}

def implementation(ctx):
    binary = ctx.attr.binary[BinaryInfo]
    data = DataInfo(
        target = ctx.attr.binary,
        executable = ctx.file.binary,
        env = {
            binary.variable: str(ctx.file.binary.path),
        },
    )
    return [
        platform_common.ToolchainInfo(data = data),
        data,
        binary,
    ]

info = rule(
    doc = "Provides toolchain information for a local binary target.",
    implementation = implementation,
    attrs = ATTRS,
    provides = [
        platform_common.ToolchainInfo,
        DataInfo,
        BinaryInfo,
    ],
)
