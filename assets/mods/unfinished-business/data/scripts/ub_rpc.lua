RegisterListener("OnInitNewCampaign", "init_rpcs")
RegisterListener("BeforePrepareSector", "add_rpc_to_sector")


function init_rpcs()
    -- randomly choose between JOHN_K and TEX
    if math.random() < 0.5 then
        extra_game_state.is_tex_in_game = true
        extra_game_state.is_johnk_in_game = false
        log.info("TEX is in game")
    else
        extra_game_state.is_tex_in_game = false
        extra_game_state.is_johnk_in_game = true
        log.info("JOHN_K is in game")
    end

    -- randomly choose John's starting secto
    if extra_game_state.is_johnk_in_game then
        if math.random() < 0.5 then
            extra_game_state.johnk_initial_sector = "I10"
        else
            extra_game_state.johnk_initial_sector = "I11"
        end
        log.info("JOHN_K is at " .. extra_game_state.johnk_initial_sector)
    end

    extra_game_state.rpcs_added = {
        [ UB_MercProfiles.TEX    ] = false,
        [ UB_MercProfiles.JOHN_K ] = false,
        [ UB_MercProfiles.MANUEL ] = false,
    }
end

function add_rpc(rpc_to_add)
    local rpc = GetMercProfile(rpc_to_add)
    local x,y,z = GetCurrentSectorLoc()
    rpc.sSectorX = x
    rpc.sSectorY = y
    rpc.bSectorZ = z

    log.info("rpc " .. rpc.zNickname .. " added to sector")
    if extra_game_state.rpcs_added == nil then
        log.warn("rpcs_added not initialized")
        extra_game_state.rpcs_added = {}
    end

    extra_game_state.rpcs_added[rpc] = true
end

function add_rpc_to_sector()
    -- add RPC(s) on specific sectors
    local current_sector = GetCurrentSector()

    if (current_sector == "H10" or current_sector == "I9") and
        not extra_game_state.rpcs_added[UB_MercProfiles.MANUEL]
    then
        add_rpc(UB_MercProfiles.MANUEL)
    end

    if current_sector == "I10" and
        not extra_game_state.rpcs_added[UB_MercProfiles.TEX]
    then
        add_rpc(UB_MercProfiles.TEX)
    end

    if current_sector == extra_game_state.johnk_initial_sector and
        not extra_game_state.rpcs_added[UB_MercProfiles.JOHN_K]
    then
        add_rpc(UB_MercProfiles.JOHN_K)
    end
end
