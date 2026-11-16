# Button caps

Each cap is the quad-button rocker cap (`enclosure/tv_remote.scad`) with a pocket for a glue-in artwork insert.
The insert has a flat bottom and a top surface built from one or more SVG layers. Each layer has its own height, and that height can slope.

| Cap | Position | Slot | File |
|-----|----------|------|------|
| 1 | YouTube | A | `youtube.scad` |
| 2 | Jellyfin | B | `jellyfin.scad` |
| 3 | Netflix | A | `netflix.scad` |
| 4 | Prime Video | B | `prime.scad` |

The slot only rotates the artwork, so that it reads upright from the front of the box (the side opposite the USB-C port).
Caps 1 and 3 face one way, 2 and 4 the other.

## Workflow

1. Put the SVG in `svg/` (for example `svg/youtube.svg`).
   Colour is ignored: the cap prints in one colour and the insert in another.
2. List the shapes the converter can see:

   ```
   cd caps/tools
   pip install svgelements shapely
   python svg2scad.py ../svg/netflix.svg ../gen/netflix.scad --prefix netflix --list
   ```

   This prints each filled shape with an index, its id, its fill and its bounds. Gradient fills show as `#000000` and never match `fill=`, so select those by `index=` or `id=`.
3. Generate the layers. The `--prefix` and layer names must match the variables used in the cap file:

   ```
   python svg2scad.py ../svg/youtube.svg ../gen/youtube.scad --prefix youtube --layer main:fill=#fff
   python svg2scad.py ../svg/netflix.svg ../gen/netflix.scad --prefix netflix --layer left:index=2 --layer right:index=3 --layer diag:index=4
   ```

   Selectors: `all`, `id=a,b`, `fill=#hex,#hex`, `index=n,m`. Within a layer, shapes are unioned.
   Each shape keeps its own `fill-rule`, so holes such as a play triangle cut through.
   Background shapes such as a full circle or a rounded square: leave them out of every layer.
4. Open the cap file in OpenSCAD:
   - `part = "cap_preview"`: the cap and insert together
   - `part = "cap"`: export, print top face down (the same as the existing caps)
   - `part = "art_insert"`: export, print flat bottom down. This part must be a separate colour, or painted.

## Layer heights

`art_layers = [[layer, h_start, h_end, angle], ...]`

- Heights are mm relative to the cap top: `0` is flush and negative is recessed.
- The height runs linearly from `h_start` to `h_end` across that layer's own extent in the direction `angle`. `0` runs left to right and `90` runs bottom to top, with the artwork upright.
- Where layers overlap, later layers win.
- `art_pocket` (default 1.6 mm) is the pocket depth. The insert is `art_pocket + height` thick, and OpenSCAD echoes a warning if any part drops below `art_insert_min` (0.6 mm).
- `art_size` (default 30 mm) is the width that the SVG's viewBox is scaled to. Every layer from one SVG shares that frame.
- `art_insert_clear` (0.1 mm per side) is the fit of the insert in the pocket. Tune it after a test print.

## Tests

`test/` uses original test shapes:
- `test_cap_flat.scad`: a single layer with an even-odd hole.
- `test_cap_layers.scad`: three overlapping layers, two of them sloped.

Both render to closed meshes. The slope heights were checked by ray-casting the exported insert.
