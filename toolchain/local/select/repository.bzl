load(":resolve.bzl", resolve = "key")

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
    label = resolve(rctx.attr.map, no_match_error = rctx.attr.no_match_error)
    canon = canonical(rctx, label)
    workspace = Label("{}//:WORKSPACE".format(canon))
    path = rctx.path(workspace)

    if not path.exists:
        fail("Missing `{}` for `{}`: {}".format(label, select, path))

    rctx.delete(".")
    rctx.symlink(path.dirname, ".")

select = repository_rule(
    doc = DOC,
    implementation = implementation,
    attrs = ATTRS,
    local = True,
    configure = True,
)
