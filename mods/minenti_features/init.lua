local vector = vector

local function inflate_box(center, radius)
    return vector.subtract(center, {x = radius, y = radius, z = radius}),
        vector.add(center, {x = radius, y = radius, z = radius})
end

local get_heat = minetest.get_heat or function(pos)
    local biome = minetest.get_biome_data(pos)
    return biome and biome.heat or 0
end

local get_humidity = minetest.get_humidity or function(pos)
    local biome = minetest.get_biome_data(pos)
    return biome and biome.humidity or 0
end

local function format_keys(keys)
    if type(keys) ~= "table" or #keys == 0 then
        return "keine Einträge"
    end
    return table.concat(keys, ", ")
end

minenti_features = {
    registry = {}
}

local feature_id = 1

local function register_feature(spec)
    spec.id = feature_id
    minenti_features.registry[feature_id] = spec
    minenti_features["feature_" .. feature_id] = function(player)
        return spec.activate(player)
    end
    feature_id = feature_id + 1
end

local function ensure_player(player)
    if player and player:is_player() then
        return player
    end
    return nil
end

local function reset_physics_after(name, delay, overrides)
    minetest.after(delay, function()
        local player = minetest.get_player_by_name(name)
        if player then
            player:set_physics_override(overrides)
            minetest.chat_send_player(name, "Dein temporärer Physik-Effekt ist beendet.")
        end
    end)
end

local function physics_feature(label, message, modifier)
    return function(player)
        player = ensure_player(player)
        if not player then
            return false, "Der Spieler konnte nicht gefunden werden."
        end
        local name = player:get_player_name()
        local original = player:get_physics_override()
        local overrides = {
            speed = modifier.speed or original.speed,
            jump = modifier.jump or original.jump,
            gravity = modifier.gravity or original.gravity,
        }
        player:set_physics_override(overrides)
        minetest.chat_send_player(name, message)
        reset_physics_after(name, modifier.duration or 20, original)
        return true, label
    end
end

local function particle_feature(label, description, color)
    return function(player)
        player = ensure_player(player)
        if not player then
            return false, "Der Spieler konnte nicht gefunden werden."
        end
        local name = player:get_player_name()
        local pos = vector.round(player:get_pos())
        local minpos, maxpos = inflate_box(pos, 1)
        minetest.add_particlespawner({
            amount = 64,
            time = 2,
            minpos = minpos,
            maxpos = maxpos,
            minvel = {x = -0.4, y = 0.1, z = -0.4},
            maxvel = {x = 0.4, y = 1.2, z = 0.4},
            minacc = {x = 0, y = 0.3, z = 0},
            maxacc = {x = 0, y = 0.8, z = 0},
            minexptime = 0.6,
            maxexptime = 1.8,
            minsize = 1,
            maxsize = 3,
            glow = 8,
            texture = "default_mese_crystal_fragment.png^[colorize:" .. color .. ":180",
            collisiondetection = false,
        })
        minetest.chat_send_player(name, description)
        return true, label
    end
end

local function heal_feature(label, description, amount)
    return function(player)
        player = ensure_player(player)
        if not player then
            return false, "Der Spieler konnte nicht gefunden werden."
        end
        local name = player:get_player_name()
        local hp = player:get_hp() or 20
        local max_hp = player:get_properties().hp_max or 20
        local new_hp = math.min(max_hp, hp + amount)
        player:set_hp(new_hp)
        minetest.chat_send_player(name, description .. " (+" .. amount .. " HP)")
        return true, label
    end
end

local function breath_feature(label, description, amount)
    return function(player)
        player = ensure_player(player)
        if not player then
            return false, "Der Spieler konnte nicht gefunden werden."
        end
        local name = player:get_player_name()
        local breath = player:get_breath() or 10
        local max_breath = player:get_properties().breath_max or 10
        local new_breath = math.min(max_breath, breath + amount)
        player:set_breath(new_breath)
        minetest.chat_send_player(name, description .. " (+" .. amount .. " Luft)")
        return true, label
    end
end

