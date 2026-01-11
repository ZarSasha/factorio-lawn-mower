data:extend({
  {
    type = "shortcut",
    name = "lawnmower-give-lawnmower",
    order = "z",
    action = "spawn-item",
    item_to_spawn = "lawnmower-lawnmower",
    style = "green",
    icon = "__lawn-mower__/graphics/icons/lawn-mower-white-32.png",
    small_icon = "__lawn-mower__/graphics/icons/lawn-mower-white-32.png",
    icon_size = 32,
    small_icon_size = 32,
  },
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
      started_sound = { filename = "__core__/sound/deconstruct-select-start.ogg" },
    },
    ["alt_select"] = {
      mode = {"nothing"},
      border_color = {r = 0.125, g = 0.447, b = 0.13, a = 0.251},
      cursor_box_type = "not-allowed",
      started_sound = { filename = "__core__/sound/deconstruct-select-start.ogg" },
    },
    flags = { "only-in-cursor", "not-stackable", "spawnable" }
  },
  {
    type = "sound",
    name = "lawnmower-lawnmowing-end",
    category = "gui-effect",
    filename = "__core__/sound/deconstruct-select-end.ogg"
  }
})