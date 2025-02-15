visibility("public")

DOC = """Resolved toolchain information for the `{toolchain}` toolchain.

This target is runnable via:

    bazelisk run -- {toolchain} <args>
"""

PROVIDES = (
    platform_common.TemplateVariableInfo,
    platform_common.ToolchainInfo,
    DefaultInfo,
)

ATTRS = {
    "basename": attr.string(
        doc = "The basename for the symlink, which defaults to `name`",
    ),
    "toolchain_type": attr.label(
        doc = "The toolchain type to resolve and forward on providers.",
        mandatory = True,
    ),
    "_windows": attr.label(
        providers = [platform_common.ConstraintValueInfo],
        default = "//toolchain/constraint/os:windows",
    ),
}

def implementation(ctx):
    basename = ctx.attr.basename or ctx.label.name
    toolchain = ctx.toolchains[ctx.attr.toolchain_type.label]
    windows = ctx.attr._windows[platform_common.ConstraintValueInfo]

    target = toolchain.executable
    extension = target.extension
    if extension in ("bat", "cmd"):
        basename = "{}.{}".format(basename, extension)
    elif not extension and "." not in basename and ctx.target_platform_has_constraint(windows):
        basename = "{}.exe".format(basename)

    executable = ctx.actions.declare_file("{}/{}".format(ctx.label.name, basename))
    ctx.actions.symlink(
        output = executable,
        target_file = target,
        is_executable = True,
    )

    files = depset([executable], transitive = [toolchain.default.files])
    runfiles = ctx.runfiles()
    runfiles = runfiles.merge(toolchain.default.default_runfiles)

    default = DefaultInfo(
        executable = executable,
        files = files,
        runfiles = runfiles,
    )

    return [
        toolchain,
        toolchain.variables,
        default,
    ]

def macro(*, toolchain_type):
    """Provides a executable `rule` to resolve a toolchain.

    To provide the resolved toolchain create a `resolved.bzl` file:

    ```py
    load("@toolchain_utils//toolchain:resolved.bzl", _resolved = "export")

    DOC = _resolved.doc.format(toolchain="cp")

    ATTRS = _resolve.attrs

    implementation = _resolved.implementation

    resolved = _resolved.rule(
        toolchain_type = Label("//coreutils/toolchain/cp:type"),
    )
    ```

    This rule can then be used to provide the resolved toolchain:

    ```py
    load(":resolved.bzl", "resolved")

    toolchain_type(
        name = ":type",
    )

    # Some `toolchain` rules that are registered

    resolved(
        name = "resolved",
        toolchain_type = ":type",
    )
    ```

    The resulting `resolved` target is runnable via `bazelisk run`.
    """
    if type(toolchain_type) != type(Label("//:all")):
        fail("`toolchain_type` must be passed as a `Label`: {}".format(type(toolchain_type)))

    return rule(
        doc = DOC.format(toolchain = toolchain_type),
        attrs = ATTRS,
        implementation = implementation,
        provides = PROVIDES,
        toolchains = [toolchain_type],
        executable = True,
    )

export = struct(
    doc = DOC,
    attrs = ATTRS,
    implementation = implementation,
    rule = macro,
)
