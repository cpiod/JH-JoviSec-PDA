function set_branch_name(all_strings, name, xy)
    if name~=nil then
        local x = xy[1]
        local y = xy[2]
        all_strings[y] = string.sub(all_strings[y], 1, x - 1) .. name .. string.sub(all_strings[y], x + 6)
    end
end

function hilite_pos_main_branch(all_strings, depth, main_pos, str)
    local i = depth
    all_strings[2*i-1] = string.sub(all_strings[2*i-1], 1, main_pos[i]-1) .. str .. string.sub(all_strings[2*i-1], main_pos[i]+2)
end

function hilite_pos_side_branch(all_strings, branch_number, depth, max_branch_depth, br_pos)
    local l = branch_number + 1
    local i = depth - branch_number - 1 -- depth in branch
    local d = max_branch_depth
    local j = math.min(i, d)
    local y = 2*l+2*j-1
    all_strings[y] = string.sub(all_strings[y], 1, br_pos[i]-1) .. "GX" .. string.sub(all_strings[y], br_pos[i]+2)
end

function run_pda_ui( self, entity )
    local list = {}
    local strings_3 = {
    "L1                 {!o}\n",
    "                   {d}  ERROR!\n",
    "L2                 {!o}{d}\n",
    "        ERROR!     {d        }\n",
    "L3    {d}{!o}        {!o}\n",
    "      {d                    }\n",
    "L4    {!o}        {d}{!o}        {d}{!o}\n",
    "      {d           } ERROR! {d}\n",
    "L5    {!o}        {!o}   {!o}{d}{mo}      {!o}{d}{mo}\n",
    "      {d} ERROR! {d           }\n",
    "L6  {mo}{d}{!o}      {mo}{d}{!o}   {!o}{d}\n",
    "      {d           }\n",
    "L7    {d}{!o}\n",
    "                   {d}\n",
    "{GX}: you  {Rx}: red lock  {Yx}: mt lock"
    }

    local strings_2 = {
    "L1                 {!o}\n",
    "        ERROR!     {d}\n",
    "L2    {d}{!o}\n",
    "      {d            }\n",
    "L3    {!o}        {d}{!o}\n",
    "      {d           }  ERROR!\n",
    "L4    {!o}        {!o}   {!o}{d}\n",
    "      {d} ERROR! {d           }\n",
    "L5  {mo}{d}{!o}      {mo}{d}{!o}   {!o}{d}{mo}      {!o}\n",
    "      {d           } ERROR! {d}\n",
    "L6    {d}{!o}        {!o}{d}{mo}\n",
    "                   {d        }\n",
    "L7                 {!o}{d}\n",
    "                   {d}\n",
    "{GX}: you  {Rx}: red lock  {Yx}: multitool lock"
    }

    local all_strings = {strings_2, strings_3}

    local br_name_loc_3 = {
        {26, 2},
        {9, 4},
        {12, 10},
        {25, 8}
    }
    local br_name_loc_2 = {
        {9, 2},
        {12, 8},
        {26, 6},
        {25, 10},
    }
    br_name_loc = {br_name_loc_2, br_name_loc_3}

    -- x values
    local main_pos = {{21, 24, 27, 27, 39, 24, 21},{21, 21, 24, 27, 27, 39, 24}}
    local br1_pos = {{8, 8, 14, 6},{36, 42, 45, 53}}
    local br2_pos = {{20, 32, 24},{8, 8, 14, 6}}
    local br3_pos = {{57, 36, 44},{20, 32, 24}}
    local sp_br_pos = {{47},{35}}

    names = {
        level_callisto_mines           = "Mines ",
        level_callisto_valhalla        = "Valha.",
        level_callisto_mimir           = "Mimir ",
        level_callisto_rift            = " Rift ",
        level_callisto_docks           = "Docks ",
        level_callisto_military        = "Barra.",
        level_europa_biolabs           = " CBB  ",
        level_europa_dig_zone          = "Dig Z.",
        level_europa_asterius          = "Aster.",
        level_europa_ruins             = "Ruins ",
        level_europa_refueling         = "Refuel",
        level_europa_pit               = " Pit  ",
        level_io_blacksite             = "B.Site",
        level_io_armory                = " Labs ",
        level_io_mephitic              = "Mephi.",
        level_io_halls                 = "Halls ",
        level_io_warehouse             = "Wareh.",
        level_io_lock                  = " Lock ",
    }

    local episode = world:get_level().level_info.episode
    local current = world.data.current
    local l = world.data.level[world.data.current]
    local linfo = world:get_level().level_info
    local episode = linfo.episode
    local depth = linfo.depth

    -- for k,v in pairs(l) do
    --     nova.log(tostring(k).." "..tostring(v))
    -- end

    depth = depth - 7 * (episode - 1)

    local branch_index = {{5, 6, 7, 1},{8, 9, 10, 2},{11, 12, 13, 3}}
    local name_br = {}
    local level_2_depth = 0

    for _,v in ipairs(world.data.level) do
        for i = 1,4 do
            if episode < 4 and v.branch_index == branch_index[episode][i] and names[v.blueprint] ~= nil then
                -- nova.log("Branch: "..names[v.blueprint])
                name_br[i] = names[v.blueprint]
                if i == 2 then
                    level_2_depth = level_2_depth + 1
                end
            end
        end
    end

    local logl = math.min(#cpiod_log, 15)
    local desc = ""
    for i=1,logl do
        desc = desc..cpiod_log[#cpiod_log-i+1]
        if i < logl then
            desc = desc.."\n"
        end
    end
    list.fsize = logl

    table.insert( list, {
        name = "Log",
        target = self,
        desc = desc,
        cancel = true,
    })


    -- nova.log("Level 2 depth: "..level_2_depth)
    local trait = entity:child("trait_pda")
    updated = self.attributes.updated
    if level_2_depth < 2 or level_2_depth > 3 then
        table.insert( list, {
                name = "Map",
                target = self,
                desc = "Unknown location",
                cancel = true,
        })
    elseif episode == 4 then
            table.insert( list, {
                    name = "Map",
                    target = self,
                    desc = "No map for Dante station",
                    cancel = true,
    })
    elseif episode > 4 then
            table.insert( list, {
                    name = "Map",
                    target = self,
                    desc = "Unknown location",
                    cancel = true,
            })
	elseif updated == 0 then
            table.insert( list, {
                    name = "Map",
                    target = self,
                    desc = "Download the map from a terminal!",
                    cancel = true,
            })
    else
        local i = level_2_depth - 1
        br_name_loc = br_name_loc[i]
        all_strings = all_strings[i]
        main_pos = main_pos[i]
        br1_pos = br1_pos[i]
        br2_pos = br2_pos[i]
        br3_pos = br3_pos[i]
        sp_br_pos = sp_br_pos[i]

        for i = 1,4 do
            set_branch_name(all_strings, name_br[i], br_name_loc[i])
        end

        if l.branch_index == episode and names[l.blueprint] == nil then
            hilite_pos_main_branch(all_strings, depth, main_pos, "GX")
        elseif l.branch_index == episode then
            -- special level reachable from main branch
            local y = 9
            all_strings[y] = string.sub(all_strings[y], 1, sp_br_pos[1]-1) .. "GX" .. string.sub(all_strings[y], sp_br_pos[1]+2)
        else
            local branch_index = (l.branch_index - 5) % 3 + 1
            local max_branch_depth = {3,3,2}
            max_branch_depth[2] = level_2_depth
            local br_pos = {br1_pos, br2_pos, br3_pos}
            if l.returnable then
                depth = depth + 1 -- hack for special levels
            end
            hilite_pos_side_branch(all_strings, branch_index, depth, max_branch_depth[branch_index], br_pos[branch_index])
        end

        for d,v in ipairs(world.data.level) do
            if v.episode == episode then
                if v.branch_lock == "elevator_locked" then
                    hilite_pos_main_branch(all_strings, v.depth - 7 * (episode - 1)
, main_pos, "Rx")
                elseif v.branch_lock == "elevator_broken" then
                    hilite_pos_main_branch(all_strings, v.depth - 7 * (episode - 1)
, main_pos, "Yx")
                end
            end
        end

        local s = ""
        for i = 1,15 do
            s = s .. "         " .. all_strings[i]
        end
    --    iterate over all quest message. check jh.lua, line 1026

        table.insert( list, {
                        name = "Map",
                        target = self,
                        desc = s,
                        cancel = true,
        })
        list.fsize = math.max(list.fsize, 15)
    end

    list.title = "JoviSec PDA - HelloS 1.6"
    list.size  = coord( 56, 0 )
    ui:terminal( entity, what, list )
end

register_blueprint "trait_pda"
{
    blueprint = "trait",
    text = {
        name   = "JoviSec PDA",
        desc   = "INTERNAL",
        full   = "INTERNAL",
        abbr   = "PDA",
    },
	attributes = {
		updated = 0, -- 0 if the player needs to update their map from a terminal, 1 if they have already done so.
	},
    callbacks = {

        on_use = [=[
            function( self, entity )
                if entity == world:get_player() then
                    run_pda_ui( self, entity )
                    return -1
                else 
                    return -1
                end
            end
        ]=],

        on_activate = [=[
            function ( self, player, level, param, id )
                return 0
            end
        ]=],
		on_enter_level = [=[
			function ( self, entity, reenter )
				local linfo = world:get_level().level_info
				local episode = linfo.episode
				local depth = linfo.depth
				depth = depth - 7 * (episode - 1)
				if depth == 1 then
					self.attributes.updated = 0
				end
				if depth > 1 and self.attributes.updated == 0 and episode <= 3 then
					if reenter then return end
					local level = world:get_level()
					for e in level:entities() do
						if world:get_id( e ) == "terminal" then
                            e:attach( "event_pda_update" )
						end
					end
				end
			end
					
		]=],--Resets updated to 0 when the player enters a new moon. Adds the option to update the map to the terminal if not on the first level of a moon and not on Dante.
    },
    skill = {
        cooldown = 0,
        cost = 0,
    },
}

cpiod_pda = {}
function cpiod_pda.on_entity( entity )
    -- don’t attach PDA on non-standard games
    if entity.data and entity.data.ai and entity.data.ai.group == "player" and #world.data.level > 60 and #world.data.level <= 68 then
        entity:attach( "trait_pda" )
    end
    if entity.data and entity.data.ai then
        entity:attach( "cpiod_logger" )
    end
end

world.register_on_entity( cpiod_pda.on_entity )

cpiod_log = {}
cpiod_wait = 0

register_blueprint "cpiod_logger"
{
	flags = { EF_NOPICKUP }, 
	text = {
		entry    = "Download map to PDA",
        complete = "PDA map downloaded",
		desc      = "Download the map to PDA to display current location"
	},
	data = {
		terminal = {
			priority = 9,
		},
    },
	attributes = {
		last_entry = nil,
	},
	callbacks = {
		on_receive_damage = [=[
			function ( self, entity, source, weapon, amount )
                -- destination must have an AI to avoid "X attacks crates/barrel/etc."
                -- but keep them as source (to know if a barrel destroyed an enemy for example)
                if amount > 0 then
                    if source and source.data and source.data.ai and source.data.ai.group == "player" then
                        table.insert(cpiod_log, "You deal {!"..tostring(amount).."} to {!"..world:get_text( world:get_id(entity), "name" ).."}")
                    else
                        local s = world:get_text( world:get_id(source), "name" )
                        s = string.upper(s:sub(1,1))..s:sub(2,#s)
                        table.insert(cpiod_log, "{!"..s.."} deals {!"..tostring(amount).."} to {!"..world:get_text( world:get_id(entity), "name" ).."}")
                    end
                    self.attributes.last_entry = #cpiod_log
                    cpiod_wait = 0
                end
            end
		]=],
		on_die = [=[
			function ( self )
                if self.attributes.last_entry then
                    cpiod_log[self.attributes.last_entry] = cpiod_log[self.attributes.last_entry]..", killing it"
                end
            end
		]=],
		on_enter_level = [=[
            function ( self, entity, reenter )
                for k,v in pairs(cpiod_log) do -- delete previous logs
                    cpiod_log[k] = nil
                end
                cpiod_log[1] = "You enter {!".. world.data.level[world.data.current].name.."}"
            end
		]=],
		on_post_command = [=[
			function ( self, entity, cmt, target, time )
                if entity.data and entity.data.ai and entity.data.ai.group == "player" then
                    if cmt == COMMAND_WAIT then
                        cpiod_wait = cpiod_wait + 1
                        if cpiod_wait == 1 then
                            table.insert(cpiod_log, "You wait")
                        else
                            cpiod_log[#cpiod_log] = "You wait ("..cpiod_wait.." times)"
                        end
                    -- elseif cmt == COMMAND_DROP then
                    --     table.insert(cpiod_log, "You drop "..world:get_text( world:get_id(target), "name" ))
                    --     cpiod_wait = false
                    -- elseif cmt == COMMAND_PICKUP then
                    --     table.insert(cpiod_log, "You pick up "..world:get_text( world:get_id(target), "name" ))
                    --     cpiod_wait = false
                    elseif cmt == COMMAND_RELOAD then
                        table.insert(cpiod_log, "You reload")
                        cpiod_wait = 0
                    end
                end
            end
		]=],

		on_rearm = [=[
			function ( self, entity, wpn, wpn_next )
                if entity.data and entity.data.ai and entity.data.ai.group == "player" then
                    table.insert(cpiod_log, "You equip {!"..world:get_text( world:get_id(wpn), "name" ).."}")
                    cpiod_wait = 0
                end
            end
		]=],

	}
}

register_blueprint "event_pda_update"
{
	flags = { EF_NOPICKUP }, 
	text = {
		entry    = "Download map to PDA",
        complete = "PDA map downloaded",
		desc      = "Download the map to PDA to display current location"
	},
	data = {
		terminal = {
			priority = 9,
		},
    },
	callbacks = {
		on_activate = [=[
		function( self, who, level )
			local parent  = ecs:parent( self )
			local trait = who:child("trait_pda")
			trait.attributes.updated = 1
			ui:set_hint( "{R".."Map downloaded".."}", 1001, 0 )
			world:destroy( self )
			ui:activate_terminal( who, parent )
		end
		]=]--Changes updated to 1 when the option is selected on a terminal.
	}
}