local function give_item_feature(label, description, itemstring)
    return function(player)
        player = ensure_player(player)
        if not player then
            return false, "Der Spieler konnte nicht gefunden werden."
        end
        local name = player:get_player_name()
        local stack = ItemStack(itemstring)
        local inv = player:get_inventory()
        local given = false
        if inv and inv:room_for_item("main", stack) then
            inv:add_item("main", stack)
            given = true
        end
        if not given then
            local pos = player:get_pos()
            minetest.add_item(pos, stack)
        end
        minetest.chat_send_player(name, description .. " (" .. itemstring .. ")")
        return true, label
    end
end

local function info_feature(label, description, generator)
    return function(player)
        player = ensure_player(player)
        if not player then
            return false, "Der Spieler konnte nicht gefunden werden."
        end
        local name = player:get_player_name()
        local info = generator(player)
        minetest.chat_send_player(name, description .. ": " .. info)
        return true, label
    end
end

local function schedule_feature(label, description, delay, payload)
    return function(player)
        player = ensure_player(player)
        if not player then
            return false, "Der Spieler konnte nicht gefunden werden."
        end
        local name = player:get_player_name()
        minetest.chat_send_player(name, description .. " In " .. delay .. " Sekunden!")
        minetest.after(delay, function()
            local current = minetest.get_player_by_name(name)
            if current then
                payload(current)
            end
        end)
        return true, label
    end
end

-- Geschwindigkeit (1-10)
for i = 1, 10 do
    local speed = 1 + i * 0.1
    register_feature({
        label = "Tempo" .. i,
        name = "speed_boost_" .. i,
        description = "Erhöht deine Laufgeschwindigkeit temporär auf " .. string.format("%.1f", speed) .. "x",
        activate = physics_feature(
            "Tempo" .. i,
            "Sprint-Schub " .. i .. " aktiviert!",
            {speed = speed, duration = 20}
        )
    })
end

-- Sprungkraft (11-20)
for i = 1, 10 do
    local jump = 1 + i * 0.15
    register_feature({
        label = "Sprung" .. i,
        name = "jump_boost_" .. i,
        description = "Erhöht deine Sprungkraft temporär auf " .. string.format("%.2f", jump) .. "x",
        activate = physics_feature(
            "Sprung" .. i,
            "Sprungkraft " .. i .. " aktiviert!",
            {jump = jump, duration = 20}
        )
    })
end

-- Gravitation (21-30)
for i = 1, 10 do
    local gravity = 1 - i * 0.05
    register_feature({
        label = "Schwerkraft" .. i,
        name = "gravity_shift_" .. i,
        description = "Verringert die Schwerkraft auf " .. string.format("%.2f", gravity) .. "x",
        activate = physics_feature(
            "Schwerkraft" .. i,
            "Schwerkraft-Entlastung " .. i .. " gestartet!",
            {gravity = gravity, duration = 25}
        )
    })
end

-- Partikel-Auren (31-40)
local aura_colors = {
    "#ff4d4d",
    "#ffa64d",
    "#fff54d",
    "#7dff4d",
    "#4dffda",
    "#4dd9ff",
    "#4d83ff",
    "#a54dff",
    "#ff4de2",
    "#ffffff",
}

for index, color in ipairs(aura_colors) do
    register_feature({
        label = "Aura" .. index,
        name = "aura_effect_" .. index,
        description = "Beschwört eine schillernde Aura in Farbe " .. color,
        activate = particle_feature("Aura" .. index, "Du bist von einer Aura " .. index .. " umgeben!", color)
    })
end

-- Heilung (41-50)
for i = 1, 10 do
    local amount = 1 + i
    register_feature({
        label = "Heilung" .. i,
        name = "healing_wave_" .. i,
        description = "Regeneriert " .. amount .. " Lebenspunkte sofort",
        activate = heal_feature("Heilung" .. i, "Eine warme Welle regeneriert dich", amount)
    })
end

