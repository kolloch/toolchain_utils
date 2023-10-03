load(":TargetInfo.bzl", "TargetInfo")

ATTRS = {}

def implementation(ctx):
    output = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.write(
        output = output,
        content = "#!/bin/sh",
        is_executable = True,
    )

    info = TargetInfo(
        env = {
            output.basename.upper(): output.path,
        },
    )

    default = DefaultInfo(
        executable = output,
        files = depset([output]),
        runfiles = ctx.runfiles([output]),
    )

    return [info, default]

binary = rule(
    doc = "Creates a stub executable binary target.",
    attrs = ATTRS,
    implementation = implementation,
    provides = [TargetInfo],
    executable = True,
)
