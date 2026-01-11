data:extend({
  {
    type = "shortcut",
    name = "lawnmower-give-lawnmower",
    associated_control_input = "lawnmower-give-lawnmower",
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
    type = "custom-input",
    name = "lawnmower-give-lawnmower",
    key_sequence = "",
    consuming = "game-only",
    item_to_spawn = "lawnmower-lawnmower",
    action = "spawn-item"
  },
  {
    type = "selection-tool",
    name = "lawnmower-lawnmower",
    icon = "__lawn-mower__/graphics/icons/lawn-mower-white-32.png",
    icon_size = 32,
    icon_mipmaps = 0,
    flags = {"only-in-cursor", "not-stackable", "spawnable"},
    subgroup = "other",
    stack_size = 1,
    select = {
      mode = {"nothing"},
      border_color = {r = 0.125, g = 0.447, b = 0.13, a = 0.051},
      cursor_box_type = "not-allowed",
      started_sound = {filename = "__core__/sound/deconstruct-select-start.ogg"},
      ended_sound = {filename = "__core__/sound/deconstruct-select-end.ogg"},
      play_ended_sound_when_nothing_selected = true
    },
    alt_select = {
      mode = {"nothing"},
      border_color = {r = 0.125, g = 0.447, b = 0.13, a = 0.301},
      cursor_box_type = "not-allowed",
      started_sound = {filename = "__core__/sound/deconstruct-select-start.ogg"},
      ended_sound = {filename = "__core__/sound/deconstruct-select-end.ogg"},
      play_ended_sound_when_nothing_selected = true
    }
    --skip_fog_of_war = true
  }
})