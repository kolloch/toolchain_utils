def init(target, env):
    """
    Initialises a `DataInfo` instance.

    Args:
      target: The Bazel target that to be used as the toolchain
      env: Environment variables to be exposed

    Returns:
      A mapping of keywords for the `data_info` raw constructor.
    """
    return {
        "target": target,
        "env": env,
    }

DataInfo, data_info = provider(
    "Data that is contained in a `platform_common.ToolchainInfo`",
    fields = ["target", "env"],
    init = init,
)
