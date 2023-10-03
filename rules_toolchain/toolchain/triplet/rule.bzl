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
    doc = "Provies a machine triplet",
    attrs = ATTRS,
    implementation = implementation,
    provides = [
        DefaultInfo,
        TripletInfo,
    ],
    executable = True,
)
