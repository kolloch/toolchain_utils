load("//toolchain/local/which:repository.bzl", _WHICH = "ATTRS", _which = "which")

which = tag_class(attrs = {
    "name": attr.string(doc = "Name of the generated repository.", mandatory = True),
} | _WHICH)

def implementation(mctx):
    for mod in mctx.modules:
        for d in mod.tags.which:
            _which(name = d.name, **{a: getattr(d, a) for a in _WHICH})

local = module_extension(
    implementation = implementation,
    tag_classes = {
        "which": which,
    },
)
