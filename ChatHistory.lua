local Coach = LibStub("AceAddon-3.0"):GetAddon("Coach");
local AceGUI = LibStub("AceGUI-3.0");

local chatHistoryFrame = nil;
local selectedCharacter = nil;
local refreshTimer = nil;

-- Helper function to extract server name from character name (everything after first dash)
function Coach:GetServerName(characterName)
    if not characterName then return ""; end
    local dashPos = string.find(characterName, "-");
    if dashPos then
        return string.sub(characterName, dashPos + 1);
    end
    return "";
end

-- Helper function to format timestamp
function Coach:FormatTimestamp(timestamp)
    if not timestamp then return "[Unknown]"; end
    
    -- Get current time for comparison
    local currentTime = time();
    local timeDiff = currentTime - timestamp;
    
    -- If less than a minute ago, show seconds
    if timeDiff < 60 then
        return string.format("[%ds ago]", timeDiff);
    -- If less than an hour ago, show minutes
    elseif timeDiff < 3600 then
        return string.format("[%dm ago]", math.floor(timeDiff / 60));
    -- If less than a day ago, show hours
    elseif timeDiff < 86400 then
        return string.format("[%dh ago]", math.floor(timeDiff / 3600));
    -- Otherwise show days
    else
        local days = math.floor(timeDiff / 86400);
        if days == 1 then
            return "[Yesterday]";
        elseif days < 7 then
            return string.format("[%dd ago]", days);
        else
            return string.format("[%dd ago]", days);
        end
    end
end

-- Add incoming message to chat history
function Coach:AddIncomingMessage(characterName, message)
    if not self.db.profile.chatHistory then
        self.db.profile.chatHistory = {};
    end
    
    if not self.db.profile.chatHistory[characterName] then
        self.db.profile.chatHistory[characterName] = {};
    end
    
    table.insert(self.db.profile.chatHistory[characterName], {
        type = "incoming",
        message = message,
        timestamp = time(),
    });
    
    -- Limit history to last 100 messages per character
    if #self.db.profile.chatHistory[characterName] > 100 then
        table.remove(self.db.profile.chatHistory[characterName], 1);
    end
end

-- Add outgoing message to chat history
function Coach:AddOutgoingMessage(characterName, message)
    if not self.db.profile.chatHistory then
        self.db.profile.chatHistory = {};
    end
    
    if not self.db.profile.chatHistory[characterName] then
        self.db.profile.chatHistory[characterName] = {};
    end
    
    table.insert(self.db.profile.chatHistory[characterName], {
        type = "outgoing",
        message = message,
        timestamp = time(),
    });
    
    -- Limit history to last 100 messages per character
    if #self.db.profile.chatHistory[characterName] > 100 then
        table.remove(self.db.profile.chatHistory[characterName], 1);
    end
end

-- Refresh the chat display
function Coach:RefreshChatDisplay()
    if not chatHistoryFrame or not selectedCharacter then
        return;
    end
    
    local chatScroll = chatHistoryFrame:GetUserData("chatScroll");
    if not chatScroll then
        return;
    end
    
    -- Clear existing content
    chatScroll:ReleaseChildren();
    
    local history = self.db.profile.chatHistory[selectedCharacter] or {};
    
    if #history == 0 then
        local noMessages = AceGUI:Create("Label");
        noMessages:SetText("No messages with this character.");
        noMessages:SetFullWidth(true);
        chatScroll:AddChild(noMessages);
    else
        for i, entry in ipairs(history) do
            local messageFrame = AceGUI:Create("Label");
            local timestamp = self:FormatTimestamp(entry.timestamp);
            local color = entry.type == "incoming" and "|cff00FF00" or "|cff0088FF";
            local prefix = entry.type == "incoming" and "[" .. selectedCharacter .. "]" or "[You]";
            
            messageFrame:SetText(timestamp .. " " .. color .. prefix .. "|r: " .. entry.message);
            messageFrame:SetFullWidth(true);
            messageFrame.label:SetJustifyH("LEFT");
            chatScroll:AddChild(messageFrame);
        end
    end
end

