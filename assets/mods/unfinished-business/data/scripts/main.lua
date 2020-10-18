JA2Require("enums.lua")
JA2Require("ub_enums.lua")

JA2Require("ub_hiring.lua")
JA2Require("ub_init_attack.lua")
JA2Require("ub_laptop.lua")
JA2Require("ub_merc_quotes.lua")
JA2Require("ub_progress.lua")
JA2Require("ub_quests.lua")
JA2Require("ub_rpc.lua")
JA2Require("ub_sectors.lua")
JA2Require("ub_strategic_ai.lua")
JA2Require("ub_start_seq.lua")
JA2Require("ub_tactical.lua")

JA2Require("custom-enemies.lua")

RegisterListener("OnInitNewCampaign", "on_new_campaign")
RegisterListener("OnStrategicEvent", "handle_events")

math.randomseed(os.time())
extra_game_state = {}  -- TODO: persist to save games

function on_new_campaign()
    local init_sector = GetSectorInfo("H7")
    init_sector.uiFlags = init_sector.uiFlags & (~SectorFlags.SF_USE_ALTERNATE_MAP)

    -- ensure STOGIE and GASTON are available
    local p = GetMercProfile(UB_MercProfiles.GASTON)
    p.bMercStatus           = MercStatuses.MERC_OK
    p.uiDayBecomesAvailable = 0

    p = GetMercProfile(UB_MercProfiles.STOGIE)
    p.bMercStatus           = MercStatuses.MERC_OK
    p.uiDayBecomesAvailable = 0
end

function handle_events(event, processed)
    if event.ubEventKind == EventTypes.EVENT_MEANWHILE then
        log.info('intercepted and cancelled MEANWHILE cutscene')
        processed.val = TRUE
    end
end