-- Items (51-60)
local gift_items = {
    "default:torch 4",
    "default:apple 2",
    "default:pick_steel 1",
    "default:shovel_stone 1",
    "default:axe_bronze 1",
    "default:diamond 1",
    "default:glass 8",
    "default:tree 6",
    "default:wood 12",
    "default:meselamp 2",
}

for index, item in ipairs(gift_items) do
    register_feature({
        label = "Geschenk" .. index,
        name = "gift_drop_" .. index,
        description = "Du erhältst ein Bonusgeschenk",
        activate = give_item_feature("Geschenk" .. index, "Geschenk " .. index .. " erhalten", item)
    })
end

-- Informationsfunktionen (61-70)
local info_generators = {
    function(player)
        local pos = player:get_pos()
        return string.format("Position: %.1f/%.1f/%.1f", pos.x, pos.y, pos.z)
    end,
    function(player)
        local yaw = player:get_look_horizontal()
        return string.format("Blickrichtung: %.2f rad", yaw)
    end,
    function(player)
        local dir = player:get_look_dir()
        return string.format("Richtung: %.2f %.2f %.2f", dir.x, dir.y, dir.z)
    end,
    function(player)
        local pos = player:get_pos()
        local node = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
        if node then
            return "Block unter dir: " .. node.name
        end
        return "Keine Blockdaten verfügbar"
    end,
    function(player)
        local meta = player:get_meta()
        local keys = meta.get_keys and meta:get_keys() or {}
        return "Metadaten-Keys: " .. format_keys(keys)
    end,
    function(player)
        local hp = player:get_hp()
        local max_hp = player:get_properties().hp_max or 20
        return string.format("Lebenspunkte: %d/%d", hp, max_hp)
    end,
    function(player)
        local breath = player:get_breath()
        local max_breath = player:get_properties().breath_max or 10
        return string.format("Luft: %d/%d", breath, max_breath)
    end,
    function(player)
        local physics = player:get_physics_override()
        return string.format("Physik: speed %.2f, jump %.2f, gravity %.2f", physics.speed, physics.jump, physics.gravity)
    end,
    function(player)
        local sky = player:get_sky()
        if type(sky) == "table" and sky.sky_color then
            return "Eigene Himmelsfarben aktiv"
        end
        return "Standard-Himmel aktiv"
    end,
    function(player)
        return "Spielername: " .. player:get_player_name()
    end,
}

for index, generator in ipairs(info_generators) do
    register_feature({
        label = "Info" .. index,
        name = "info_ping_" .. index,
        description = "Zeigt dir besondere Statusinformationen",
        activate = info_feature("Info" .. index, "Analyse " .. index, generator)
    })
end

-- Atem (71-80)
for i = 1, 10 do
    local boost = 1 + i
    register_feature({
        label = "Atem" .. i,
        name = "breath_refresh_" .. i,
        description = "Füllt deine Luft um " .. boost .. " Einheiten auf",
        activate = breath_feature("Atem" .. i, "Frische Luft füllt deine Lungen", boost)
    })
end

