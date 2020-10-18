RegisterListener("OnCheckQuests", "check_quests")

function check_quests(day, is_handled)
    -- QUEST 23 : Destroy missles
    -- The game always starts with destroy missles quest, so turn it on if it hasn't already started
    if gubQuest[UB_Quests.QUEST_DESTROY_MISSLES] == QuestStatuses.QUESTNOTSTARTED then
        StartQuest(UB_Quests.QUEST_DESTROY_MISSLES, "")
    end

    -- skip base game's quests
    is_handled.val = TRUE
end