-- Refresh character list
function Coach:RefreshCharacterList()
    if not chatHistoryFrame then
        return;
    end
    
    local characterList = chatHistoryFrame:GetUserData("characterList");
    if not characterList then
        return;
    end
    
    characterList:ReleaseChildren();
    
    local chatHistory = self.db.profile.chatHistory or {};
    local characterNames = {};
    
    for name, _ in pairs(chatHistory) do
        table.insert(characterNames, name);
    end
    
    table.sort(characterNames);
    
    if #characterNames == 0 then
        local noChars = AceGUI:Create("Label");
        noChars:SetText("No chat history yet.");
        noChars:SetFullWidth(true);
        characterList:AddChild(noChars);
    else
        for _, name in ipairs(characterNames) do
            local button = AceGUI:Create("InteractiveLabel");
            local serverName = self:GetServerName(name);
            local displayText = name;
            if serverName ~= "" then
                displayText = name .. " |cff808080(" .. serverName .. ")|r";
            end
            button:SetText(displayText);
            button:SetFullWidth(true);
            if selectedCharacter == name then
                -- Set yellowish background with low alpha instead of text color
                if button.frame then
                    if not button.frame.bgTexture then
                        button.frame.bgTexture = button.frame:CreateTexture(nil, "BACKGROUND");
                        button.frame.bgTexture:SetAllPoints(button.frame);
                    end
                    button.frame.bgTexture:SetColorTexture(1, 1, 0.3, 0.2); -- Yellowish with low alpha
                end
            else
                -- Clear background if not selected
                if button.frame and button.frame.bgTexture then
                    button.frame.bgTexture:SetColorTexture(0, 0, 0, 0);
                end
            end
            button:SetCallback("OnClick", function()
                selectedCharacter = name;
                self:RefreshCharacterList();
                self:RefreshChatDisplay();
            end);
            characterList:AddChild(button);
        end
    end
end



