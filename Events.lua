local Coach = LibStub("AceAddon-3.0"):GetAddon("Coach");
local Config = Coach.Config;

function Coach:IncrementCharacterInteractedWith(characterName)
    if self.recentlyInteractedWith[characterName] then
        self.recentlyInteractedWith[characterName] = self.recentlyInteractedWith[characterName] + 1;
    else
        self.recentlyInteractedWith[characterName] = 1;
    end
end

function Coach:SendDelayedMessage(message, characterName)
    print("  |cff00FFFF[SendDelayedMessage]|r Called for: " .. characterName);
    
    local maxInteractions = self.db.profile.maxInteractionsPerPlayer or 2;
    local currentInteractions = self.recentlyInteractedWith[characterName] or 0;
    local interactedWithTooManyTimes = currentInteractions >= maxInteractions;
    
    print("    Current interactions: " .. currentInteractions .. " / " .. maxInteractions);
    
    if interactedWithTooManyTimes then
        print("    |cffFF0000[BLOCKED]|r Player has reached max interactions, not sending message");
        return;
    end
    
    local minDelay = self.db.profile.minDelayTime or 4;
    local maxDelay = self.db.profile.maxDelayTime or 10;
    -- Ensure min doesn't exceed max
    if minDelay > maxDelay then
        minDelay = maxDelay;
    end
    
    local delay = math.random(minDelay, maxDelay);
    print("    Message: " .. message);
    print("    Delay: " .. delay .. " seconds (range: " .. minDelay .. "-" .. maxDelay .. ")");
    print("    |cff00FF00[SCHEDULED]|r Message will be sent in " .. delay .. " seconds");
    
    C_Timer.After(delay, function ()
        print("    |cff00FF00[SENDING]|r Sending message to " .. characterName .. ": " .. message);
        SendChatMessage(message, "WHISPER", nil, characterName);
        -- Save outgoing message to chat history
        self:AddOutgoingMessage(characterName, message);
    end);
    
    self:IncrementCharacterInteractedWith(characterName);
    print("    Interaction count incremented to: " .. (self.recentlyInteractedWith[characterName] or 0));
end

-- Helper function to split message into words
function Coach:SplitMessageIntoWords(message)
    local words = {};
    for word in message:gmatch("%S+") do
        table.insert(words, word);
        print("    Word #" .. #words .. ": |cffFFFF00'" .. word .. "'|r (length: " .. #word .. ")");
    end
    return words;
end

-- Helper function to check for exact word match
function Coach:CheckExactWordMatch(messageWords, keyword)
    print("    |cff00FFFF[WORD ITERATION]|r Checking exact word matches:");
    for wordIdx, word in ipairs(messageWords) do
        print("      Word #" .. wordIdx .. " ('" .. word .. "'): Comparing with '" .. keyword .. "'");
        if word == keyword then
            return true;
        end
    end
    return false;
end

-- Helper function to check for fuzzy word match
function Coach:CheckFuzzyWordMatch(messageWords, keyword, threshold)
    for wordIdx, word in ipairs(messageWords) do
        local distance = self:Levenshtein(word, keyword);
        if distance <= threshold then
            return true, distance;
        end
    end
    return false, nil;
end

-- Helper function to find keyword match in message
function Coach:FindKeywordMatch(message, messageWords, keywordResponses)
    for keyword, data in pairs(keywordResponses) do
        if not data or not data.response or data.response == "" then
            -- Skip invalid entries
        else
            -- Try exact word match first
            if self:CheckExactWordMatch(messageWords, keyword) then
                return data.response, keyword, "exact word";
            end
            
            -- Try fuzzy match if no exact match
            local threshold = data.threshold or 2;
            local matched, distance = self:CheckFuzzyWordMatch(messageWords, keyword, threshold);
            if matched then
                return data.response, keyword, "fuzzy word (distance: " .. distance .. ")";
            end
        end
    end
    return nil, nil, nil;
end

-- Helper function to get default response based on interaction count
function Coach:GetDefaultResponse(currentInteractions)
    local enableSecondary = self.db.profile.enableSecondaryDefault or false;
    
    if not enableSecondary then
        return self.db.profile.defaultResponse or "";
    end
    
    -- Alternate: 1st/3rd/etc use default, 2nd/4th/etc use secondary
    local useSecondary = (currentInteractions % 2) == 1;
    
    if useSecondary then
        local secondary = self.db.profile.secondaryDefaultResponse or "";
        return (secondary:match("%S") and secondary) or (self.db.profile.defaultResponse or "");
    else
        return self.db.profile.defaultResponse or "";
    end
end

function Coach:HandleWhispers(event, message, sender, ...)
    -- Save incoming message to chat history (before lowercasing)
    local originalMessage = message;
    local whispererCharacterName = sender:match("([^%-]+)");
    self:AddIncomingMessage(whispererCharacterName, originalMessage);
    
    -- Check if paused
    if self.db.profile.isPaused then
        self:Print("Addon is paused, not responding to whispers.");
        return;
    end
    
    message = message:lower();
    
    -- Check interaction limits
    local maxInteractions = self.db.profile.maxInteractionsPerPlayer or 2;
    local currentInteractions = self.recentlyInteractedWith[whispererCharacterName] or 0;
    
    if currentInteractions >= maxInteractions then
        self:Print("Player has reached max interactions (" .. currentInteractions .. "/" .. maxInteractions .. "), ignoring.");
        return;
    end
    
    -- Split message into words
    local messageWords = self:SplitMessageIntoWords(message);
    
    -- Try to find keyword match
    local keywordResponses = self.db.profile.keywordResponses or {};
    local matchedResponse, matchedKeyword, matchType = self:FindKeywordMatch(message, messageWords, keywordResponses);
    
    -- Determine and send response
    local responseToSend = matchedResponse or self:GetDefaultResponse(currentInteractions);
    
    if responseToSend and responseToSend:match("%S") then
        self:SendDelayedMessage(responseToSend, whispererCharacterName);
    end
end