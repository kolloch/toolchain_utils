load(":detect.bzl", "detect")

ATTRS = {
    "template": attr.label(
        doc = "The template that is expanded into the `triplet.bzl`.",
        default = Label(":triplet.tmpl.bzl"),
        allow_single_file = True,
    ),
}

def implementation(rctx):
    triplet = detect(rctx)
    rctx.template("triplet.bzl", rctx.attr.template, {
        "{{value}}": triplet.value,
    })
    rctx.file("BUILD.bazel", "")

triplet = repository_rule(
    doc = "Detects the host triplet.",
    implementation = implementation,
    attrs = ATTRS,
    local = True,
)
