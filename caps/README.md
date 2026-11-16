# Button caps

Each cap is the quad-button rocker cap (`enclosure/tv_remote.scad`) with pockets for glue-in artwork **pieces**.

- A piece sits in a pocket in the cap or in a pocket in another piece, so pieces can nest.
- Each piece has a flat bottom.
- Its top can be flush, recessed or sloped.
- Print each piece in its own colour.

| Cap | App | Slot | Pieces |
|-----|-----|------|--------|
| 1 | YouTube | A | TV shape (red) in the cap; play triangle (white) in the TV shape |
| 2 | Jellyfin | B | outer fin and inner fin, both in the cap |
| 3 | Netflix | A | left leg, right leg and diagonal. Two-level pocket: the legs sit deeper, and their tops slope down to the right |
| 4 | Prime Video | B | the "a" and the swoosh, as one piece in the cap |

The slot only rotates the artwork, so that it reads upright from the front of the box (the side opposite the USB-C port).

## Workflow

1. Put the SVG in `svg/<name>.svg`.
2. List the filled shapes. Each one is printed with its index, id, fill and bounds. Invisible shapes, such as stroke-only copies, are skipped.

   ```
   cd caps/tools
   pip install svgelements shapely
   python svg2scad.py ../svg/netflix.svg ../gen/netflix.scad --prefix netflix --list
   ```

3. Generate the layers. The exact command for each cap is in the comment at the top of its `.scad` file.
   - Selectors: `all`, `id=a,b`, `fill=#hex`, `index=n,m`. Gradient fills never match `fill=`, so select those by index or id.
   - Modes, added as a third field: `:solid` fills holes, and `:holes` keeps only the holes. For example, `--layer tv:fill=#fff:solid --layer play:fill=#fff:holes` splits a frame from its cut-out.
   - Leave background shapes out of every layer.
4. Open the cap file in OpenSCAD.
   - `part = "cap_preview"` shows everything together.
   - `part = "cap"` exports the cap. Print it top face down.
   - `part = "piece"` with `piece = n` exports piece n. Print it flat side down.

## Piece format

`art_pieces = [[layer, parent, bottom, h_start, h_end, angle, colour], ...]`

- **parent:** `-1` is the cap. `n` means the piece sits in a pocket in piece n (an earlier piece).
- **bottom:** the depth of the flat bottom, in mm below the cap top. The parent's pocket is cut to this depth.
- **h_start, h_end, angle:** the top surface, in mm relative to the cap top (0 is flush). It runs linearly across the piece's own extent along `angle`: `0` runs left to right and `90` bottom to top, with the artwork upright.
- **colour:** preview only.
- Where pieces with the same parent overlap, the later one wins.
- **Warnings:** OpenSCAD echoes a warning if a piece, a pocket floor in a piece, or the cap floor gets thinner than `art_min_t` (0.6 mm). The cap's top disk is 3 mm.
- `art_size` (30 mm) is the width that the SVG viewBox is scaled to. `art_clear` (0.1 mm per side) is the piece-to-pocket fit; tune it after a test print.

## Tests

`test/` uses original test shapes. The cap and every piece render as closed meshes, and the pieces and pockets were checked for zero overlap.
- `test_cap_nested.scad`: a frame in the cap, with its cut-out shape nested in the frame. See `nested_exploded.png`.
- `test_cap_layers.scad`: a two-level pocket with sloped tops. The slope heights were checked by ray-casting the exported pieces.