-- Geländesensoren (81-90)
local terrain_features = {
    {"Biom-Scanner", function(player)
        local pos = vector.round(player:get_pos())
        local heat, humidity = get_heat(pos), get_humidity(pos)
        return string.format("Hitze: %.1f, Feuchte: %.1f", heat, humidity)
    end},
    {"Nachtcheck", function(player)
        local tod = minetest.get_timeofday()
        return tod < 0.2 or tod > 0.8 and "Es ist Nacht" or "Taglicht vorhanden"
    end},
    {"Höhenmesser", function(player)
        local pos = player:get_pos()
        return string.format("Aktuelle Höhe: %.1f", pos.y)
    end},
    {"Wasserfinder", function(player)
        local pos = vector.round(player:get_pos())
        for dy = -1, 1 do
            local node = minetest.get_node_or_nil({x = pos.x, y = pos.y + dy, z = pos.z})
            if node and node.name and node.name:find("water") then
                return "Wasser in der Nähe entdeckt!"
            end
        end
        return "Kein Wasser in unmittelbarer Nähe"
    end},
    {"Lichtmesser", function(player)
        local pos = vector.round(player:get_pos())
        local light = minetest.get_node_light(pos) or 0
        return string.format("Lichtlevel: %d", light)
    end},
    {"Höhlenradar", function(player)
        local pos = vector.round(player:get_pos())
        for dy = -5, 5 do
            local node = minetest.get_node_or_nil({x = pos.x, y = pos.y + dy, z = pos.z})
            if node and node.name == "air" then
                return "Luftraum in der Nähe gefunden (Tiefe " .. dy .. ")"
            end
        end
        return "Keine Höhle in direkter Nähe"
    end},
    {"Pflanzenkunde", function(player)
        local pos = vector.round(player:get_pos())
        for _, offset in ipairs({{1,0,0},{-1,0,0},{0,0,1},{0,0,-1}}) do
            local node = minetest.get_node_or_nil({x = pos.x + offset[1], y = pos.y, z = pos.z + offset[3]})
            if node and node.name and node.name:find("flower") then
                return "Du riechst den Duft einer Blume neben dir!"
            end
        end
        return "Keine Blumen entdeckt"
    end},
    {"Erzdetektor", function(player)
        local pos = vector.round(player:get_pos())
        for dy = -3, 3 do
            for dx = -3, 3 do
                for dz = -3, 3 do
                    local node = minetest.get_node_or_nil({x = pos.x + dx, y = pos.y + dy, z = pos.z + dz})
                    if node and node.name and node.name:find("ore") then
                        return "Erz in der Nähe geortet!"
                    end
                end
            end
        end
        return "Keine Erze in der direkten Umgebung"
    end},
    {"Baumsucher", function(player)
        local pos = vector.round(player:get_pos())
        for dy = 0, 5 do
            local node = minetest.get_node_or_nil({x = pos.x, y = pos.y + dy, z = pos.z})
            if node and node.name and node.name:find("tree") then
                return "Baum über dir entdeckt"
            end
        end
        return "Kein Baum direkt über dir"
    end},
    {"Bodenanalyse", function(player)
        local pos = vector.round(player:get_pos())
        local node = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
        if node then
            return "Untergrund besteht aus " .. node.name
        end
        return "Keine Bodeninformationen"
    end},
}

for index, def in ipairs(terrain_features) do
    register_feature({
        label = "Terrain" .. index,
        name = "terrain_scan_" .. index,
        description = "Analysiert deine Umgebung",
        activate = info_feature("Terrain" .. index, def[1], def[2])
    })
end

