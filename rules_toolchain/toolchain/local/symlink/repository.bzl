DOC = "Creates a symlink repository."

ATTRS = {
    "target": attr.label(
        doc = "Target repository.",
        allow_single_file = True,
        mandatory = True,
    ),
}

def implementation(rctx):
    workspace = rctx.attr.target.workspace_name
    label = Label("@@{}//:WORKSPACE".format(workspace))
    path = rctx.path(label)

    if not path.exists:
        fail("Failed to resolve local respository workspace: {}".format(label))

    rctx.delete(".")
    rctx.symlink(path.dirname, ".")

symlink = repository_rule(
    doc = DOC,
    implementation = implementation,
    attrs = ATTRS,
    local = True,
    configure = True,
)

export = struct(
    doc = DOC,
    attrs = ATTRS,
    rule = symlink,
)
