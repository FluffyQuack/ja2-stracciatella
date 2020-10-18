RegisterListener('OnAddEmail', 'handle_add_email')
RegisterListener('OnInitNewCampaign', 'start_new_campaign')

function start_new_campaign()
    -- add UB emails
    local send_date = 1501  -- so we can tell them apart from base game emails

    AddEmailMessage(UB_Emails.STARTGAME,       UB_Emails.STARTGAME_LENGTH,
                    send_date, UB_EmailSenders.MAIL_ENRICO,       FALSE, 0, 0)
    AddEmailMessage(UB_Emails.AIMDISCOUNT,     UB_Emails.AIMDISCOUNT_LENGTH,
                    send_date, UB_EmailSenders.AIM_SITE,          FALSE, 0, 0)  -- add the initial email from AIM
    AddEmailMessage(UB_Emails.IMP_EMAIL_INTRO, UB_Emails.IMP_EMAIL_INTRO_LENGTH,
                    send_date, UB_EmailSenders.CHAR_PROFILE_SITE, FALSE, 0, 0)  -- add the imp site email

    -- set M.E.R.C. to be available immediately
    SetBookMark(Bookmarks.AIM)
    SetBookMark(Bookmarks.MERC)

    -- pre-open accounts on M.E.R.C.
    LaptopSaveInfo.gubPlayersMercAccountStatus = 4    -- MERC_ACCOUNT_VALID
    LaptopSaveInfo.ubPlayerBeenToMercSiteStatus = 3   -- MERC_SITE_THIRD_OR_MORE_VISITS
end

function handle_add_email(offset, len, date, sender, already_read, data1, data2, is_cancelled)
    -- intercept and cancel all base game initial emails
    if date == 1500 then  -- 1500 is the base game start-of-game email date
        -- pre-read email at game init
        is_cancelled.val = TRUE
    end
    --TODO: no new emails if Laptop is broken
end