--------------------------------------------------------------------------------
-- CLEAR DECORATIONS AND/OR CORPSES, WITH OPTIONAL ITEM DROPS
--------------------------------------------------------------------------------

-- FUNCTION FOR INCREASING SIZE OF AREA --

-- Expands size of bounding box or selection area with a given value.
local function expand_selection_area(info)
  local area   = info.area -- apparently no need to check for long format
  local offset = info.offset
  if offset == 0 then return end
  area.left_top.x     = area.left_top.x     - offset
  area.left_top.y     = area.left_top.y     - offset
  area.right_bottom.x = area.right_bottom.x + offset
  area.right_bottom.y = area.right_bottom.y + offset
end

-- FUNCTIONS FOR DESTROYING CORPSES --

-- Alternative 1: Destroys corpses and drops any items.
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

-- Alternative 2: Destroys corpses and drops no items.
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

-- Main function: Destroys corpses within area, optionally drops items.
local function destroy_corpses_in_area(info)
  local surface = info.surface
  local area    = info.area
  local drops   = info.drops
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

-- MAIN FUNCTION FOR CLEARING DECORATIONS AND CORPSES --

-- Destroys decorations and/or corpses within a given area (configurable).
local function clear_area(info)
  local surface = info.surface
  local area    = info.area
  local offset  = info.offset -- area radius increase
  local alt     = info.alt    -- for alternative mode
  if offset then
    expand_selection_area({
      area   = area,
      offset = offset
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

-- Normal selection mode: Clears decorations and corpses.
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

-- Alternative selection mode: Clears corpses only.
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
    offset  = storage.settings.building_clear_range,
    drops   = storage.settings.drop_minable_items
  })
end)

-- STORAGE TABLE INITIALIZATION & CACHING OF VALUES FROM RUNTIME SETTINGS --

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