local Coach = LibStub("AceAddon-3.0"):GetAddon("Coach");
local LibDBIcon = LibStub("LibDBIcon-1.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local AceConfig = LibStub("AceConfig-3.0");
local CoachConfig;

function Coach:Toggle(button)
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(Coach.addonName);
    else
        InterfaceOptionsFrame_OpenToCategory(Coach.addonName);
        InterfaceOptionsFrame_OpenToCategory(Coach.addonName);
    end
end

function Coach:GetKeyByValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k;
        end
    end
    return nil;
end

-- Color coding helper functions
function Coach:ColorText(text, colorCode)
    return "|cff" .. colorCode .. text .. "|r";
end

function Coach:GetThresholdColor(threshold)
    -- Color scheme: green (strict) -> yellow -> orange -> red (loose)
    if threshold == 0 then
        return "00FF00"; -- Green - exact match
    elseif threshold == 1 then
        return "80FF00"; -- Light green - very strict
    elseif threshold == 2 then
        return "FFFF00"; -- Yellow - moderate (recommended)
    elseif threshold == 3 then
        return "FF8000"; -- Orange - loose
    elseif threshold == 4 then
        return "FF4000"; -- Red-orange - very loose
    else
        return "FF0000"; -- Red - maximum
    end
end

function Coach:GetThresholdLevelName(threshold)
    if threshold == 0 then
        return "Exact Match Only";
    elseif threshold == 1 then
        return "Very Strict Matching";
    elseif threshold == 2 then
        return "Moderate Matching (Recommended)";
    elseif threshold == 3 then
        return "Loose Matching";
    elseif threshold == 4 then
        return "Very Loose Matching";
    else
        return "Maximum Matching";
    end
end

function Coach:GetThresholdDescription(threshold)
    if threshold == 0 then
        return "The keyword must match perfectly (e.g., 'help' matches 'help' but not 'hel' or 'helps').";
    elseif threshold == 1 then
        return "Allows 1 character difference (e.g., 'help' matches 'hel' or 'helps').";
    elseif threshold == 2 then
        return "Allows 2 character differences (e.g., 'help' matches 'hel', 'helps', or 'hep').";
    elseif threshold == 3 then
        return "Allows 3 character differences (e.g., 'help' matches 'hel', 'helps', 'hep', or 'helpp').";
    elseif threshold == 4 then
        return "Allows 4 character differences. May match unintended words.";
    else
        return "Allows 5 character differences. Very likely to match unintended words.";
    end
end

function Coach:CreateMenu()
    CoachConfig = CreateFrame("Frame", "CoachConfig", UIParent);

    CoachConfig.name = self.addonName;

    CoachConfig.title = CoachConfig:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    CoachConfig.title:SetParent(CoachConfig);
    CoachConfig.title:SetPoint("TOPLEFT", 16, -16);
    CoachConfig.title:SetText(self.addonName);


    local options = {
        name = "Coach",
        type = "group",
        args = {
            general = {
                order = 1,
                type = "group",
                name = "General Settings",
                inline = false,
                args = {
                    message = {
                        order = 1,
                        name = "Advertising Message",
                        desc = "Advertising message for LFG",
                        type = "input",
                        width = "full",
                        set = function(info, value) 
                            self.db.profile.message = value;
                        end,
                        get = function(info) 
                            return self.db.profile.message;
                        end,
                        validate = function(info, value)
                            return #value <= 255;
                        end,
                    },
                    activateButton = {
                        order = 2,
                        type = "execute",
                        name = function ()
                            if self.db.profile.isPaused then
                                return "Activate Auto Messaging";
                            else
                                return "Pause Auto Messaging";
                            end
                        end,
                        desc = function ()
                            if self.db.profile.isPaused then
                                return "Activate auto messaging";
                            else
                                return "Pause auto messaging";
                            end
                        end,
                        func = function()
                           self.db.profile.isPaused = not self.db.profile.isPaused; 
                        end,
                        width = "full",
                    },
                },
            },
            responseSettings = {
                order = 2,
                type = "group",
                name = "Response Settings",
                inline = false,
                args = {
                    defaultResponse = {
                        order = 1,
                        type = "input",
                        name = "Default Response Message",
                        desc = "Message to send when no keywords match. Leave empty to not respond to unmatched messages.",
                        multiline = 3,
                        width = "full",
                        set = function(info, value)
                            self.db.profile.defaultResponse = value;
                        end,
                        get = function(info)
                            return self.db.profile.defaultResponse or "";
                        end,
                    },
                    enableSecondaryDefault = {
                        order = 2,
                        type = "toggle",
                        name = "Enable Secondary Default Response",
                        desc = "If enabled, alternates between default and secondary default responses. Helps avoid appearing bot-like.",
                        width = "full",
                        set = function(info, value)
                            self.db.profile.enableSecondaryDefault = value;
                        end,
                        get = function(info)
                            return self.db.profile.enableSecondaryDefault or false;
                        end,
                    },
                    secondaryDefaultResponse = {
                        order = 3,
                        type = "input",
                        name = "Secondary Default Response",
                        desc = "Message to send on the second interaction (alternates with default). Only used if 'Enable Secondary Default Response' is checked.",
                        multiline = 3,
                        width = "full",
                        hidden = function()
                            return not self.db.profile.enableSecondaryDefault;
                        end,
                        set = function(info, value)
                            self.db.profile.secondaryDefaultResponse = value;
                        end,
                        get = function(info)
                            return self.db.profile.secondaryDefaultResponse or "";
                        end,
                    },
                    delayHeader = {
                        order = 4,
                        type = "header",
                        name = "Response Delay",
                    },
                    minDelayTime = {
                        order = 5,
                        type = "range",
                        name = "Minimum Delay (seconds)",
                        desc = "Minimum delay in seconds before sending a response message",
                        min = 0,
                        max = 30,
                        step = 1,
                        get = function()
                            return self.db.profile.minDelayTime or 4;
                        end,
                        set = function(info, value)
                            self.db.profile.minDelayTime = value;
                            -- Ensure min doesn't exceed max
                            if self.db.profile.minDelayTime > (self.db.profile.maxDelayTime or 10) then
                                self.db.profile.maxDelayTime = self.db.profile.minDelayTime;
                            end
                            -- Refresh to update preview
                            AceConfig:NotifyChange(self.addonName);
                        end,
                    },
                    maxDelayTime = {
                        order = 6,
                        type = "range",
                        name = "Maximum Delay (seconds)",
                        desc = "Maximum delay in seconds before sending a response message",
                        min = 0,
                        max = 30,
                        step = 1,
                        get = function()
                            return self.db.profile.maxDelayTime or 10;
                        end,
                        set = function(info, value)
                            self.db.profile.maxDelayTime = value;
                            -- Ensure max isn't less than min
                            if self.db.profile.maxDelayTime < (self.db.profile.minDelayTime or 4) then
                                self.db.profile.minDelayTime = self.db.profile.maxDelayTime;
                            end
                            -- Refresh to update preview
                            AceConfig:NotifyChange(self.addonName);
                        end,
                    },
                    delayPreview = {
                        order = 7,
                        type = "description",
                        name = function()
                            local min = self.db.profile.minDelayTime or 4;
                            local max = self.db.profile.maxDelayTime or 10;
                            return "|cffCCCCCCResponse will be sent after a random delay between " .. min .. " and " .. max .. " seconds.|r";
                        end,
                        fontSize = "small",
                    },
                    interactionHeader = {
                        order = 8,
                        type = "header",
                        name = "Interaction Limits",
                    },
                    maxInteractionsPerPlayer = {
                        order = 9,
                        type = "range",
                        name = "Max Interactions Per Player",
                        desc = "Maximum number of times to respond to the same player before stopping (prevents spam)",
                        min = 1,
                        max = 10,
                        step = 1,
                        get = function()
                            return self.db.profile.maxInteractionsPerPlayer or 2;
                        end,
                        set = function(info, value)
                            self.db.profile.maxInteractionsPerPlayer = value;
                            -- Refresh to update description
                            AceConfig:NotifyChange(self.addonName);
                        end,
                    },
                    maxInteractionsDesc = {
                        order = 10,
                        type = "description",
                        name = function()
                            local max = self.db.profile.maxInteractionsPerPlayer or 2;
                            local plural = max == 1 and "time" or "times";
                            return "|cffCCCCCCThe addon will stop responding to a player after " .. max .. " " .. plural .. " to prevent spam.|r";
                        end,
                        fontSize = "small",
                    },
                },
            },
            keywordResponses = {
                order = 3,
                type = "group",
                name = "Keyword Responses",
                inline = false,
                args = {
                    keywordResponsesDesc = {
                        order = 1,
                        type = "description",
                        name = "Select a keyword from the list to edit its response, or add a new keyword.\n\n|cffCCCCCCIf you receive a message with the selected word within it, it will give the response given instead of the default.|r",
                        fontSize = "medium",
                    },
                    selectedKeyword = {
                        order = 2,
                        type = "select",
                        name = "Select Keyword",
                        desc = "Choose a keyword to edit its response",
                        width = "full",
                        values = function()
                            local keywords = {};
                            if self.db.profile.keywordResponses then
                                local keywordList = {};
                                for keyword, _ in pairs(self.db.profile.keywordResponses) do
                                    table.insert(keywordList, keyword);
                                end
                                table.sort(keywordList);
                                for _, keyword in ipairs(keywordList) do
                                    keywords[keyword] = keyword;
                                end
                            end
                            if not next(keywords) then
                                keywords[""] = "(No keywords - add one below)";
                            end
                            return keywords;
                        end,
                        get = function()
                            return self.db.profile.selectedKeyword or "";
                        end,
                        set = function(info, value)
                            self.db.profile.selectedKeyword = value;
                        end,
                    },
                    addNewKeyword = {
                        order = 3,
                        type = "input",
                        name = "Add New Keyword",
                        desc = "Enter a new keyword to add to the list",
                        width = "full",
                        get = function()
                            return "";
                        end,
                        set = function(info, value)
                            if value and value:match("%S") then
                                local keyword = value:lower():match("^%s*(.-)%s*$");
                                if keyword and keyword ~= "" then
                                    if not self.db.profile.keywordResponses then
                                        self.db.profile.keywordResponses = {};
                                    end
                                    if not self.db.profile.keywordResponses[keyword] then
                                        self.db.profile.keywordResponses[keyword] = {
                                            response = "",
                                            threshold = 2,
                                        };
                                        self.db.profile.selectedKeyword = keyword;
                                        -- Refresh the options to update the dropdown
                                        AceConfig:NotifyChange(self.addonName);
                                    end
                                end
                            end
                        end,
                    },
                    keywordResponse = {
                        order = 4,
                        type = "input",
                        name = "Response Message",
                        desc = "The message to send when this keyword is matched",
                        multiline = 5,
                        width = "full",
                        disabled = function()
                            return not self.db.profile.selectedKeyword or self.db.profile.selectedKeyword == "";
                        end,
                        get = function()
                            local selected = self.db.profile.selectedKeyword;
                            if selected and selected ~= "" and self.db.profile.keywordResponses and self.db.profile.keywordResponses[selected] then
                                return self.db.profile.keywordResponses[selected].response or "";
                            end
                            return "";
                        end,
                        set = function(info, value)
                            local selected = self.db.profile.selectedKeyword;
                            if selected and selected ~= "" then
                                if not self.db.profile.keywordResponses then
                                    self.db.profile.keywordResponses = {};
                                end
                                if not self.db.profile.keywordResponses[selected] then
                                    self.db.profile.keywordResponses[selected] = {
                                        response = value,
                                        threshold = 2,
                                    };
                                else
                                    self.db.profile.keywordResponses[selected].response = value;
                                end
                            end
                        end,
                    },
                    threshold = {
                        order = 5,
                        type = "range",
                        name = "Fuzzy Match Threshold",
                        desc = "Maximum Levenshtein distance for fuzzy matching (lower = stricter)",
                        min = 0,
                        max = 5,
                        step = 1,
                        disabled = function()
                            return not self.db.profile.selectedKeyword or self.db.profile.selectedKeyword == "";
                        end,
                        get = function()
                            local selected = self.db.profile.selectedKeyword;
                            if selected and selected ~= "" and self.db.profile.keywordResponses and self.db.profile.keywordResponses[selected] then
                                return self.db.profile.keywordResponses[selected].threshold or 2;
                            end
                            return 2;
                        end,
                        set = function(info, value)
                            local selected = self.db.profile.selectedKeyword;
                            if selected and selected ~= "" then
                                if not self.db.profile.keywordResponses then
                                    self.db.profile.keywordResponses = {};
                                end
                                if not self.db.profile.keywordResponses[selected] then
                                    self.db.profile.keywordResponses[selected] = {
                                        response = "",
                                        threshold = value,
                                    };
                                else
                                    self.db.profile.keywordResponses[selected].threshold = value;
                                end
                                -- Refresh to update the description text
                                AceConfig:NotifyChange(self.addonName);
                            end
                        end,
                    },
                    thresholdDescription = {
                        order = 6,
                        type = "description",
                        name = function()
                            local selected = self.db.profile.selectedKeyword;
                            local threshold = 2;
                            if selected and selected ~= "" and self.db.profile.keywordResponses and self.db.profile.keywordResponses[selected] then
                                threshold = self.db.profile.keywordResponses[selected].threshold or 2;
                            end
                            
                            local colorCode = self:GetThresholdColor(threshold);
                            local levelName = self:GetThresholdLevelName(threshold);
                            local description = self:GetThresholdDescription(threshold);
                            
                            local coloredLevelName = self:ColorText(levelName, colorCode);
                            local grayDescription = self:ColorText(description, "CCCCCC");
                            
                            return coloredLevelName .. "\n" .. grayDescription;
                        end,
                        fontSize = "small",
                        disabled = function()
                            return not self.db.profile.selectedKeyword or self.db.profile.selectedKeyword == "";
                        end,
                    },
                    deleteKeyword = {
                        order = 7,
                        type = "execute",
                        name = "Delete Selected Keyword",
                        desc = "Delete the currently selected keyword",
                        width = "full",
                        disabled = function()
                            return not self.db.profile.selectedKeyword or self.db.profile.selectedKeyword == "";
                        end,
                        func = function()
                            local selected = self.db.profile.selectedKeyword;
                            if selected and selected ~= "" and self.db.profile.keywordResponses then
                                self.db.profile.keywordResponses[selected] = nil;
                                self.db.profile.selectedKeyword = "";
                                -- Refresh the options to update the dropdown
                                AceConfig:NotifyChange(self.addonName);
                            end
                        end,
                        confirm = true,
                        confirmText = "Are you sure you want to delete this keyword?",
                    },
                },
            },
        }
    }
    
    -- register options table for the main "Coach" addon
    AceConfig:RegisterOptionsTable(self.addonName, options);

    -- add addon to the Blizzard options panel
    self.menu = AceConfigDialog:AddToBlizOptions(self.addonName, self.addonName);

    CoachConfig:Hide();
end

function Coach:IsInTrade()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i)
        if channelName then
            if channelName:find("Trade") then
                return true;
            end
        end
    end
    return false;
