"""Render the library and its examples, and check sizes, pieces and fit.

usage: python3 tests/test_snapfit.py [OPENSCAD]

Each render uses --hardwarnings. A binary STL's separate solids are counted
(triangles sharing a vertex belong to the same solid), and sizes are checked
to within 0.01 mm. A render that OpenSCAD reports as empty counts as no
geometry, which is what the fit and mirror checks expect.
"""

import os
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "snapfit.scad")
FIT = os.path.join(ROOT, "tests", "fit.scad")


def measure(path):
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    parent = {}

    def find(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    for i in range(n):
        v = struct.unpack_from("<9f", data, 84 + i * 50 + 12)
        corners = [v[0:3], v[3:6], v[6:9]]
        for c in corners:
            parent.setdefault(c, c)
        root = find(corners[0])
        for c in corners[1:]:
            parent[find(c)] = root
    solids = len({find(v) for v in parent})
    size = [max(p[i] for p in parent) - min(p[i] for p in parent) for i in range(3)]
    return solids, size


def render(openscad, scad, out, defines=()):
    """Return (solids, size), or None when OpenSCAD reports empty geometry."""
    cmd = [openscad, "--hardwarnings", "--export-format", "binstl", "-o", out]
    for d in defines:
        cmd += ["-D", d]
    result = subprocess.run(cmd + [scad], capture_output=True, text=True)
    if "empty" in result.stderr.lower():
        return None
    if result.returncode != 0:
        errors = [l for l in result.stderr.splitlines() if "WARNING" in l or "ERROR" in l]
        raise RuntimeError(f"{os.path.basename(scad)}: openscad exited {result.returncode}: {'; '.join(errors)}")
    return measure(out)


def call(openscad, tmp, body):
    scad = os.path.join(tmp, "call.scad")
    with open(scad, "w") as f:
        f.write(f"use <{LIB}>;\n$fn = 64;\n{body}\n")
    return render(openscad, scad, os.path.join(tmp, "call.stl"))


# (label, OpenSCAD source, solids, x, y, z). At $fn = 64 a circle's y extent
# is a little under its diameter.
SHAPES = [
    ("snapfit()", "snapfit();", 1, 3.75, 3.69, 7.875),
    ("snapfit(thickness=1)", "snapfit(thickness=1);", 1, 4.30, 4.25, 7.875),
    ("snapfit(under_chamfer_angle=45)", "snapfit(under_chamfer_angle=45);", 1, 3.75, 3.69, 7.875),
    ("snapfit_neg()", "snapfit_neg();", 1, 4.75, 4.75, 8.375),
    ("snapfit_neg(thickness=1)", "snapfit_neg(thickness=1);", 1, 4.75, 4.75, 3.375),
    ("snapfit_neg(under_chamfer_angle=45)", "snapfit_neg(under_chamfer_angle=45);", 1, 4.75, 4.75, 8.375),
    # What the under chamfer adds: below the head, the 45 degree cone is wider
    # than the column for 0.47 mm (split in two by the slot) ...
    (
        "under chamfer, positive",
        "difference() { snapfit(under_chamfer_angle=45); snapfit(); }",
        2, 3.75, 3.69, 0.475,
    ),
    # ... and its clearance is wider than the hole for 0.75 mm.
    (
        "under chamfer, negative",
        "difference() { snapfit_neg(under_chamfer_angle=45); snapfit_neg(); }",
        1, 4.75, 4.75, 0.75,
    ),
]

EXAMPLES = [
    # base 5 + column 6 + head 1.875
    ("self_connecting_snap.scad", 1, 10, 10, 12.875),
    # base 3 + column 2 + head 3
    ("pcb_feet_tpu.scad", 1, 10, 10, 8),
]


def main():
    openscad = sys.argv[1] if len(sys.argv) > 1 else "openscad"
    failures = []

    def check(label, got, want):
        solids, *size = want
        if got is None:
            print(f"FAIL {label}: empty, expected {solids} solids")
            failures.append(f"{label}: empty, expected {solids} solids")
            return
        ok = got[0] == solids and all(abs(a - b) <= 0.01 for a, b in zip(got[1], size))
        line = f"{got[0]} solids, {' x '.join(f'{s:.2f}' for s in got[1])} mm"
        print(f"{'ok  ' if ok else 'FAIL'} {label}: {line}")
        if not ok:
            failures.append(f"{label}: {line}, expected {solids} solids, {' x '.join(f'{s:.2f}' for s in size)} mm")

    with tempfile.TemporaryDirectory() as tmp:
        out = os.path.join(tmp, "case.stl")

        for label, body, *want in SHAPES:
            check(label, call(openscad, tmp, body), want)

        for name, *want in EXAMPLES:
            check(f"examples/{name}", render(openscad, os.path.join(ROOT, "examples", name), out), want)

        # Seated, the two copies only touch.
        seated = render(openscad, FIT, out, ["OFFSET=10"])
        print(f"{'ok  ' if seated is None or seated[1][2] <= 0.001 else 'FAIL'} seated: "
              + ("no overlap" if seated is None else f"overlap {seated[1][2]:.3f} mm tall"))
        if seated is not None and seated[1][2] > 0.001:
            failures.append(f"seated copies overlap {seated[1][2]:.3f} mm")

        # 0.1 mm closer, the foot runs into the upper copy, so the check can
        # see an overlap.
        closer = render(openscad, FIT, out, ["OFFSET=9.9"])
        check("0.1 mm closer than seated", closer, (2, 4.30, 4.25, 0.10))

        # Lifted 1 mm, the head sits in the upper copy's hole and is wider
        # than it: the two halves of the slotted head overlap the plate. That
        # interference is the snap.
        lifted = render(openscad, FIT, out, ["OFFSET=11"])
        check("lifted 1 mm (the snap's lip)", lifted, (2, 3.75, 3.70, 0.43))

        # flip = true is the negative mirrored top to bottom.
        for t, height in (("undef", 8.375), ("1", 3.375)):
            flipped = f"snapfit_neg(thickness={t}, flip=true)"
            mirrored = f"translate([0, 0, {height}]) mirror([0, 0, 1]) snapfit_neg(thickness={t})"
            for a, b in ((flipped, mirrored), (mirrored, flipped)):
                rest = call(openscad, tmp, f"difference() {{ {a}; {b}; }}")
                label = f"flip mirrors the negative, thickness={t}"
                print(f"{'ok  ' if rest is None else 'FAIL'} {label}")
                if rest is not None:
                    failures.append(f"{label}: {rest[0]} solids left over")

    if failures:
        print("\nfailed:")
        for failure in failures:
            print(f"  {failure}")
    print("all checks passed" if not failures else f"{len(failures)} failed")
    sys.exit(1 if failures else 0)


main()
