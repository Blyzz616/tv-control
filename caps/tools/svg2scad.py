#!/usr/bin/env python3
"""Convert shapes from an SVG into OpenSCAD polygon data for the cap artwork.

Each --layer picks a set of shapes from the SVG and becomes one OpenSCAD variable.
All layers from one SVG share the SVG's viewBox frame, normalised so the viewBox
width = 1.0 and its centre is at the origin (Y up). The cap scales it by art_size.

Shape selection (per layer, combine as needed):
    id=left,right        shapes whose id (or an ancestor <g>'s id) is listed
    fill=#fff,#ffffff    shapes whose resolved fill colour matches (gradients never match)
    index=2,3            filled shapes by position in document order, from 1 (run --list to see them)
    all                  every filled shape
Optional third field, after another colon:
    solid                fill every hole (outer outlines only)
    holes                only the holes, as solid shapes (e.g. the play triangle cut out of a frame)
Colour is otherwise ignored.

Fill rules: each shape's subpaths are combined with its own fill-rule
(evenodd, or nonzero approximated by winding), then the selected shapes are unioned.

Usage:
    python svg2scad.py IN.svg OUT.scad --prefix youtube --layer main:fill=#fff
    python svg2scad.py IN.svg OUT.scad --prefix yt --layer frame:fill=#fff:solid --layer play:fill=#fff:holes
    python svg2scad.py IN.svg OUT.scad --prefix nflx \
        --layer left:id=left --layer right:id=right --layer diag:id=diag

Requires: pip install svgelements shapely
"""
import argparse
import sys

from shapely.geometry import Polygon, MultiPolygon, GeometryCollection
from shapely.ops import unary_union
from shapely.validation import make_valid
import svgelements as se


def norm_colour(c):
    c = c.strip().lower()
    if c.startswith("#") and len(c) == 4:
        c = "#" + "".join(ch * 2 for ch in c[1:])
    return c


def walk(node, group_ids=()):
    """Yield shapes with the ids of all enclosing groups attached."""
    if isinstance(node, (se.Group, se.Use)):
        gid = node.values.get("id") if hasattr(node, "values") else None
        ids = group_ids + ((gid,) if gid else ())
        for child in node:
            yield from walk(child, ids)
    elif isinstance(node, se.Shape):
        node._group_ids = list(group_ids)
        yield node


def shape_to_geom(shape, tol):
    path = se.Path(shape)
    path.reify()
    rings = []
    for sub in path.as_subpaths():
        sp = se.Path(sub)
        length = sp.length(error=1e-3)
        if not length:
            continue
        n = max(16, int(length / tol))
        pts = [sp.point(i / n) for i in range(n + 1)]
        pts = [(p.x, p.y) for p in pts if p is not None]
        if len(pts) >= 3:
            rings.append(pts)
    if not rings:
        return None
    rule = (shape.values.get("fill-rule") or "nonzero").strip().lower()
    polys = [make_valid(Polygon(r)) for r in rings]
    polys = [p for p in polys if not p.is_empty and p.area > 0]
    if not polys:
        return None
    if rule == "evenodd":
        g = polys[0]
        for p in polys[1:]:
            g = g.symmetric_difference(p)
        return g
    # nonzero: rings wound opposite to the largest ring become holes when contained
    def signed_area(r):
        a = 0.0
        for (x1, y1), (x2, y2) in zip(r, r[1:] + r[:1]):
            a += x1 * y2 - x2 * y1
        return a / 2
    order = sorted(range(len(rings)), key=lambda i: -abs(signed_area(rings[i])))
    ref = signed_area(rings[order[0]]) >= 0
    g = None
    for i in order:
        p = make_valid(Polygon(rings[i]))
        same = (signed_area(rings[i]) >= 0) == ref
        if g is None:
            g = p
        elif same:
            g = g.union(p)
        else:
            g = g.difference(p)
    return g


def polygons_of(g):
    if g is None or g.is_empty:
        return []
    if isinstance(g, Polygon):
        return [g]
    if isinstance(g, (MultiPolygon, GeometryCollection)):
        out = []
        for part in g.geoms:
            out.extend(polygons_of(part))
        return out
    return []


