load("//toolchain/local/which:repository.bzl", _DOC = "DOC", _WHICH = "ATTRS", _which = "which")

which = tag_class(
    doc = _DOC,
    attrs = {
        "name": attr.string(doc = "Name of the generated repository.", mandatory = True),
    } | _WHICH,
)

def implementation(mctx):
    for mod in mctx.modules:
        for d in mod.tags.which:
            _which(name = d.name, **{a: getattr(d, a) for a in _WHICH})

local = module_extension(
    doc = "An extension for working with the local (i.e. host) system.",
    implementation = implementation,
    tag_classes = {
        "which": which,
    },
)
