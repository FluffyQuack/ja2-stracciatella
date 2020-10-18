RegisterListener("OnInitNewCampaign", "new_campaign")
RegisterListener("OnMercHired", "init_merc_placement")
RegisterListener("OnEnterTacticalScreen", "on_enter_tactical_screen")
RegisterListener("OnHandleStrategicScreen" , "handle_strategic_screen")
RegisterListener("BeforePrepareSector", "prepare_heli_crash")
RegisterListener("OnTimeCompressDisallowed", "handle_timecompress_disallow")
RegisterListener("OnNPCDoAction", "handle_jerry_npc_action")

function new_campaign()
    extra_game_state.first_time_in_map_screen = true
    extra_game_state.ever_been_in_tactical = false

    log.info("placing jerry")
    local jerry = GetMercProfile(UB_MercProfiles.JERRY)
    jerry.sSectorX = INIT_SECTOR_X
    jerry.sSectorY = INIT_SECTOR_Y
    jerry.ubStrategicInsertionCode = 4  --INSERTION_CODE_GRIDNO;
    jerry.usStrategicInsertionData = 15109
    jerry.fUseProfileInsertionInfo = TRUE
end

function init_merc_placement(s)
    log.info("hired merc " .. s.ubID)
    if gTacticalStatus.fDidGameJustStart then
        local init_heli_grid_nos = { 14947, 15584, 15754, 16232, 16067, 16230, 15272 }
        log.info("moving merc to initial gridNo " .. init_heli_grid_nos[s.ubID + 1])
        s.ubStrategicInsertionCode = 4
        s.usStrategicInsertionData = init_heli_grid_nos[s.ubID + 1]
    end
end
--[[
	gsInitialHeliRandomTimes[ 0 ] = 1300;
	gsInitialHeliRandomTimes[ 1 ] = 2000;
	gsInitialHeliRandomTimes[ 2 ] = 2750;
	gsInitialHeliRandomTimes[ 3 ] = 3400;
	gsInitialHeliRandomTimes[ 4 ] = 4160;
	gsInitialHeliRandomTimes[ 5 ] = 4700;
	gsInitialHeliRandomTimes[ 6 ] = 5630;
}
--]]

function jerry_say_quote(quote_num)
    if extra_game_state.jerry_said_quotes == nil then
        extra_game_state.jerry_said_quotes = {}
    end

    -- do not repeat if the quote has been said already
    if extra_game_state.jerry_said_quotes[quote_num] then
        return
    end

    log.info("start jerry quote")
    StrategicNPCDialogue(UB_MercProfiles.JERRY, quote_num)

    extra_game_state.jerry_said_quotes[quote_num] = true
end

function handle_strategic_screen()
    if not extra_game_state.first_time_in_map_screen then
        log.debug("not first time in map screen")
        return
    end

    -- Get Jerry Milo to say his opening quote, if he hasnt said it before)
    jerry_say_quote(UB_JerryQuotes.MILO_QUOTE__OPENING_GREETING_PART_1)
    jerry_say_quote(UB_JerryQuotes.MILO_QUOTE__OPENING_GREETING_PART_2)

    extra_game_state.first_time_in_map_screen = false
end

--[[
Prepare for the crash landing start scene
--]]
function prepare_heli_crash()
    if extra_game_state.ever_been_in_tactical
        or GetCurrentSector() ~= INIT_SECTOR
    then
        return
    end

    -- first, loop through all the mercs and injure them
    local our_team = ListSoldiersFromTeam(Teams.OUR_TEAM)
    for _, s in ipairs(our_team) do
        if s.bActive then
            s.bLife = s.bLife - (3 + math.random(0, 5))
            s.sBreathRed = (15 + math.random(0, 15)) * 100
            s.bActionPoints = 0
        end
    end
end


--[[
Heli crash sequence upon landing at the first sector
--]]
function on_enter_tactical_screen()
    gTacticalStatus.fEnemyFlags = gTacticalStatus.fEnemyFlags & 1  -- TODO: do it "properly"? (ENEMY_OFFERED_SURRENDER)

    if extra_game_state.ever_been_in_tactical then
        return
    end

    if GetCurrentSector() ~= INIT_SECTOR then
        return
    end

    local sector = GetSectorInfo(INIT_SECTOR)

    log.info("landed in H7")

    gTacticalStatus.fEnemyInSector = FALSE
    gTacticalStatus.uiFlags = gTacticalStatus.uiFlags & (~TacticalStatusFlags.INCOMBAT)
    CenterAtGridNo(15427, true)

    --[[
    -- TODO: Make sure we can see the pilot
		gbPublicOpplist[OUR_TEAM][ pJerrySoldier->ubID ] = SEEN_CURRENTLY;
		pJerrySoldier->bVisible = TRUE;
    --]]

    --[[
    -- TODO: Loop through each merc, have them get up at (pre-)random intervals and say a quote (at Overhead.cc)
    --]]

    -- Trigger Jerry Milo's script record 10 ( call action 301 )
    TriggerNPCRecord(UB_MercProfiles.JERRY, 10)

    StartQuest(UB_Quests.QUEST_FIX_LAPTOP, "") -- the internet part of the laptop isnt working.  It gets broken in the heli crash.

    SetThisSectorAsPlayerControlled(INIT_SECTOR_X, INIT_SECTOR_Y, 0, FALSE)

    local jerry = GetMercProfile(UB_MercProfiles.JERRY)
    jerry.ubLastDateSpokenTo = 1 -- ensure we do not prompt him as a NPC yet to talk to

    extra_game_state.ever_been_in_tactical = true
end

function handle_jerry_npc_action(npc_id, action_code, quote_num)
    if action_code == UB_NPCActions.NPC_ACTION_TRIGGER_JERRY_CONVERSATION_WITH_PGC_1 then
        -- action 301
        local our_team = ListSoldiersFromTeam(Teams.OUR_TEAM)
        for _, s in ipairs(our_team) do
            if soldier_has_ub_quotes(s) then
                -- complain about bad flight
                TacticalCharacterDialogue(s, UB_Quotes.QUOTE_COMPLAIN_BAD_PILOT)
            end
        end

        -- Trigger Jerry Milo's script record 11 ( call action 302 )
        TriggerNPCRecord(UB_MercProfiles.JERRY, 11)

        DeleteTalkingMenu() -- Close the dialogue panel

    elseif action_code == UB_NPCActions.NPC_ACTION_TRIGGER_JERRY_CONVERSATION_WITH_PGC_2 then
        -- action 302
        local random_mercs = get_mercs_with_ub_quotes()
        if #random_mercs > 0 then
            -- have one merc say we shouldn't stay long
            TacticalCharacterDialogue(random_mercs[1], UB_Quotes.QUOTE_DONT_STAY_FOR_LONG)

            -- have one merc say the "brr it's cold" quote
            merc_say_quote_delayed(random_mercs[#random_mercs].ubProfile, UB_Quotes.QUOTE_COMPLAIN_ITS_COLD, 15)
        end

        DeleteTalkingMenu() -- Close the dialogue panel
    end
end

function handle_timecompress_disallow(handled)
    if extra_game_state.ever_been_in_tactical then
        return
    end

    -- before we landed in Tracona
    local our_team = ListSoldiersFromTeam(Teams.OUR_TEAM)
    if #our_team == 0 then
        jerry_say_quote(UB_JerryQuotes.MILO_QUOTE__PLAYER_HAS_NO_MERCS)
        handled.val = TRUE
    else
        jerry_say_quote(UB_JerryQuotes.MILO_QUOTE__HEADED_TO_TRACONA_QUOTE)
        handled.val = TRUE
    end
end