end

function Coach:IsInLookingForGroup()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i)
        if channelName == "LookingForGroup" then
            return true;
        end
    end
    return false;
end

function Coach:FindLFGChannelIndex()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i);
        if channelName == "LookingForGroup" then
            return id;
        end
    end
    return nil;
end

function Coach:FindTradeChannelIndex()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i);
        if channelName then
            if channelName:find("Trade") then
                return id;
            end
        end
    end
    return nil;
end


function AdvertiseLFG()
    if Coach:IsInLookingForGroup() then
        local lookingForGroupChannelID = Coach:FindLFGChannelIndex();
        SendChatMessage(Coach.db.profile.message, "CHANNEL", nil, lookingForGroupChannelID);
    else
        ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "LookingForGroup");
        print("Advertisement failed because you're not in the LookingForGroup channel.");
        print("Trying to join LookingForGroup...");
        print("Please type /join LookingForGroup and resend the advertisement.");
        C_Timer.After(7, function ()
            StaticPopup_Show("NOT_IN_LFG");
        end);
    end
end

function AdvertiseTrade()
    if not Coach.db.profile.message then 
        return print("Please enter an advertisement message.");
    end

    if Coach:IsInTrade() then
        local tradeChannelID = Coach:FindTradeChannelIndex();
        SendChatMessage(Coach.db.profile.message, "CHANNEL", nil, tradeChannelID);
    else
        print("Advertisement failed because you're not in the Trade channel.");
        print("Please type /join trade and resend the advertisement.");
        C_Timer.After(7, function ()
            StaticPopup_Show("NOT_IN_TRADE");
        end);
    end
