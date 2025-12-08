local Coach = LibStub("AceAddon-3.0"):GetAddon("Coach");

function Coach:Levenshtein(str1, str2)
    local len1 = #str1;
    local len2 = #str2;
    local matrix = {};
    
    for i = 0, len1 do
        matrix[i] = {};
        for j = 0, len2 do
            if i == 0 then
                matrix[i][j] = j;
            elseif j == 0 then
                matrix[i][j] = i;
            else
                matrix[i][j] = 0;
            end
        end
    end
    
    -- compute the Levenshtein distance
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (str1:sub(i, i) ~= str2:sub(j, j)) and 1 or 0;
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,
                matrix[i][j-1] + 1,
                matrix[i-1][j-1] + cost
            );
        end
    end
    
    return matrix[len1][len2];
end

function Coach:FuzzyFind(message, keyWords, threshold)
    local closestKeyword, closestKeywordDistance;
    for _, keyWord in ipairs(keyWords) do
        local distance = self:Levenshtein(message, keyWord);
        if distance <= threshold then
            if closestKeyword == nil or closestKeywordDistance == nil or closestKeywordDistance < distance then
                closestKeyword = keyWord;
                closestKeywordDistance = distance;
            end
        end
    end
    return closestKeyword;
end

function Coach:FindClass(message)
    -- check for exact matches first
    for abbreviation, className in pairs(self.classAbberviations) do
        if message:find(abbreviation) then
            return className;
        end
    end

    local words = {}
    for word in message:gmatch("%S+") do
        table.insert(words, word);
    end
    
    -- fuzzy find
    for _, word in ipairs(words) do
        for abbreviation, className in pairs(self.classAbberviations) do
            local closestMatch = self:FuzzyFind(word, {abbreviation}, (#word > 3 and 2 or 1));
            if closestMatch then
                return className;
            end
        end
    end

    return nil;
end

