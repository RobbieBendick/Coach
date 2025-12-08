local Coach = LibStub("AceAddon-3.0"):GetAddon("Coach");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

function Coach:ResetTemplate()
    Coach.db.profile.maxDPS = "";
    Coach.db.profile.maxTanks = "";
    Coach.db.profile.maxHealers = "";
    Coach.db.profile.maxRangedDPS = "";
    Coach.db.profile.maxMeleeDPS = "";
    Coach.db.profile.minGearscore = "";
    Coach.db.profile.maxTotalPlayers = "";

    for roleName in pairs(Coach.roles) do
        for i, class in ipairs(Coach.classes) do
            if Coach.db.profile[roleName .. class .. "Maximum"] and Coach:Contains(Coach.roleClasses[roleName], class) then
                Coach.db.profile[roleName .. class .. "Maximum"] = "";
            end
        end
    end

end

function Coach:CheckForPlayerRole()
    local selectedRole = Coach.db.profile.selectedRole;
    if not selectedRole then return end
    if selectedRole == "ranged_dps" then
        if Coach.db.profile.maxDPS ~= "" and Coach.db.profile.maxDPS ~= 0 then
            Coach.db.profile.maxDPS = Coach.db.profile.maxDPS - 1;
        end
        if Coach.db.profile.maxRangedDPS ~= "" and Coach.db.profile.maxRangedDPS ~= 0 then
            Coach.db.profile.maxRangedDPS = Coach.db.profile.maxRangedDPS - 1;
        end
    elseif selectedRole == "melee_dps" then
        if Coach.db.profile.maxDPS ~= "" and Coach.db.profile.maxDPS ~= 0 then
            Coach.db.profile.maxDPS = Coach.db.profile.maxDPS - 1;
        end
        if Coach.db.profile.maxMeleeDPS ~= "" and Coach.db.profile.maxMeleeDPS ~= 0 then
            Coach.db.profile.maxMeleeDPS = Coach.db.profile.maxMeleeDPS - 1;
        end
    elseif selectedRole == "tank" then
        if Coach.db.profile.maxTanks ~= "" and Coach.db.profile.maxTanks ~= 0 then
            Coach.db.profile.maxTanks = Coach.db.profile.maxTanks - 1;
        end
    elseif selectedRole == "healer" then
        if Coach.db.profile.maxHealers ~= "" and Coach.db.profile.maxHealers ~= 0 then
            Coach.db.profile.maxHealers = Coach.db.profile.maxHealers - 1;
        end
    end
end

function Coach:IcecrownCitadel25Template()
    Coach:ResetTemplate()
    Coach.db.profile.maxDPS = 17;
    Coach.db.profile.maxTanks = 2;
    Coach.db.profile.maxHealers = 6;
    Coach.db.profile.maxRangedDPS = 10;
    Coach.db.profile.maxMeleeDPS = 10;
    Coach.db.profile.minGearscore = 5800;
    Coach.db.profile.maxTotalPlayers = 25;
    Coach.db.profile["healerPRIESTMaximum"] = 1;
    Coach.db.profile["healerSHAMANMaximum"] = 2;
    Coach.db.profile["healerPALADINMaximum"] = 2;
    Coach.db.profile["healerDRUIDMaximum"] = 2;
    Coach.db.profile["tankDRUIDMaximum"] = 1;


    Coach:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(Coach.addonName);
    Coach:UpdateGUI();
end

function Coach:IcecrownCitadel10Template()
    Coach:ResetTemplate()
    Coach.db.profile.maxDPS = 5;
    Coach.db.profile.maxTanks = 2;
    Coach.db.profile.maxHealers = 3;
    Coach.db.profile.maxRangedDPS = 4;
    Coach.db.profile.maxMeleeDPS = 4;
    Coach.db.profile.minGearscore = 5700;
    Coach.db.profile.maxTotalPlayers = 10;

    Coach:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(Coach.addonName);
    Coach:UpdateGUI();
end

function Coach:RubySanctum10Template()
    Coach:ResetTemplate()
    Coach.db.profile.maxDPS = 5;
    Coach.db.profile.maxTanks = 2;
    Coach.db.profile.maxHealers = 3;
    Coach.db.profile.maxRangedDPS = 4;
    Coach.db.profile.maxMeleeDPS = 4;
    Coach.db.profile.minGearscore = 5700;
    Coach.db.profile.maxTotalPlayers = 10;

    Coach:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(Coach.addonName);
    Coach:UpdateGUI();
end

function Coach:RubySanctum25Template()
    Coach:ResetTemplate()
    Coach.db.profile.maxDPS = 17;
    Coach.db.profile.maxTanks = 2;
    Coach.db.profile.maxHealers = 6;
    Coach.db.profile.maxRangedDPS = 10;
    Coach.db.profile.maxMeleeDPS = 10;
    Coach.db.profile.minGearscore = 5800;
    Coach.db.profile.maxTotalPlayers = 25;

    Coach:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(Coach.addonName);
    Coach:UpdateGUI();
end

function Coach:VaultOfArchavon25Template()
    Coach:ResetTemplate()
    Coach.db.profile.minGearscore = 4500;
    Coach.db.profile.maxTanks = 2;
    Coach.db.profile.maxHealers = 4;
    Coach.db.profile.maxDPS = 15;
    Coach.db.profile.maxMeleeDPS = "";
    Coach.db.profile.maxRangedDPS = "";

    Coach.db.profile.maxTotalPlayers = 25;

    -- set 1 for each role/class pair
    for roleName in pairs(Coach.roles) do
        for i, class in ipairs(Coach.classes) do
            if Coach:Contains(Coach.roleClasses[roleName], class) then
                Coach.db.profile[roleName .. class .. "Maximum"] = 1;
            end
        end
    end
    Coach:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(Coach.addonName);
    Coach:UpdateGUI();
end

function Coach:VaultOfArchavon10Template()
    Coach:ResetTemplate()
    Coach.db.profile.minGearscore = 4500;
    Coach.db.profile.maxTanks = 2;
    Coach.db.profile.maxHealers = 3;
    Coach.db.profile.maxDPS = 5;
    Coach.db.profile.maxMeleeDPS = "";
    Coach.db.profile.maxRangedDPS = "";
    Coach.db.profile.maxTotalPlayers = 10;

    -- set 1 for each role/class pair
    for roleName in pairs(Coach.roles) do
        for i, class in ipairs(Coach.classes) do
            if Coach:Contains(Coach.roleClasses[roleName], class) then
                Coach.db.profile[roleName .. class .. "Maximum"] = 1;
            end
        end
    end


    Coach:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(Coach.addonName);
    Coach:UpdateGUI();
end

Coach.raidTemplates = {
    ["Reset"] = Coach.ResetTemplate,
    ["Icecrown Citadel 25"] = Coach.IcecrownCitadel25Template,
    ["Icecrown Citadel 10"] = Coach.IcecrownCitadel10Template,
    ["Ruby Sanctum 25"] = Coach.RubySanctum25Template,
    ["Ruby Sanctum 10"] = Coach.RubySanctum10Template,
    ["Vault Of Archavon 25"] = Coach.VaultOfArchavon25Template,
    ["Vault Of Archavon 10"] = Coach.VaultOfArchavon10Template,
}