end

function Coach:CreateMinimapIcon()
    LibDBIcon:Register(Coach.addonName, {
        icon = "Interface\\GROUPFRAME\\UI-Group-LeaderIcon",
        OnClick = function(button, buttonName, down)
            if buttonName == "RightButton" then
                Coach:ToggleChatHistory();
            else
                Coach:Toggle();
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine(self.addonName .. " |cff808080" .. GetAddOnMetadata(self.addonName, "Version"));
            tt:AddLine("|cffCCCCCCLeft Click|r to open the options");
            tt:AddLine("|cffCCCCCCRight Click|r to open chat history");
            tt:AddLine("|cffCCCCCCDrag|r to move this button");
        end,
        text = Coach.addonName,
        iconCoords = {0.05, 0.85, 0.15, 0.95},
    });

    C_Timer.After(0.25, function ()
        if self.db.profile.minimapCoords and #self.db.profile.minimapCoords > 0 then
            LibDBIcon:GetMinimapButton(Coach.addonName):SetPoint(unpack(self.db.profile.minimapCoords));
        end
        LibDBIcon:GetMinimapButton(self.addonName):SetScript("OnDragStop", function (self)
            self:SetScript("OnUpdate", nil);
            self.isMouseDown = false;
            self.icon:UpdateCoord();
            self:UnlockHighlight();

            local point, relativeFrame, relativePoint, x, y = self:GetPoint();
            Coach.db.profile.minimapCoords = { point, relativeFrame:GetName(), relativePoint, x, y };
        end);
    end);
