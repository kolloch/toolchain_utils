load("//toolchain/triplet:split.bzl", "split")
load("//toolchain/triplet:VersionedInfo.bzl", "VersionedInfo")

def _header(rctx, path):
    """
    Reads the Linux version header to determine the correct Linux version.

    Args:
      rctx: The repository context that can execute commands on the host machine.
      path: the path to the Linux version header to read.

    Returns:
      The `VersionedInfo` provider
    """
    data = rctx.read(path).strip()

    def _split(line):
        if not line.startswith("#define"):
            return (None, None)

        _, name, value = line.split(" ", 2)

        if "(" in name:
            return (None, None)

        name = name.removeprefix("LINUX_VERSION_").lower()

        return (name, value)

    pairs = [_split(line) for line in data.splitlines()]
    map = {k: v for k, v in pairs if k and v}

    major = map.get("major", None)
    minor = map.get("patchlevel", None)
    patch = map.get("sublevel", None)

    if major and minor and patch:
        return VersionedInfo("linux.{}.{}.{}".format(int(major), int(minor), int(patch)))

    if "code" not in map:
        fail("Failed to find a `LINUX_VERSION_CODE` in {}".format(path))

    code = int(map["code"])

    major = (code >> 16) & 0xFF
    minor = (code >> 8) & 0xFF
    patch = (code >> 0) & 0xFF

    return VersionedInfo("linux.{}.{}.{}".format(major, minor, patch))

def _uname(rctx, path):
    """
    Determines the operating system version from `uname`

    Args:
      rctx: The repository context that can execute commands on the host machine.
      path: the path to the `uname` executable.

    Returns:
      The `VersionedInfo` provider
    """
    result = rctx.execute((path, "-r"))
    if result.return_code != 0:
        fail("Failed to get `uname` release: {}".format(result.stderr))

    version, _ = result.stdout.split("-", 1)

    major, minor, patch = split(version, ".", {
        1: lambda x: (x, None, None),
        2: lambda x, y: (x, y, None),
        3: lambda x, y, z: (x, y, z),
    })

    if rctx.path("/.dockerenv").exists:
        print("`uname` release is the host kernel inside a container.")

    return VersionedInfo("linux.{}.{}.{}".format(int(major), int(minor), int(patch)))

def os(rctx):
    """
    Detects the host operating system.

    Args:
      rctx: the repository context to use for detection.

    Return:
      A `VersionedInfo` operating system triplet part.
    """
    path = rctx.path("/usr/include/linux/version.h")
    if path.exists:
        return _header(rctx, path)

    path = rctx.which("uname")
    if path.exists:
        return _uname(rctx, path)

    return VersionedInfo({
        "linux": "linux",
    }[rctx.os.name])
