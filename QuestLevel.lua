-- QuestLevel: prefixes every quest in the quest log with its level, e.g. "[72] Quest Name".
--
-- Blizzard's QuestLog_Update (FrameXML/QuestLogFrame.lua, 3.3.5a) already does this when
-- colorblind mode is on. This addon applies the same prefix unconditionally by re-setting
-- each list button's text after QuestLog_Update runs, then calling Blizzard's own
-- QuestLogTitleButton_Resize so the text still fits beside the (Complete)/(Daily) tag
-- and the tracking check mark.

QuestLevelDB = QuestLevelDB or {}

local function IsEnabled()
    return QuestLevelDB.enabled ~= false
end

local function FormatTitle(level, title)
    return "[" .. level .. "] " .. title
end

local function UpdateQuestLog()
    if not IsEnabled() then
        return
    end
    -- Colorblind mode already prefixes "[level] " in QuestLog_Update; avoid doubling it.
    if ENABLE_COLORBLIND_MODE == "1" then
        return
    end

    local buttons = QuestLogScrollFrame and QuestLogScrollFrame.buttons
    if not buttons then
        return
    end

    local numEntries = GetNumQuestLogEntries()
    for i = 1, #buttons do
        local button = buttons[i]
        local questIndex = button:GetID()
        if questIndex > 0 and questIndex <= numEntries and button:IsShown() then
            local title, level, _, _, isHeader, _, _, _, questID, displayQuestID = GetQuestLogTitle(questIndex)
            if title and not isHeader and level and level > 0 then
                local text = FormatTitle(level, title)
                if questID and displayQuestID then
                    text = questID .. " - " .. text
                end
                button:SetText("  " .. text)
                QuestLogTitleButton_Resize(button)
            end
        end
    end
end

-- Hook the Blizzard quest log refresh once its code has loaded.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if type(QuestLog_Update) == "function" then
        hooksecurefunc("QuestLog_Update", UpdateQuestLog)
        -- QuestLogScrollFrame_OnLoad stored a direct reference to the original function as
        -- its scroll callback, which would bypass the hook when the list is scrolled.
        -- Point it at the hooked global instead.
        if QuestLogScrollFrame then
            QuestLogScrollFrame.update = QuestLog_Update
        end
    end
    self:UnregisterEvent("PLAYER_LOGIN")
end)

-- /questlevel (or /ql) toggles the prefix on and off.
SLASH_QUESTLEVEL1 = "/questlevel"
SLASH_QUESTLEVEL2 = "/ql"
SlashCmdList["QUESTLEVEL"] = function()
    QuestLevelDB.enabled = not IsEnabled()
    local state = IsEnabled() and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
    DEFAULT_CHAT_FRAME:AddMessage("QuestLevel: quest levels in the log are now " .. state .. ".")
    if QuestLogFrame and QuestLogFrame:IsShown() and type(QuestLog_Update) == "function" then
        QuestLog_Update()
    end
end
