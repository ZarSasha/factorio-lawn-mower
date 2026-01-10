require("prototypes.shortcuts")

data:extend({
  {
    type = "selection-tool",
    name = "lawnmower-lawnmower",
    icon = "__lawn-mower__/graphics/icons/lawn-mower-white-32.png",
    icon_size = 32,
    icon_mipmaps = 0,
    stack_size = 1,
    subgroup = "other",
    ["select"] = {
      mode = {"nothing"},
      border_color = {r = 0.125, g = 0.447, b = 0.13, a = 0.051},
      cursor_box_type = "not-allowed",
      -- "blueprint-snap-rectangle"
    },
    ["alt_select"] = {
      mode = {"nothing"},
      border_color = {r = 0.125, g = 0.447, b = 0.13, a = 0.051},
      cursor_box_type = "not-allowed" -- "blueprint-snap-rectangle"
    },
    flags = { "only-in-cursor", "not-stackable", "spawnable" },
  }
})