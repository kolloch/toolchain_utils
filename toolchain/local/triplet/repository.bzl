load(":detect.bzl", "detect")

visibility("//toolchain/...")

DOC = """Detects the host triplet.
"""

ATTRS = {
    "triplet": attr.label(
        doc = "The template that is expanded into the `triplet.bzl`.",
        default = Label(":triplet.tmpl.bzl"),
        allow_single_file = True,
    ),
    "value": attr.label(
        doc = "The template that is expanded into the `value.bzl`.",
        default = Label(":value.tmpl.bzl"),
        allow_single_file = True,
    ),
}

def implementation(rctx):
    triplet = detect(rctx)
    rctx.template("triplet.bzl", rctx.attr.triplet, {
        "{{value}}": triplet.value,
    }, executable = False)
    rctx.template("value.bzl", rctx.attr.value, {
        "{{value}}": triplet.value,
    }, executable = False)
    rctx.file("BUILD.bazel", "")

triplet = repository_rule(
    doc = DOC,
    implementation = implementation,
    attrs = ATTRS,
    local = True,
)
