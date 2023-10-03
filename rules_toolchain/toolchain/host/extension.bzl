load("//toolchain/host/triplet:repository.bzl", _TRIPLET = "ATTRS", _triplet = "triplet")

triplet = tag_class(attrs = {
    "name": attr.string(doc = "Name of the generated repository.", mandatory = True),
} | _TRIPLET)

def implementation(mctx):
    for mod in mctx.modules:
        for d in mod.tags.triplet:
            _triplet(name = d.name, **{a: getattr(d, a) for a in _TRIPLET})

host = module_extension(
    implementation = implementation,
    tag_classes = {
        "triplet": triplet,
    },
)
