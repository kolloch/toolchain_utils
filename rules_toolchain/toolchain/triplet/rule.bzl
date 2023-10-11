load(":TripletInfo.bzl", "TripletInfo")

ATTRS = {
    "value": attr.string(
        doc = "A triplet value that overrides `name`.",
    ),
}

def implementation(ctx):
    value = ctx.attr.value or ctx.label.name
    triplet = TripletInfo(value)

    output = ctx.actions.declare_file("{}.txt".format(value))
    ctx.actions.write(
        output = output,
        content = value,
    )

    executable = ctx.actions.declare_file("{}.sh".format(value))
    ctx.actions.write(
        output = executable,
        content = "#!/bin/sh\nprintf '%s\n' {}".format(value),
        is_executable = True,
    )

    default = DefaultInfo(
        executable = executable,
        files = depset([output]),
        runfiles = ctx.runfiles([output]),
    )

    return [triplet, default]

triplet = rule(
    doc = """Provides a machine triplet.

A simple rule that provides a `ToolchainTripletInfo` provider.

The resulting provider can be used in other rules to understand triplet values.

Running the target with `bazel run` will result in the triplet being printed.

The triplet runnable output is particularly useful for the resolved host triplet at `@rules_toolchain//toolchain/triplet:host`
""",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        DefaultInfo,
        TripletInfo,
    ],
    executable = True,
)
