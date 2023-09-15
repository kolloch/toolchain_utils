load("//toolchain/local:defs.bzl", "BinaryInfo")

ATTRS = {}

def implementation(ctx):
    output = ctx.actions.declare_file(ctx.label.name)

    info = BinaryInfo(
        program = output.basename,
        path = output.path,
        variable = output.basename.upper(),
    )

    ctx.actions.write(
        output = output,
        content = "#!/bin/sh",
        is_executable = True,
    )

    default = DefaultInfo(
        executable = output,
        files = depset([output]),
        runfiles = ctx.runfiles([output]),
    )

    return [info, default]

binary = rule(
    doc = "Creates a executable binary target file around a local binary path",
    attrs = ATTRS,
    implementation = implementation,
    provides = [BinaryInfo],
    executable = True,
)
