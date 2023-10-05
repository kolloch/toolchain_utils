load("//test/fixture:repository.bzl", _fixture = "export")

fixture = tag_class(
    doc = _fixture.doc,
    attrs = {
        "name": attr.string(doc = "Name of the generated repository.", mandatory = True),
    } | _fixture.attrs,
)

def implementation(mctx):
    for mod in mctx.modules:
        for d in mod.tags.fixture:
            _fixture.rule(name = d.name, **{a: getattr(d, a) for a in _fixture.attrs})

test = module_extension(
    doc = "An extension for creating test fixtures.",
    implementation = implementation,
    tag_classes = {
        "fixture": fixture,
    },
)