-- Create chat history GUI
function Coach:CreateChatHistoryGUI()
    if chatHistoryFrame then
        chatHistoryFrame:Show();
        -- Start refresh timer if window already exists
        if refreshTimer then
            refreshTimer:Cancel();
        end
        refreshTimer = C_Timer.NewTicker(1.0, function()
            if chatHistoryFrame and chatHistoryFrame:IsShown() then
                self:RefreshChatDisplay();
            else
                -- Stop timer if window is hidden
                if refreshTimer then
                    refreshTimer:Cancel();
                    refreshTimer = nil;
                end
            end
        end);
        return;
    end

    local minWidth = 550;
    local minHeight = 500;
    
    -- Create main window
    chatHistoryFrame = AceGUI:Create("Window");
    chatHistoryFrame:SetTitle("Coach - Chat History");
    chatHistoryFrame:SetLayout("Fill");
    chatHistoryFrame:SetHeight(minHeight);
    chatHistoryFrame:SetWidth(minWidth);
    chatHistoryFrame:SetCallback("OnClose", function(widget)
        widget:Hide();
        -- Stop refresh timer when window is closed
        if refreshTimer then
            refreshTimer:Cancel();
            refreshTimer = nil;
        end
    end);
    
    -- Hook into frame resize events after frame is created
    C_Timer.After(0.2, function()
        if chatHistoryFrame and chatHistoryFrame.frame then
            local frame = chatHistoryFrame.frame;
            
            -- Hook into OnSizeChanged to detect window resizing
            local originalOnSizeChanged = frame:GetScript("OnSizeChanged");
            frame:SetScript("OnSizeChanged", function(self, width, height)
                -- min height
                if height < minHeight then
                    height = minHeight;
                    self:SetHeight(minHeight);
                end
                -- min width
                if width < minWidth then
                    width = minWidth;
                    self:SetWidth(minWidth);
                end
            end);
        end
    end);
    chatHistoryFrame:SetCallback("OnShow", function(widget)
        -- Force layout recalculation when window is shown
        C_Timer.After(0.1, function()
            if widget and widget.frame then
                widget:DoLayout();
                local mainContainer = widget:GetUserData("mainContainer");
                if mainContainer then
                    mainContainer:DoLayout();
                end
            end
        end);
        
        -- Start refresh timer when window is shown
        if refreshTimer then
            refreshTimer:Cancel();
        end
        refreshTimer = C_Timer.NewTicker(1.0, function()
            if chatHistoryFrame and chatHistoryFrame:IsShown() then
                self:RefreshChatDisplay();
            else
                -- Stop timer if window is hidden
                if refreshTimer then
                    refreshTimer:Cancel();
                    refreshTimer = nil;
                end
            end
        end);
    end);
    
    -- Set min resize after frame is created - try multiple times to ensure it works
    local function setMinResize()
        if chatHistoryFrame and chatHistoryFrame.frame then
            local frame = chatHistoryFrame.frame;
            if frame.SetMinResize then
                frame:SetMinResize(minWidth, minHeight);
                return true;
            end
        end
        return false;
    end
    
    -- Try immediately
    if not setMinResize() then
        -- Try after short delay
        C_Timer.After(0.1, function()
            if not setMinResize() then
                -- Try one more time after longer delay
                C_Timer.After(0.2, setMinResize);
            end
        end);
    end
    
    -- Create main container with horizontal layout
    local mainContainer = AceGUI:Create("SimpleGroup");
    mainContainer:SetFullWidth(true);
    mainContainer:SetFullHeight(true);
    mainContainer:SetLayout("Flow");
    chatHistoryFrame:AddChild(mainContainer);
    chatHistoryFrame:SetUserData("mainContainer", mainContainer);
    
    -- Character list (left side) - fixed width
    local characterListGroup = AceGUI:Create("InlineGroup");
    characterListGroup:SetTitle("Characters");
    characterListGroup:SetWidth(200);
    characterListGroup:SetFullHeight(true);
    characterListGroup:SetLayout("Fill");
    mainContainer:AddChild(characterListGroup);
    
    local characterList = AceGUI:Create("ScrollFrame");
    characterList:SetLayout("List");
    characterList:SetFullWidth(true);
    characterList:SetFullHeight(true);
    characterListGroup:AddChild(characterList);
    chatHistoryFrame:SetUserData("characterList", characterList);
    
    local chatGroup = AceGUI:Create("InlineGroup");
    chatGroup:SetTitle("Chat History");
    chatGroup:SetFullHeight(true);
    chatGroup:SetLayout("Fill");
    mainContainer:AddChild(chatGroup);
    chatHistoryFrame:SetUserData("chatGroup", chatGroup);
    
    local chatScroll = AceGUI:Create("ScrollFrame");
    chatScroll:SetLayout("List");
    chatScroll:SetFullWidth(true);
    chatScroll:SetFullHeight(true);
    chatGroup:AddChild(chatScroll);
    chatHistoryFrame:SetUserData("chatScroll", chatScroll);
    
    -- Add initial message if no character selected
    local initialMessage = AceGUI:Create("Label");
    initialMessage:SetText("Select a character from the list to view chat history.");
    initialMessage:SetFullWidth(true);
    chatScroll:AddChild(initialMessage);
    
    -- Refresh displays
    self:RefreshCharacterList();
    
    chatHistoryFrame:Show();
    
    -- Force layout calculation after showing
    C_Timer.After(0.05, function()
        if chatHistoryFrame and chatHistoryFrame.frame then
            chatHistoryFrame:DoLayout();
            
            if mainContainer then
                mainContainer:DoLayout();
            end
        end
    end);
    
    -- Move window 1px at a time to force layout updates (3 right, 3 left)
    C_Timer.After(0.1, function()
        if chatHistoryFrame and chatHistoryFrame.frame then
            local frame = chatHistoryFrame.frame;
            local originalLeft, originalTop = frame:GetLeft(), frame:GetTop();
            
            -- Move right 3 times (1px each)
            for i = 1, 3 do
                C_Timer.After(i * 0.01, function()
                    if frame and frame:IsVisible() then
                        local left, top = frame:GetLeft(), frame:GetTop();
                        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left + 1, top);
                        chatHistoryFrame:DoLayout();
                        if mainContainer then mainContainer:DoLayout(); end
                    end
                end);
            end
            
            -- Move back left 3 times (1px each)
            for i = 1, 3 do
                C_Timer.After((3 + i) * 0.01, function()
                    if frame and frame:IsVisible() then
                        local left, top = frame:GetLeft(), frame:GetTop();
                        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left - 1, top);
                        chatHistoryFrame:DoLayout();
                        if mainContainer then mainContainer:DoLayout(); end
                    end
                end);
            end
            
            -- Return to original position after all movements
            C_Timer.After(0.07, function()
                if frame and frame:IsVisible() and originalLeft and originalTop then
                    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", originalLeft, originalTop);
                    chatHistoryFrame:DoLayout();
                    if mainContainer then mainContainer:DoLayout(); end
                end
            end);
        end
    end);
end

-- Toggle chat history GUI
function Coach:ToggleChatHistory()
    if chatHistoryFrame and chatHistoryFrame:IsShown() then
        chatHistoryFrame:Hide();
        -- Stop refresh timer when window is hidden
        if refreshTimer then
            refreshTimer:Cancel();
            refreshTimer = nil;
        end
    else
        self:CreateChatHistoryGUI();
    end
end

