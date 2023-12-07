load("//toolchain/local/triplet:detect.bzl", "detect")
load("//toolchain/triplet:TripletInfo.bzl", "TripletInfo")

visibility("//toolchain/...")

DOC = "Selects and symlinks a repository based on the local machine triplet."

ATTRS = {
    "map": attr.string_dict(
        doc = """Local triplet to repository mappings:

```
toolchian_local_select(
    name = "abc",
    map = {
        "arm64-linux-gnu": "@abc-arm64-linux-gnu",
        "arm64-linux-musl": "@abc-arm64-linux-musl",
    },
)
""",
        mandatory = True,
        allow_empty = False,
    ),
    "triplet": attr.string(
        doc = "Overrides local machine triplet.",
    ),
    "no_match_error": attr.string(
        doc = """Error message to raise when no match is found in map.

    Can use the `{triplet}` replacement to show the resolved local triplet.""",
        default = "No repository match found for `{triplet}`: {map}",
    ),
}

def canonical(rctx, label):
    # This is _flaky_, it depends on `MODULE.bazel` repository naming[1]
    # [1]: https://bazel.build/external/extension#repository_names_and_visibility
    prefix = "~".join(rctx.name.split("~")[:-1])
    return "@@{}~{}".format(prefix, label.removeprefix("@"))

def implementation(rctx):
    t = TripletInfo(rctx.attr.triplet or detect(rctx).value)

    selects = (
        "{}-{}-{}".format(t.cpu, t.os.value, t.libc.value),
        "{}-{}-{}".format(t.cpu, t.os.value, t.libc.kind),
        "{}-{}-{}".format(t.cpu, t.os.kind, t.libc.value),
        "{}-{}-{}".format(t.cpu, t.os.kind, t.libc.kind),
        "{}-{}".format(t.cpu, t.os.value),
        "{}-{}".format(t.cpu, t.os.kind),
        "{}-{}".format(t.os.value, t.libc.value),
        "{}-{}".format(t.os.value, t.libc.kind),
        "{}-{}".format(t.os.kind, t.libc.value),
        "{}-{}".format(t.os.kind, t.libc.kind),
        "{}-{}".format(t.cpu, t.libc.value),
        "{}-{}".format(t.cpu, t.libc.kind),
        "{}".format(t.cpu),
        "{}".format(t.os.value),
        "{}".format(t.os.kind),
        "{}".format(t.libc.value),
        "{}".format(t.libc.kind),
        "//conditions:default",
    )

    for select in selects:
        if select in rctx.attr.map:
            label = rctx.attr.map[select]
            canon = canonical(rctx, label)
            workspace = Label("{}//:WORKSPACE".format(canon))
            path = rctx.path(workspace)

            if not path.exists:
                fail("Missing `{}` for `{}`: {}".format(label, select, path))

            rctx.delete(".")
            rctx.symlink(path.dirname, ".")
            return

    fail(rctx.attr.no_match_error.format(triplet = t.value, map = rctx.attr.map))

select = repository_rule(
    doc = DOC,
    implementation = implementation,
    attrs = ATTRS,
    local = True,
    configure = True,
)
