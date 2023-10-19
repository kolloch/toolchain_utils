visibility("//toolchain/local/triplet/...")

def cpu(rctx):
    """
    Detects the host CPU.

    Args:
      rctx: the repository context to use for detection.

    Return:
      A CPU string.
    """
    return {
        "amd64": "amd64",
        "arm64": "arm64",
    }[rctx.os.arch]