end


function Coach:LoadStaticPopups()
    StaticPopupDialogs["NOT_IN_LFG"] = {
        text = "You weren't previously in the LFG channel. Resend your advertisement?",
        button1 = "Send Advertisement",
        button2 = "Cancel",
        timeout = 120,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS,
        OnAccept = AdvertiseLFG,
        OnCancel = function ()
            StaticPopup_Hide("NOT_IN_LFG");
        end
    };
    StaticPopupDialogs["NOT_IN_TRADE"] = {
        text = "You're not in the Trade channel. Please type /join trade and send the advertisement again.",
        button1 = "Send Advertisement",
        button2 = "Cancel",
        timeout = 120,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS,
        OnAccept = AdvertiseTrade,
        OnCancel = function ()
            StaticPopup_Hide("NOT_IN_TRADE");
        end
    };
    StaticPopupDialogs["COACH_DELETE_CHAT_HISTORY"] = {
        text = "Are you sure you want to delete the chat history of %s?",
        button1 = "Delete",
        button2 = "Cancel",
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS,
        OnAccept = function(self, data)
            Coach:ConfirmDeleteChatHistory(data);
        end,
        OnCancel = function ()
            StaticPopup_Hide("COACH_DELETE_CHAT_HISTORY");
        end
    };
end

