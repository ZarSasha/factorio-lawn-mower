--------------------------------------------------------------------------------
-- CLEAR DECORATIVES AND/OR CORPSES, WITH OPTIONAL ITEM DROPS
--------------------------------------------------------------------------------

-- Expands size of a selection area.
local function expand_area(info)
  local area  = info.area
  local range = info.range
  area.left_top.x     = area.left_top.x     - range
  area.left_top.y     = area.left_top.y     - range
  area.right_bottom.x = area.right_bottom.x + range
  area.right_bottom.y = area.right_bottom.y + range
end

-- Destroys corpses and drops any items.
local function destroy_corpses_drop_items(info)
  local surface = info.surface
  local corpses = info.corpses
  for _, corpse in pairs(corpses) do
    if not corpse.minable then
      corpse.destroy() goto continue
    end
    local temp_inventory = game.create_inventory(100) -- enough? enough.
    local position = corpse.position
    corpse.mine({ -- corpse remains if not fully emptied
      inventory = temp_inventory
    })
    surface.spill_inventory({ -- available since v2.0.51.
      inventory     = temp_inventory,
      position      = position,
      allow_belts   = false, -- not dropped on existing belts
      enable_looted = true,  -- walk over to pick up
    })
    temp_inventory.destroy()
    ::continue::
  end
end

-- Destroys corpses without dropping any items.
local function destroy_corpses_ignore_items(info)
  local corpses = info.corpses
  for _, corpse in pairs(corpses) do
    if not corpse.minable then
      corpse.destroy() goto continue
    end
    corpse.destroy({
      raise_destroy = true -- informs other mods, just in case
    })
    ::continue::
  end
end

-- Destroys corpses within a given area, optionally dropping items.
local function destroy_corpses_in_area(info)
  local surface = info.surface
  local area    = info.area
  local drops   = info.drops -- drops from minable corpses
  local corpses = surface.find_entities_filtered({
    area = area,
    type = "corpse" -- enemy corpses, tree stumps, remnants, scorch marks
  })
  if next(corpses) == nil then return end
  if drops then
    destroy_corpses_drop_items({
      surface = surface,
      corpses = corpses
    })
  else
    destroy_corpses_ignore_items({
      corpses = corpses
    })
  end
end

-- Destroys decorations and/or corpses within a given area (configurable).
local function clear_area(info)
  local surface = info.surface
  local area    = info.area
  local range   = info.range or 0
  local alt     = info.alt or false
  if range > 0 then
    expand_area({
      area  = area,
      range = range
    })
  end
  if not alt then
    surface.destroy_decoratives({
      area = area
    })
  end
  do
    destroy_corpses_in_area({
      surface = surface,
      area    = area,
      drops   = storage.settings.drop_minable_items
    })
  end
end

-- SCRIPTS: CLEAR AREA WITH LAWNMOWER AREA SELECTION TOOL --

-- Clears decorations and corpses with the normal selection mode.
script.on_event({
  defines.events.on_player_selected_area,
}, function(event)
  if event.item ~= "lawnmower-lawnmower" then return end
  clear_area({
    surface = event.surface,
    area    = event.area,
    drops   = storage.settings.drop_minable_items
  })
end)

-- Clears corpses only with the alternative selection mode.
script.on_event({
  defines.events.on_player_alt_selected_area
}, function(event)
  if event.item ~= "lawnmower-lawnmower" then return end
  clear_area({
    surface = event.surface,
    area    = event.area,
    drops   = storage.settings.drop_minable_items,
    alt     = true
  })
end)

-- SCRIPTS: CLEAR VICINITY WHEN BUILDING --

-- Clears decorations and corpses when placing down entities/tiles.
script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive
}, function(event)
  local entity = event.entity
  if entity == nil or
     entity.type == "entity-ghost" or
     entity.type == "tile-ghost" or
     not entity.prototype.selectable_in_game then
    return
  end
  clear_area({
    surface = game.surfaces[entity.surface_index],
    area    = entity.selection_box,
    range   = storage.settings.building_clear_range,
    drops   = storage.settings.drop_minable_items
  })
end)

-- STORAGE TABLE INITIALIZATION & CACHING OF VALUES FROM SETTINGS --

local function cacheSettings()
  storage.settings = {} -- simple reset
  storage.settings.building_clear_range =
    settings.global["lawnmower-building-clear-range"].value
  storage.settings.drop_minable_items =
    settings.global["lawnmower-drop-minable-items"].value
end

-- SCRIPTS: CACHED VALUES UPDATE --

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting ~= "lawnmower-building-clear-range" and
     event.setting ~= "lawnmower-drop-minable-items" then
    return
  end
  cacheSettings()
end)

script.on_init(function()
  cacheSettings()
end)

script.on_configuration_changed(function()
  cacheSettings()
end)

--------------------------------------------------------------------------------