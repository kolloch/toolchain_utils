load(":TripletInfo.bzl", "TripletInfo")

def unversioned(triplet):
    """
    Converts a `TripletInfo` into an unversioned one.

    Args:
      triplet: the `TripletInfo` to remove version numbers from.

    Returns:
      An unversioned `TripletInfo`
    """
    parts = (
        triplet.cpu,
        triplet.vendor,
        triplet.os.kind,
        triplet.libc.kind,
    )
    return TripletInfo("-".join([p for p in parts if p != None]))