local defaults = {
    profile = {
        isPaused = true,
        minDelayTime = 4,
        maxDelayTime = 10,
        maxInteractionsPerPlayer = 2,
        defaultResponse = "",
        enableSecondaryDefault = false,
        secondaryDefaultResponse = "",
        chatHistory = {
            -- Structure: characterName -> {{type = "incoming"/"outgoing", message = "...", timestamp = ...}, ...}
        },
        keywordResponses = {
            -- Structure: keyword -> {response = "message", threshold = 2}
            -- Example:
            -- ["help"] = {response = "I'd be happy to help you!", threshold = 2},
            -- ["coaching"] = {response = "I offer coaching services!", threshold = 2},
        },
        selectedKeyword = "",
    }
};

function Coach:OnInitialize()
    -- initialize saved variables with defaults
    self.db = LibStub("AceDB-3.0"):New("CoachDB", defaults, true);

    -- handle events
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleWhispers");

    -- load config stuff
    self:LoadStaticPopups();
    self:CreateMinimapIcon();
    self:CreateMenu();

    -- start paused
    self.db.profile.isPaused = true;
end

function Coach:OnEnable()
    -- Check if general macro named "Coach" exists
    local macroExists = false;
    local numGeneralMacros = GetNumMacros();
    
    -- Check general macros (first numGeneralMacros slots)
    for i = 1, numGeneralMacros do
        local name, icon, body = GetMacroInfo(i);
        if name == "Coach" then
            macroExists = true;
            -- Check if body is correct, update if needed
            if body ~= "/run AdvertiseLFG()" then
                EditMacro(i, "Coach", icon, "/run AdvertiseLFG()");
            end
            break;
        end
    end
    
    -- If macro doesn't exist, create it
    if not macroExists then
        CreateMacro("Coach", "INV_Misc_QuestionMark", "/run AdvertiseLFG()", false);
    end
end