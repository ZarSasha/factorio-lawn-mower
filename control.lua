local function destroy_all_corpses(info)
  -- Parameters:
  local corpses = info.corpses
  -- Clears corpses, raising event if minable.
  for _, corpse in pairs(corpses) do
    if corpse.minable then
      corpse.destroy({
        raise_destroy = true -- just in case
      })
    else
      corpse.destroy()
    end
  end
end

local function destroy_all_corpses_and_drop_any_items(info)
  -- Parameters:
  local surface = info.surface
  local corpses = info.corpses
  -- Clears corpses, raising event and dropping items if minable:
  for _, corpse in pairs(corpses) do
    if corpse.minable then
      for i = 1, 11 do
        local single_inventory = corpse.get_inventory(i)
        if single_inventory == nil then return end
        surface.spill_inventory({
          inventory     = single_inventory,
          position      = corpse.position,
          allow_belts   = false,
          enable_looted = true,
        })
      end
      corpse.destroy({
        raise_destroy = true -- just in case
      })
    else
      corpse.destroy()
    end
  end
end

local function clear_area(info)
  -- Parameters:
  local surface = info.surface
  local area    = info.area
  local range   = info.range or 0
  if range > 0 then
    area.left_top.x     = area.left_top.x     - range
    area.left_top.y     = area.left_top.y     - range
    area.right_bottom.x = area.right_bottom.x + range
    area.right_bottom.y = area.right_bottom.y + range
  end
  -- Clear decoratitives:
  surface.destroy_decoratives({
    area = area
  })
  -- Clear corpses, optionally dropping any items:
  local corpses = surface.find_entities_filtered({
    area = area,
    type = "character-corpse"
  })
  if corpses == {} then return end
  if storage.settings.lawnmower_drop_minable_items then
    destroy_all_corpses_and_drop_any_items({
      surface = surface,
      corpses = corpses
    })
  else
    destroy_all_corpses({
      corpses = corpses}
    )
  end
end

-- EVENTS

script.on_event({
    defines.events.on_player_selected_area,
    defines.events.on_player_alt_selected_area
}, function(event)
  if event.item ~= "lawnmower-lawnmower" then return end
  clear_area({
    surface = event.surface,
    area    = event.area
  })
end)

script.on_event({
    defines.events.on_built_entity,       -- entity
    defines.events.on_robot_built_entity, -- entity
    defines.events.script_raised_built,   -- entity
    defines.events.script_raised_revive,  -- entity
    defines.events.on_entity_cloned       -- destination
}, function(event)
  local entity = event.entity or event.destination
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

-- SETTINGS & INITIALIZATION

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