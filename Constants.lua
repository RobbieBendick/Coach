local Coach = _G.LibStub("AceAddon-3.0"):NewAddon("Coach", "AceConsole-3.0", "AceEvent-3.0");
Coach.addonName = "Coach";
Coach.recentlyInteractedWith = {};

Coach.classAbberviations = {
    ["rog"] = "ROGUE",
    ["rogue"] = "ROGUE",

    ["warrior"] = "WARRIOR",
    ["war"] = "WARRIOR",

    ["disc"] = "PRIEST",
    ["priest"] = "PRIEST",
    ["pri"] = "PRIEST",
    ["dpr"] = "PRIEST",

    ["mage"] = "MAGE",
    ["fire"] = "MAGE",

    ["hunter"] = "HUNTER",
    ["hunt"] = "HUNTER",
    ["surv"] = "HUNTER",
    ["mark"] = "HUNTER",
    ["bm"] = "HUNTER",
    ["beast"] = "HUNTER",
    
    ["death"] = "DEATHKNIGHT",
    ["dk"] = "DEATHKNIGHT",
    ["unh"] = "DEATHKNIGHT",

    ["warlock"] = "WARLOCK",
    ["lock"] = "WARLOCK",

    ["shaman"] = "SHAMAN",
    ["sham"] = "SHAMAN",
    ["ele"] = "SHAMAN",
    ["enh"] = "SHAMAN",

    ["boomy"] = "DRUID",
    ["boomkin"] = "DRUID",
    ["balance"] = "DRUID",
    ["moon"] = "DRUID",
    ["feral"] = "DRUID",
    ["rdruid"] = "DRUID",
    ["dru"] = "DRUID",
    ["druid"] = "DRUID",
    ["tree"] = "DRUID",

    ["pal"] = "PALADIN",
    ["pally"] = "PALADIN",
    ["paladin"] = "PALADIN",
    ["ret"] = "PALADIN",

    ["monk"] = "MONK",
    ["ww"] = "MONK",
    ["mw"] = "MONK",
    ["mist"] = "MONK",
    ["windwalker"] = "MONK",
}

Coach.classes = {
};

function Coach:GetAllClasses()
    if #self.classes > 0 then
        return self.classes;
    end

    local classInfo = C_CreatureInfo.GetClassInfo
    for classID = 1, 50 do
        local info = classInfo(classID)
        if info then
            table.insert(self.classes, info.className)
        end
    end

    return self.classes;
end

function Coach:Contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true;
        end
    end
    return false;
end
