load("//toolchain/local/which:repository.bzl", _which = "export")
load("//toolchain/local/triplet:detect.bzl", "detect")
load("//toolchain/local/triplet:repository.bzl", _triplet = "export")
load("//toolchain/local/symlink:repository.bzl", _symlink = "export")

which = tag_class(
    doc = _which.doc,
    attrs = {
        "name": attr.string(doc = "Name of the generated repository.", mandatory = True),
    } | _which.attrs,
)

triplet = tag_class(
    doc = _triplet.doc,
    attrs = {
        "name": attr.string(doc = "Name of the generated repository.", mandatory = True),
    } | _triplet.attrs,
)

select = tag_class(
    doc = """Select a repository based on the current local triplet.

```py
local.select(
    name = "coreutils",
    map = {
        "@coreutils-arm64-linux-gnu": "arm64-linux-gnu",
        "@coreutils-amd64-linux-gnu": "amd64-linux-gnu",
    }
)
```
""",
    attrs = {
        "name": attr.string(doc = "Name of the generated repository.", mandatory = True),
        "map": attr.label_keyed_string_dict(
            doc = """Label to repositories that will be selected based on the triplet value.

The values can use reduced precision triplets to do a generic select:

```py
local.select(
    name = "abc",
    map = {
        "@xzy": "amd64-linux.5.3.1-gnu.2.31",
        "@foo": "amd64-linux-gnu",
        "@rrr": "amd64-linux.6.3.0",
        "@bar": "amd64-linux",
        "@baz": "amd64",
        "@def": "//conditions:default",
    }
)
```
""",
            allow_empty = False,
        ),
        "no_match_error": attr.string(
            doc = """Error message to raise when no match is found in map.

        Can use the `{triplet}` replacement to show the resolved local triplet.""",
            default = "No repository match found for `{triplet}`",
        ),
    },
)

def implementation(mctx):
    for mod in mctx.modules:
        for d in mod.tags.which:
            _which.rule(name = d.name, **{a: getattr(d, a) for a in _which.attrs})
        for d in mod.tags.triplet:
            _triplet.rule(name = d.name, **{a: getattr(d, a) for a in _triplet.attrs})
        for d in mod.tags.select:
            _symlink.rule(name = d.name, target = match(mctx, d))

def match(mctx, tag):
    local = detect(mctx)

    map = {}
    for label, triplet in tag.map.items():
        if triplet in map:
            fail("Cannot have duplicate triplet values: {}".format(triplet))

        map[triplet] = label

    selects = (
        "{}-{}-{}".format(local.cpu, local.os.value, local.libc.value),
        "{}-{}-{}".format(local.cpu, local.os.kind, local.libc.kind),
        "{}-{}".format(local.cpu, local.os.value),
        "{}-{}".format(local.cpu, local.os.kind),
        "{}".format(local.cpu),
        "//conditions:default",
    )

    for key in selects:
        if key in map:
            return map[key]

    fail(tag.no_match_error.format(triplet = local.value))

local = module_extension(
    doc = "An extension for working with the local (i.e. host) system.",
    implementation = implementation,
    tag_classes = {
        "which": which,
        "triplet": triplet,
        "select": select,
    },
)