def to_scad(name, geom, cx, cy, scale):
    points, paths = [], []

    def add_ring(coords):
        coords = list(coords)[:-1]
        idx = []
        for x, y in coords:
            idx.append(len(points))
            points.append(((x - cx) * scale, -(y - cy) * scale))
        paths.append(idx)

    for poly in polygons_of(geom):
        add_ring(poly.exterior.coords)
        for hole in poly.interiors:
            add_ring(hole.coords)
    pts = ",".join(f"[{x:.5f},{y:.5f}]" for x, y in points)
    pth = ",".join("[" + ",".join(map(str, p)) + "]" for p in paths)
    return f"{name} = [[{pts}],[{pth}]];\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("svg")
    ap.add_argument("out")
    ap.add_argument("--prefix", required=True, help="variable name prefix, e.g. youtube")
    ap.add_argument("--list", action="store_true", help="list the filled shapes (index, id, fill, bounds) and exit")
    ap.add_argument("--layer", action="append", default=[],
                    help="NAME:SELECTOR[:solid|holes], selector = all | id=a,b | fill=#hex,#hex | index=n,m (repeatable)")
    ap.add_argument("--tol", type=float, default=0.0, help="curve step in SVG units (default: viewBox width / 400)")
    a = ap.parse_args()

    doc = se.SVG.parse(a.svg, reify=True)
    vb = doc.viewbox
    if vb is not None:
        vx, vy, vw, vh = vb.x, vb.y, vb.width, vb.height
    else:
        vx, vy, vw, vh = 0, 0, doc.width, doc.height
    # svgelements applies the viewBox->viewport transform; undo it by working in viewport units
    sx = doc.width / vw if vw else 1.0
    cx = (vx + vw / 2) * sx
    cy = (vy + vh / 2) * sx
    width = vw * sx
    tol = a.tol * sx if a.tol else width / 400
    scale = 1.0 / width

    shapes = []
    for s in walk(doc):
        fill = s.fill
        if fill is None or getattr(fill, "value", 1) is None:
            continue
        op = s.values.get("fill-opacity")
        if (isinstance(fill, se.Color) and fill.alpha == 0) or (op is not None and float(op) == 0):
            continue   # invisible (e.g. a stroke-only copy of a shape)
        shapes.append(s)
    if a.list:
        for n, s in enumerate(shapes, 1):
            g = shape_to_geom(s, tol)
            b = g.bounds if g is not None and not g.is_empty else (0, 0, 0, 0)
            ids = ([s.id] if s.id else []) + list(getattr(s, "_group_ids", []))
            f = s.fill.hex if isinstance(s.fill, se.Color) else str(s.fill)
            print(f"{n:3d}  id={','.join(ids) or '-':20s} fill={f:12s} "
                  f"x {((b[0]-cx)*scale):+.3f}..{((b[2]-cx)*scale):+.3f}  y {(-(b[3]-cy)*scale):+.3f}..{(-(b[1]-cy)*scale):+.3f}")
        return
    if not a.layer:
        sys.exit("give at least one --layer (or --list)")
    out = [f"// generated by svg2scad.py from {a.svg}\n// frame: viewBox width = 1.0, centre at origin, Y up\n"]
    names = []
    for spec in a.layer:
        lname, _, rest = spec.partition(":")
        sel, _, mode = rest.partition(":")
        if mode not in ("", "solid", "holes"):
            sys.exit(f"unknown mode '{mode}' in {spec}")
        kind, _, vals = sel.partition("=")
        wanted = [v.strip() for v in vals.split(",") if v.strip()]
        picked = []
        for n, s in enumerate(shapes, 1):
            fill = s.fill
            if kind == "all":
                ok = True
            elif kind == "id":
                ids = ([s.id] if s.id else []) + list(getattr(s, "_group_ids", []))
                ok = any(i in wanted for i in ids)
            elif kind == "index":
                ok = str(n) in wanted
            elif kind == "fill":
                ok = isinstance(fill, se.Color) and norm_colour(fill.hex) in [norm_colour(w) for w in wanted]
                if ok and fill.alpha == 0:
                    ok = False
            else:
                sys.exit(f"unknown selector '{kind}' in {spec}")
            if ok:
                picked.append(s)
        if not picked:
            sys.exit(f"layer {lname}: no shapes matched '{sel}'")
        geom = unary_union([g for g in (shape_to_geom(s, tol) for s in picked) if g is not None])
        geom = geom.simplify(tol * 0.25)
        if mode == "solid":
            geom = unary_union([Polygon(p.exterior) for p in polygons_of(geom)])
        elif mode == "holes":
            geom = unary_union([Polygon(h) for p in polygons_of(geom) for h in p.interiors])
            if geom.is_empty:
                sys.exit(f"layer {lname}: selection has no holes")
        var = f"{a.prefix}_{lname}"
        names.append(var)
        out.append(to_scad(var, geom, cx, cy, scale))
        b = geom.bounds
        print(f"{var}: {len(picked)} shape(s), bounds x {((b[0]-cx)*scale):.3f}..{((b[2]-cx)*scale):.3f}, "
              f"y {(-(b[3]-cy)*scale):.3f}..{(-(b[1]-cy)*scale):.3f} (viewBox width = 1)")
    with open(a.out, "w") as f:
        f.writelines(out)
    print(f"wrote {a.out}: {', '.join(names)}")


if __name__ == "__main__":
    main()
