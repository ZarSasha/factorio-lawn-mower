function clear_area(info)
  local surface = info.surface
  local area    = info.area
  local range   = info.range or 0
  if range > 0 then
    area.left_top.x = area.left_top.x - range
    area.left_top.y = area.left_top.y - range
    area.right_bottom.x = area.right_bottom.x + range
    area.right_bottom.y = area.right_bottom.y + range
  end
  surface.destroy_decoratives({area = area})

  local temp_inventory -- was nil, which just deletes variable in lua!
  if storage.settings.lawnmower_drop_minable_items then
    temp_inventory = game.create_inventory(0)
  end

  local corpses = surface.find_entities_filtered({area = area, type = "corpse"})
  for _, corpse in pairs(corpses) do
    if corpse.minable and storage.settings.lawnmower_drop_minable_items then
      local position = corpse.position                          -- not used for anything!
      local result = corpse.mine{inventory = temp_inventory}    -- not used for anything!
    end
    corpse.destroy()
  end

  if storage.settings.lawnmower_drop_minable_items then
    temp_inventory.destroy()
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

--[[ 
local function on_selected_area(event)
  if event.item ~= "lawnmower-lawnmower" then return end
  local surface = event.surface
  local area = event.area
  clear_area(surface, area)
end

function on_selected_area(event, alt_selected) -- second arg not used for anything!
  if (event.item ~= "lawnmower-lawnmower") then return end

  local surface = event.surface
  local area = event.area

  clear_area(surface, area)
end

script.on_event(defines.events.on_player_selected_area, function(event)
  on_selected_area(event, false)
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
  on_selected_area(event, true)
end)
]]

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

--[[ 
script.on_event(defines.events.on_built_entity, function(event)
  if event.entity == nil or
     event.entity.type == "entity-ghost" or
     event.entity.type == "tile-ghost" or
     not event.entity.prototype.selectable_in_game then
      return
  end

  local surface = game.surfaces[event.entity.surface_index]
  local area = event.entity.selection_box

  clear_area(surface, area, storage.settings.lawnmower_building_clear_range)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  if event.entity.type == "entity-ghost" or
     event.entity.type == "tile-ghost" or
     not event.entity.prototype.selectable_in_game then
      return
  end

  local surface = game.surfaces[event.entity.surface_index]
  local area = event.entity.selection_box

  clear_area(surface, area, storage.settings.lawnmower_building_clear_range)
end)

script.on_event(defines.events.script_raised_built, function(event)
  if event.entity.type == "entity-ghost" or
     event.entity.type == "tile-ghost" or
     not event.entity.prototype.selectable_in_game then
      return
  end

  local surface = game.surfaces[event.entity.surface_index]
  local area = event.entity.selection_box

  clear_area(surface, area, storage.settings.lawnmower_building_clear_range)
end)

script.on_event(defines.events.script_raised_revive, function(event)
  if event.entity.type == "entity-ghost" or
     event.entity.type == "tile-ghost" or
     not event.entity.prototype.selectable_in_game then
      return
  end

  local surface = game.surfaces[event.entity.surface_index]
  local area = event.entity.selection_box

  clear_area(surface, area, storage.settings.lawnmower_building_clear_range)
end)
]]

-- SETTINGS & INITIALIZATION

function cacheSettings()
  storage.settings = {}
  storage.settings.lawnmower_building_clear_range =
    settings.global["lawnmower-building-clear-range"].value
  storage.settings.lawnmower_drop_minable_items =
    settings.global["lawnmower-drop-minable-items"].value
end

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