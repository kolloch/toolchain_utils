load("//toolchain/triplet:split.bzl", "split")
load("//toolchain/triplet:VersionedInfo.bzl", "VersionedInfo")

visibility("//toolchain/local/triplet/...")

def _unquote(value):
    if value[0] == '"' and value[-1] == '"':
        return value[1:-1]
    return value

def _release(rctx, path):
    content = rctx.read(path)
    lines = content.splitlines()
    pairs = [line.split("=", 1) for line in lines if "=" in line]
    processed = {k.lower(): _unquote(v) for k, v in pairs}
    data = struct(**processed)

    if data.id in ("arch", "debian", "fedora"):
        return VersionedInfo("gnu")

    if data.id in ("alpine",):
        return VersionedInfo("musl")

    if data.id_like in ("debian",):
        return VersionedInfo("gnu")

    fail("Failed to determine host C library from `{}`".format(path))

def _ldd(rctx, path):
    result = rctx.execute([path, "--version"])
    if result.return_code != 0:
        fail("Failed to retrieve `ldd` version output:\n{}".format(result.stderr))

    first, second = result.stdout.strip().splitlines()[:2]

    if first.startswith("musl lib"):
        version = split(second, " ", {
            2: lambda _, v: v,
        })
        return VersionedInfo("musl.{}".format(version))

    if first.startswith("ldd") and "Free Software Foundation" in second:
        _, _, description = first.partition(" (")
        description, _, version = description.rpartition(") ")
        version = version

        if description == "GNU libc" or "GLIBC" in description:
            return VersionedInfo("gnu.{}".format(version))

    fail("Failed to detect `{}` version:\n{}".format(path, result.stdout))

def libc(rctx):
    """
    Detects the host C library.

    Args:
      rctx: the repository context to use for detection.

    Return:
      A `VersionedInfo` operating system triplet part.
    """
    path = rctx.which("ldd")
    if path:
        return _ldd(rctx, path)

    path = rctx.path("/etc/os-release")
    if path.exists:
        return _release(rctx, path)

    fail("Failed to detect host C library")
