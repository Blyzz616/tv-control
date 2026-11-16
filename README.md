# tv-control

A four-button remote with a scroll wheel for the LG TV. It is driven through Home Assistant (Chaos).

- **Caps:** YouTube, Jellyfin, Netflix, Prime Video
- **Scroll wheel:** turn for TV volume, press to toggle TV power

It is based on the bedroom quad-button (2x M5Stack U025 Dual Button + Seeed XIAO ESP32-C6, powered over USB-C), plus the wheel and PCB from an M5Stack U186 Unit Scroll.

## Layout

| Path | What |
|------|------|
| `enclosure/quad-base/` | The bedroom quad-button design, unchanged: `.scad`, STLs, renders. The reference path to the unit model was fixed to `../ref/`. |
| `enclosure/tv_remote.scad` | The working enclosure. `scroll_mount = "top"` or `"side"` (v0, see status) and the layered cap artwork. |
| `enclosure/ref/` | M5 reference models: the U025 unit and the U186 Unit Scroll. `scroll_parts/` holds the U186 split into its separate parts, in the shell's own frame. |
| `caps/` | The cap artwork pipeline: SVG to OpenSCAD layers to cap + insert. See `caps/README.md`. |
| `esphome/tv-control.yaml` | Device firmware config. |
| `homeassistant/scripts.yaml` | The Chaos scripts the device calls. |

## Status

- **Scroll wheel mount:** pending. The goal is the wheel sticking out past the top face, the front face (the side opposite USB-C) and the corner between them, between caps 2 and 3, in a new printed cradle that holds the bare U186 PCB and wheel. This is waiting on caliper measurements and photos of the U186 PCB.
  - The `top` and `side` variants in `tv_remote.scad` are v0 explorations that reuse M5's shell geometry. They are kept for reference and are not the final design.
- **Caps:** the pipeline is done and tested with test shapes. The SVGs for the four caps still need to be added to `caps/svg/`.
- **ESPHome:** `esphome config` passes (ESPHome 2026.10.2, including M5's `unit_scroll` external component). **It has not been compiled yet.**
  - D4/D5 = GPIO22/23 for I2C is unverified.
  - The scroll-button polarity is unverified.
- **Home Assistant scripts:** untested. The entity IDs `media_player.lg_tv` and `button.lg_tv_wol` must be confirmed first.
