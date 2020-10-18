RegisterListener('OnStrategicEvent', 'handle_merc_say_quote_delayed')
RegisterListener('OnEnterSector', 'handle_merc_quote_on_enter_sector')
RegisterListener('OnSoldierGotItem', 'handle_soldier_got_item')

SectorDescQuotes = {
    H9  = 86,  --QUOTE_HATE_MERC_1_ON_TEAM,
    I9  = 88,  --QUOTE_LEARNED_TO_HATE_MERC_ON_TEAM,
    H10 = 88,  --QUOTE_LEARNED_TO_HATE_MERC_ON_TEAM,
    I10 = 87,  --QUOTE_HATE_MERC_2_ON_TEAM,
    J13 = 107, --QUOTE_ENTER_SECTOR_WITH_FAN_1,
    ["J14-1"] = 0,
};

NewGuns = {
    [UB_Weapons.BARRETT] = true,
    [UB_Weapons.CALICO_960] = true,
    [UB_Weapons.PSG1] = true,
    [UB_Weapons.L85] = true,
    [UB_Weapons.TAR21] = true,
    [UB_Weapons.VAL_SILENT] = true,
    [UB_Weapons.MICRO_UZI] = true,
    [UB_Weapons.HAND_CANNON] = true,
    [UB_Weapons.CALICO_950] = true,
    [UB_Weapons.CALICO_900] = true,
}

DELAY_FOR_PLAYER_DESC_OF_SECTOR = 2

-- list all mercs, in current sector, that has the new UB quotes, in randomized order
function get_mercs_with_ub_quotes()
    local our_team = ListSoldiersFromTeam(Teams.OUR_TEAM)
    local mercs = {}
    local x,y,z = GetCurrentSectorLoc()
    for _, s in ipairs(our_team) do
        if s.bActive       and
           s.sSectorX == x and
           s.sSectorY == y and
           s.bSectorZ == z and
           s.bLife >= 15   and --OKLIFE
           s.fBetweenSectors == FALSE
        then
            -- if the merc is one of the mercs we are looking for
            if soldier_has_ub_quotes(s) then
                table.insert(mercs, s)
            end
        end
    end

    log.debug("got " .. #mercs .. " qualified mercs")
    return shuffle(mercs)
end

function shuffle(arr)
    for i = 1, #arr do
        local j = math.random(#arr)
        arr[i], arr[j] = arr[j], arr[i]
    end
    return arr
end

function soldier_has_ub_quotes(pSoldier)
    -- also called "qualified mercs" in UB source code
    if pSoldier.ubProfile == UB_MercProfiles.GASTON or
       pSoldier.ubProfile == UB_MercProfiles.STOGIE or
       pSoldier.ubProfile == UB_MercProfiles.TEX or
       pSoldier.ubProfile == UB_MercProfiles.JOHN_K or
       pSoldier.ubProfile == UB_MercProfiles.BIGGENS or
       pSoldier.ubProfile == UB_MercProfiles.MANUEL or
       pSoldier.ubWhatKindOfMercAmI == MercTypes.PLAYER_CHARACTER
    then
        return true
    else
        return false
    end
end

-- schedule a callback when a merc should say a quote
function merc_say_quote_delayed(profile_id, quote_num, seconds_delay)
    log.info("delayed quote: " .. profile_id .. " " .. quote_num)
    local event_param = profile_id + (quote_num << 16)
    local event_time = GetWorldTotalSeconds() + seconds_delay
    AddStrategicEvent(UB_EventTypes.EVENT_SAY_DELAYED_MERC_QUOTE, event_time, event_param);
end

-- handles the callback scheduled by merc_say_quote_delayed
function handle_merc_say_quote_delayed(event, processed)
    if event.ubEventKind ~= UB_EventTypes.EVENT_SAY_DELAYED_MERC_QUOTE then
        return
    end

    local profile_id = (0xFFFF & event.uiParam)
    local quote_num = (event.uiParam >> 16)
    -- TODO: handle "special" quotes (quoteNum < DQ__NORMAL_DELAYED_QUOTE)

    -- Get the soldier that should say the quote
    local soldier = FindSoldierByProfileID(profile_id)
    if not soldier then
        log.warn("cannot find soldier with profile #" .. profile_id)
        return
    end

    -- Do Quote specific code here
    if quote_num == UB_Quotes.QUOTE_COMPLAIN_ITS_COLD then
        -- if the soldier is saying the 'brr its cold' quote, and he has left the sector
        if soldier.sSectorX ~= 7 or soldier.sSectorY ~= 8 or soldier.bSectorZ ~= 0 then
            -- dont say the quote
            log.debug("skipping cold quote")
            return
        end
    end

    -- Say the quote
    TacticalCharacterDialogue(soldier, quote_num)
end


function handle_merc_quote_on_enter_sector(x, y, z)
    if extra_game_state.sector_quotes_said == nil then
        extra_game_state.sector_quotes_said = {}
    end

    local quote_num = SectorDescQuotes[GetCurrentSector()]
    if quote_num == nil then
        log.info("no quote for sector")
        return
    end

    local mercs = get_mercs_with_ub_quotes()
    if #mercs == 0 then
        log.info("no mercs can say quote")
        return
    end

    if extra_game_state.sector_quotes_said[quoteNum] == nil then
        log.info("delay sector quote")
        -- not yet said
        merc_say_quote_delayed(mercs[1].ubProfile, quote_num, DELAY_FOR_PLAYER_DESC_OF_SECTOR)
        extra_game_state.sector_quotes_said = true

        -- TODO: special handling for I10, J13, J14
    end
end

function handle_soldier_got_item(soldier, object, grid_no, z_level)
    log.info("got item " .. object.usItem)
    if extra_game_state.gun_quotes_said == nil then
        extra_game_state.gun_quotes_said = {}
    elseif extra_game_state.gun_quotes_said[object.usItem] then
        -- gun comment already said
        log.info("new gun comment already said")
        return
    end

    if soldier_has_ub_quotes(soldier) and NewGuns[object.usItem] then
        log.info("say new gun comment")
        -- say the new gun quote
        --TODO: if not HAND_CANNON
        TacticalCharacterDialogue(soldier, UB_Quotes.QUOTE_NEW_GUN_COMMENT)

        extra_game_state.gun_quotes_said[object.usItem] = true
        -- TODO: disable the old cool item quote
    end
end
--[[

HandlePlayerTeamQuotesWhenEnteringSector

void HandleMercArrivesQuotesFromHeliCrashSequence()
{
	UINT32 uiCnt;
	SOLDIERTYPE *pSoldier=NULL;

	uiCnt = gTacticalStatus.Team[ gbPlayerNum ].bFirstID;

	// look for all mercs on the same team,
	for ( pSoldier = MercPtrs[ uiCnt ]; uiCnt <= gTacticalStatus.Team[ gbPlayerNum ].bLastID; uiCnt++,pSoldier++)
	{
		if ( pSoldier->bActive && pSoldier->bLife >= OKLIFE && pSoldier->bInSector )
		{
			HandleMercArrivesQuotes( pSoldier );
		}
	}
}
--]]


--[[

start merc quotes
pSoldier = pick random one qualified merc
		TacticalCharacterDialogue( pSoldier, QUOTE_LAME_REFUSAL );
pSoldier = pick another qualified merc (if any)
		//Say the quote in 15 seconds
		DelayedMercQuote( ubProfileID, QUOTE_DEPARTING_COMMENT_CONTRACT_NOT_RENEWED_OR_48_OR_MORE, GetWorldTotalSeconds( ) + 15 );


--]]