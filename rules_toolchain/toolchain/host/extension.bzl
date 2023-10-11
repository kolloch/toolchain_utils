load("//toolchain/host/triplet:repository.bzl", _DOC = "DOC", _TRIPLET = "ATTRS", _triplet = "triplet")

triplet = tag_class(doc = _DOC, attrs = {
    "name": attr.string(doc = "Name of the generated repository.", mandatory = True),
} | _TRIPLET)

def implementation(mctx):
    for mod in mctx.modules:
        for d in mod.tags.triplet:
            _triplet(name = d.name, **{a: getattr(d, a) for a in _TRIPLET})

host = module_extension(
    doc = "An extension for performing `host` inspection.",
    implementation = implementation,
    tag_classes = {
        "triplet": triplet,
    },
)
