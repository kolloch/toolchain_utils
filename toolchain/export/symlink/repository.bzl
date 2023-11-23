visibility("//toolchain/export/...")

DOC = "Symlinks a repository to another."

ATTRS = {
    "target": attr.label(
        doc = "The repository to symlink to.",
        mandatory = True,
    ),
}

def implementation(rctx):
    label = rctx.attr.target
    workspace = label.relative(":WORKSPACE")
    path = rctx.path(workspace)
    if not path.exists:
        fail("Failed to find `{}`, can only symlink repository labels.".format(path, label))
    target = path.dirname
    rctx.delete(".")
    rctx.symlink(target, ".")

symlink = repository_rule(
    doc = DOC,
    attrs = ATTRS,
    implementation = implementation,
    configure = True,
    local = True,
)
