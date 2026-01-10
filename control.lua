--------------------------------------------------------------------------------
-- CLEARING AREA OF DECORATIVES AND/OR CORPSES, WITH OPTIONAL ITEM DROPS
--------------------------------------------------------------------------------

-- For use with item drops turned off.
local function destroy_all_corpses(info)
  local corpses = info.corpses
  -- Clears corpses, raises event if minable:
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

-- For use with item drops turned on.
local function destroy_all_corpses_and_drop_items(info)
  local surface = info.surface
  local corpses = info.corpses
  -- Clears corpses, raises event if minable and drops items on ground:
  for _, corpse in pairs(corpses) do
    if not corpse.minable then
      corpse.destroy() goto continue
    end
    local temp_inventory = game.create_inventory(5) -- increase?
    local position = corpse.position
    
    corpse.mine({ -- deletes corpse when fully mined of items
      inventory = temp_inventory
    })
    surface.spill_inventory({
      inventory     = temp_inventory,
      position      = position,
      allow_belts   = false, -- not moved by existing belts
      enable_looted = true,  -- walk over to pick up
    })
    temp_inventory.destroy()
    ::continue::
  end
end

-- Main function for clearing area (configurable).
local function clear_area(info)
  local surface = info.surface
  local area    = info.area
  local range   = info.range or 0
  local alt     = info.alt or false
  -- Optionally increases size of affected area:
  if range > 0 then
    area.left_top.x     = area.left_top.x     - range
    area.left_top.y     = area.left_top.y     - range
    area.right_bottom.x = area.right_bottom.x + range
    area.right_bottom.y = area.right_bottom.y + range
  end
  -- Clears decoratives by default:
  if not alt then
    surface.destroy_decoratives({
      area = area
    })
  end
  -- Clears corpses, optionally drops any items:
  local corpses = surface.find_entities_filtered({
    area = area,
    type = "character-corpse"
  })
  if corpses == {} then return end
  if storage.settings.lawnmower_drop_minable_items then
    destroy_all_corpses_and_drop_items({
      surface = surface,
      corpses = corpses
    })
  else
    destroy_all_corpses({
      corpses = corpses
    })
  end
end

-- SCRIPTS: CLEAR AREA WITH AREA SELECTION TOOL --

-- Clears decoratives and corpses with the normal selection mode.
script.on_event({
    defines.events.on_player_selected_area,
}, function(event)
  if event.item ~= "lawnmower-lawnmower" then return end
  clear_area({
    surface = event.surface,
    area    = event.area
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
    alt     = true
  })
end)

-- SCRIPTS: CLEAR AREA WHEN BUILDING --

-- Clears decoratives and corpses when placing down entities/tiles.
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
    range   = storage.settings.lawnmower_building_clear_range
  })
end)


-- SCRIPTS: STORAGE TABLE INITIALIZATION & CACHING OF SETTINGS --

-- Caches values of settings, improving performance especially with many mods.
local function cacheSettings()
  storage.settings = {}
  storage.settings.lawnmower_building_clear_range =
    settings.global["lawnmower-building-clear-range"].value
  storage.settings.lawnmower_drop_minable_items =
    settings.global["lawnmower-drop-minable-items"].value
end

script.on_event(
  defines.events.on_runtime_mod_setting_changed, function(event)
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