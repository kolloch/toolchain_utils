def init(target, executable, env):
    """
    Initialises a `DataInfo` instance.

    Args:
      target: The Bazel target that to be used as the toolchain.
      executable: The executable file to be used with actions.
      env: Environment variables to be exposed.

    Returns:
      A mapping of keywords for the `data_info` raw constructor.
    """
    return {
        "target": target,
        "executable": executable,
        "env": env,
    }

DataInfo, data_info = provider(
    "Data that is contained in a `platform_common.ToolchainInfo`",
    fields = ["target", "executable", "env"],
    init = init,
)
