load("//toolchain/local/which:repository.bzl", _which = "export")
load("//toolchain/local/triplet:repository.bzl", _triplet = "export")

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

def implementation(mctx):
    for mod in mctx.modules:
        for d in mod.tags.which:
            _which.rule(name = d.name, **{a: getattr(d, a) for a in _which.attrs})
        for d in mod.tags.triplet:
            _triplet.rule(name = d.name, **{a: getattr(d, a) for a in _triplet.attrs})

local = module_extension(
    doc = "An extension for working with the local (i.e. host) system.",
    implementation = implementation,
    tag_classes = {
        "which": which,
        "triplet": triplet,
    },
)
