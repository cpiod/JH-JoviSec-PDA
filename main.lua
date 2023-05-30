function set_branch_name(all_strings, name, xy)
    local x = xy[1]
    local y = xy[2]
    all_strings[y] = string.sub(all_strings[y], 1, x - 1) .. name .. string.sub(all_strings[y], x + 6)
end

function hilite_pos_main_branch(all_strings, depth, main_pos)
    local i = depth
    all_strings[2*i-1] = string.sub(all_strings[2*i-1], 1, main_pos[i]-1) .. "RX".. string.sub(all_strings[2*i-1], main_pos[i]+2)
end

function hilite_pos_side_branch(all_strings, branch_number, depth, max_branch_depth, br_pos)
    nova.log("Hilite: "..branch_number.." "..depth.." "..max_branch_depth)
    local l = branch_number + 1
    local i = depth - branch_number - 1 -- depth in branch
    local d = max_branch_depth
    local j = math.min(i, d)
    local y = 2*l+2*j-1
    all_strings[y] = string.sub(all_strings[y], 1, br_pos[i]-1) .. "RX" .. string.sub(all_strings[y], br_pos[i]+2)
end

function run_pda_ui( self, entity )
    local max_len = 30
    local list = {}
    local strings_3 = {
    "L1                 {yx}\n",
    "                   {d|}  ERROR!\n",
    "L2                 {yx}{d--------\\}\n",
    "        ERROR!     {d|        |}\n",
    "L3    {d/------------}{yx}        {yx}\n",
    "      {d|            |        |}\n",
    "L4    {yx}        {d/---}{yx}        {d}{yx}\n",
    "      {d|        |   |} ERROR! {d|}\n",
    "L5    {yx}        {yx}   {yx}{d-}{mx}      {yx}{d-}{mx}\n",
    "      {d|} ERROR! {d|   |        |}\n",
    "L6  {mx}{d-}{yx}      {mx}{d-}{yx}   {yx}{d--------/}\n",
    "      {d|        |   |}\n",
    "L7    {d\\--------+---}{yx}\n",
    "                   {d|}\n"
    }

    local strings_2 = {
    "L1                 {yx}\n",
    "        ERROR!     {d|}\n",
    "L2    {d/------------}{yx}\n",
    "      {d|            |}\n",
    "L3    {yx}        {d/---}{yx}\n",
    "      {d|        |   |}  ERROR!\n",
    "L4    {yx}        {yx}   {yx}{d--------\\}\n",
    "      {d|} ERROR! {d|   |        |}\n",
    "L5  {mx}{d-}{yx}      {mx}{d-}{yx}   {yx}{d-}{mx}      {yx}\n",
    "      {d|        |   |} ERROR! {d|}\n",
    "L6    {d\\--------+---}{yx}        {yx}{d-}{mx}\n",
    "                   {d|        |}\n",
    "L7                 {yx}{d--------/}\n",
    "                   {d|}\n",
    }

    local all_strings = {strings_2, strings_3}

    local br_name_loc_3 = {
        {26,2},
        {9,4},
        {12,10},
        {25,8}
    }
    local br_name_loc_2 = {
        {9,2},
        {26,6},
        {12,8},
        {25,10},
    }
    br_name_loc = {br_name_loc_2, br_name_loc_3}

    -- x values
    local main_pos = {{21,24,27,27,39,24,21},{21, 21, 24, 27, 27, 39, 24}}
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
        level_io_blacksit              = "B.Site",
        level_io_armory                = " Labs ",
        level_io_mephitic              = "Mephi.",
        level_io_halls                 = "Halls ",
        level_io_warehouse             = "Wareh.",
        level_io_lock                  = " Lock ",
    }

    local episode = world:get_level().level_info.episode
    nova.log("PDA! episode:"..episode)
    local current = world.data.current
    nova.log("PDA! current:"..current)
    local l = world.data.level[world.data.current]
    for k,v in pairs(l) do
        nova.log(tostring(k).." "..tostring(v))
    end
    for k,v in ipairs(world.data.level) do
        nova.log(k.." "..v.name.." "..v.blueprint.." "..v.depth.." "..v.branch_index)
    end

    local linfo = world:get_level().level_info
    local episode = linfo.episode
    local depth = linfo.depth
    if episode == 1 and depth < 1 then -- FIXME
            table.insert( list, {
                    name = "Map",
                    target = self,
                    desc = "Go to Callisto L2!",
                    cancel = true,
    })
    elseif episode == 2 and depth == 8 then
            table.insert( list, {
                    name = "Map",
                    target = self,
                    desc = "Go to Europa L2!",
                    cancel = true,
    })
    elseif episode == 3 and depth == 15 then
            table.insert( list, {
                    name = "Map",
                    target = self,
                    desc = "Go to Io L2!",
                    cancel = true,
    })
    elseif episode == 4 then
            table.insert( list, {
                    name = "Map",
                    target = self,
                    desc = "No map for Dante station",
                    cancel = true,
    })
    else
        local branch_index = {{5,6,7,1},{8,9,10,2},{11,12,13,3}}
        local name_br = {}
        local level_2_depth = 0

        for _,v in ipairs(world.data.level) do
            for i = 1,4 do
                if v.branch_index == branch_index[episode][i] and names[v.blueprint] ~= nil then
                    name_br[i] = names[v.blueprint]
                    if i == 2 then
                        level_2_depth = level_2_depth + 1
                    end
                end
            end
        end

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

        local l = world.data.level[world.data.current]
        if l.branch_index == episode and names[l.blueprint] == nil then
            hilite_pos_main_branch(all_strings, linfo.depth, main_pos)
        elseif l.branch_index == episode then
            -- special level reachable from main branch
            local y = 9
            all_strings[y] = string.sub(all_strings[y], 1, sp_br_pos[1]-1) .. "RX" .. string.sub(all_strings[y], sp_br_pos[1]+2)
        else
            local branch_index = (l.branch_index - 5) % 3 + 1
            local max_branch_depth = {3,3,2}
            max_branch_depth[2] = level_2_depth
            local br_pos = {br1_pos, br2_pos, br3_pos}
            local depth = linfo.depth
            if l.returnable then
                depth = depth + 1 -- hack for special levels
            end
            hilite_pos_side_branch(all_strings, branch_index, depth, max_branch_depth[branch_index], br_pos[branch_index])
        end

        local s = ""
        for i = 1,14 do
            s = s .. all_strings[i]
        end
    --    iterate over all quest message. check jh.lua, line 1026

        table.insert( list, {
                        name = "Map",
                        target = self,
                        desc = s,
                        cancel = true,
        })
    end
    list.title = "JoviSec PDA - HelloS 1.6"
    list.size  = coord( math.max( 30, max_len + 6 ), 0 )
    list.fsize = 14
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
    },
    skill = {
        cooldown = 0,
        cost = 0,
    },
}


register_blueprint "challenge_test_pda"
{
    text = {
        name   = "Angel of PDA",
        desc   = "{!MEGA CHALLENGE PACK MOD}",
        rating = "EASY",
        abbr   = "AoBR",
        letter = "B",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "trait_pda" )
                player:attach( "exo_armor_ablative" )
                player:attach( "adv_helmet_blue" )
                player:attach( "exo_egls" )
                player:attach( "exo_cpistol" )
                player.progression.experience = 10000
            end
        ]],
    },
}

