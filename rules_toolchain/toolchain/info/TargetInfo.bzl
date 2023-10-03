def init(env):
    """
    Initialises a `TargetInfo` instance.

    Args:
      env: Environment variables to be exposed.

    Returns:
      A mapping of keywords for the `target_info` raw constructor.
    """
    return {
        "env": env,
    }

TargetInfo, target_info = provider(
    "Information about a toolchain target that is used to construct a `DataInfo`",
    fields = ["env"],
    init = init,
)