-- Zeitgesteuerte Überraschungen (91-100)
local delayed_payloads = {
    function(player)
        local name = player:get_player_name()
        minetest.chat_send_player(name, "Eine freundliche Erinnerung: Trink etwas Wasser!")
    end,
    function(player)
        local name = player:get_player_name()
        minetest.chat_send_player(name, "Eine helle Blitzwolke funkelt auf!")
        local center = player:get_pos()
        local minpos, maxpos = inflate_box(center, 0.5)
        minetest.add_particlespawner({
            amount = 40,
            time = 1,
            minpos = minpos,
            maxpos = maxpos,
            minvel = {x = -0.2, y = 1, z = -0.2},
            maxvel = {x = 0.2, y = 2, z = 0.2},
            texture = "default_mese_crystal_fragment.png^[colorize:#ffffff:180",
            glow = 12,
        })
    end,
    function(player)
        local name = player:get_player_name()
        player:set_hp(math.min(player:get_properties().hp_max or 20, (player:get_hp() or 20) + 5))
        minetest.chat_send_player(name, "Verzögerte Heilung +5")
    end,
    function(player)
        local name = player:get_player_name()
        player:set_breath(player:get_properties().breath_max or 10)
        minetest.chat_send_player(name, "Deine Luftvorräte wurden komplett erneuert!")
    end,
    function(player)
        local name = player:get_player_name()
        local pos = player:get_pos()
        minetest.add_item(pos, "default:apple")
        minetest.chat_send_player(name, "Ein Apfel landet vor deinen Füßen.")
    end,
    function(player)
        local name = player:get_player_name()
        minetest.sound_play("default_dig_crumbly", {to_player = name, gain = 0.5})
        minetest.chat_send_player(name, "Sanftes Sandrieseln erklingt.")
    end,
    function(player)
        local name = player:get_player_name()
        local pos = player:get_pos()
        local minpos, maxpos = inflate_box(pos, 1)
        minetest.add_particlespawner({
            amount = 120,
            time = 3,
            minpos = minpos,
            maxpos = maxpos,
            minvel = {x = -0.4, y = 0.2, z = -0.4},
            maxvel = {x = 0.4, y = 1.4, z = 0.4},
            minsize = 1,
            maxsize = 4,
            texture = "default_mese_crystal_fragment.png",
            glow = 6,
        })
        minetest.chat_send_player(name, "Sternenregen ergießt sich über dir.")
    end,
    function(player)
        local name = player:get_player_name()
        minetest.chat_send_player(name, "Motivation: Du schaffst das Abenteuer!")
    end,
    function(player)
        local name = player:get_player_name()
        local pos = player:get_pos()
        local minpos, maxpos = inflate_box(pos, 0.3)
        minetest.add_particlespawner({
            amount = 60,
            time = 1.5,
            minpos = minpos,
            maxpos = maxpos,
            minvel = {x = -0.2, y = 0.5, z = -0.2},
            maxvel = {x = 0.2, y = 1.0, z = 0.2},
            texture = "default_water.png",
        })
        minetest.chat_send_player(name, "Schillernde Blasen schweben auf.")
    end,
    function(player)
        local name = player:get_player_name()
        local pos = player:get_pos()
        local minpos, maxpos = inflate_box(pos, 0.5)
        minetest.add_particlespawner({
            amount = 80,
            time = 2,
            minpos = minpos,
            maxpos = maxpos,
            minvel = {x = -0.1, y = 0.9, z = -0.1},
            maxvel = {x = 0.1, y = 1.3, z = 0.1},
            texture = "default_cloud.png",
        })
        minetest.chat_send_player(name, "Eine mystische Rauchwolke steigt empor.")
    end,
}

for index, payload in ipairs(delayed_payloads) do
    local delay = 5 + index
    register_feature({
        label = "Überraschung" .. index,
        name = "delayed_magic_" .. index,
        description = "Löst nach kurzer Zeit ein Minievent aus",
        activate = schedule_feature("Überraschung" .. index, "Überraschung " .. index .. " geplant.", delay, payload)
    })
end

minetest.register_chatcommand("minenti_feature", {
    params = "<id>",
    description = "Aktiviere eine der 100 Minenti-Features",
    func = function(name, param)
        local id = tonumber(param)
        if not id then
            return false, "Bitte gib eine Feature-ID zwischen 1 und " .. (#minenti_features.registry) .. " an."
        end
        local spec = minenti_features.registry[id]
        if not spec then
            return false, "Feature " .. id .. " existiert nicht."
        end
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Spieler nicht gefunden."
        end
        local ok, msg = spec.activate(player)
        if ok == false then
            return false, msg or "Aktivierung fehlgeschlagen"
        end
        return true, msg or ("Feature " .. id .. " aktiviert")
    end,
})

minetest.register_chatcommand("minenti_features", {
    params = "[seite]",
    description = "Listet die verfügbaren Features in Seiten zu je 10 Einträgen",
    func = function(name, param)
        local page = tonumber(param) or 1
        local per_page = 10
        local total = #minenti_features.registry
        local pages = math.ceil(total / per_page)
        if page < 1 or page > pages then
            return false, "Ungültige Seite. Erlaubt sind 1 bis " .. pages .. "."
        end
        local start_index = (page - 1) * per_page + 1
        local end_index = math.min(page * per_page, total)
        local lines = {"Minenti Features (Seite " .. page .. "/" .. pages .. "):"}
        for i = start_index, end_index do
            local spec = minenti_features.registry[i]
            lines[#lines + 1] = string.format("%3d: %s - %s", i, spec.label, spec.description)
        end
        return true, table.concat(lines, "\n")
    end,
})

