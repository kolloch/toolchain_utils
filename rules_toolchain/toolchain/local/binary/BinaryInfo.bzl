def check_envvar(name, value):
    if not value[0].isalpha():
        fail("`{}` must start with a letter: {}".format(name, value))

    if not value.isupper():
        fail("`{}` must be uppercase: {}".format(name, value))

    if not value.replace("_", "A").isalnum():
        fail("`{}` must be underscore separated and alphanumeric: {}".format(name, value))

    return value

def init(program, path, variable):
    """
    Initialises a `BinaryInfo` instance.

    Args:
      program: The executable name.
      path: The local path to the binary.
      variable: The variable name to use for Make or the execution environment.

    Returns:
      A mapping of keywords for the `binary_info` raw constructor.
    """
    return {
        "program": program,
        "path": path,
        "variable": check_envvar("BinaryInfo.variable", variable).upper(),
    }

BinaryInfo, binary_info = provider(
    "Information about a locally wrapped binary",
    fields = ["program", "path", "variable"],
    init = init,
)
