---@class Settings
---This class stores settings for the ContractBoost mod
Settings = {}
local Settings_mt = Class(Settings)

---Creates a new settings instance
---@return table @The new instance
function Settings.new()
    local self = setmetatable({}, Settings_mt)
    self.debugMode = SettingsManager.defaultConfig.debugMode
    self.enableInGameSettingsMenu = SettingsManager.defaultConfig.enableInGameSettingsMenu

    -- set via in-gmae menu
    self.enableContractValueOverrides = SettingsManager.defaultConfig.enableContractValueOverrides
    self.rewardFactor = SettingsManager.defaultConfig.rewardFactor
    self.maxContractsPerFarm = SettingsManager.defaultConfig.maxContractsPerFarm
    self.maxContractsPerType = SettingsManager.defaultConfig.maxContractsPerType
    self.maxContractsOverall = SettingsManager.defaultConfig.maxContractsOverall   

    -- boolean settings 
    self.enableStrawFromHarvestMissions = SettingsManager.defaultConfig.enableStrawFromHarvestMissions
    self.enableSwathingForHarvestMissions = SettingsManager.defaultConfig.enableSwathingForHarvestMissions
    self.enableGrassFromMowingMissions = SettingsManager.defaultConfig.enableGrassFromMowingMissions
    self.enableHayFromTedderMissions = SettingsManager.defaultConfig.enableHayFromTedderMissions
    self.enableStonePickingFromMissions = SettingsManager.defaultConfig.enableStonePickingFromMissions
    self.enableFieldworkToolFillItems = SettingsManager.defaultConfig.enableFieldworkToolFillItems
    self.enableCollectingBalesFromMissions = SettingsManager.defaultConfig.enableCollectingBalesFromMissions
    self.enableCustomGrassFieldsForMissions = SettingsManager.defaultConfig.enableCustomGrassFieldsForMissions
    self.preferStrawHarvestMissions = SettingsManager.defaultConfig.preferStrawHarvestMissions

    -- harvest settings
    self.enableHarvestContractNewCrops = SettingsManager.defaultConfig.enableHarvestContractNewCrops
    self.enableHarvestContractPremiumCrops = SettingsManager.defaultConfig.enableHarvestContractPremiumCrops
    self.enableHarvestContractRootCrops = SettingsManager.defaultConfig.enableHarvestContractRootCrops
    self.enableHarvestContractSugarcane = SettingsManager.defaultConfig.enableHarvestContractSugarcane
    self.enableHarvestContractCotton = SettingsManager.defaultConfig.enableHarvestContractCotton

    -- customizing
    self.customRewards = SettingsManager.defaultConfig.customRewards
    self.customMaxPerType = SettingsManager.defaultConfig.customMaxPerType

    self:initializeListeners()

    Logging.info(MOD_NAME .. ":SETTINGS :: initialized")
    return self
end

---Stores the setting into the local opbject
---@param settingName string @The name of the setting, in dot notation for nested settings
---@param settingParent string|nil @The name of the setting, in dot notation for nested settings
function Settings:onSettingsChange(settingName,settingParent)
    local name = self:cleanSettingName(settingName, settingParent)
    if self.debugMode then Logging.info(MOD_NAME .. ":SETTINGS :: settingChanged %s%s", settingParent and settingParent..".", name) end
    self:publishNewSettings()
    ContractBoost:syncSettings()
end

---Retrieves the stored setting by name
---@param settingName string @The name of the setting
---@param settingParent string|nil @The name of the parent of the setting
---@return string|boolean @The current value of the requested setting
function Settings:getSetting(settingName, settingParent)
    local name = self:cleanSettingName(settingName, settingParent)
    if self.debugMode then Logging.info(MOD_NAME .. ":SETTINGS :: settingChanged %s%s", settingParent and settingParent..".", name) end
    if settingParent then
        return self[settingParent][name]
    else
        return self[name]
    end
end

---Retrieves the all settings at once
---@return table @The current index
function Settings:getSettings()
    return self
end

---Retrieves the all settings at once
---@return table @The current index
function Settings:cleanSettingName(settingName, settingParent)
    local name = settingName
    if settingParent == 'customRewards' then
        name = name:gsub('%Reward', '')
    elseif settingParent == 'customMaxPerType' then
        name = name:gsub('%MaxPerType', '')
    end

    return name
end

---Publishes new settings in case of multiplayer
function Settings:publishNewSettings()
    if g_server ~= nil then
        if self.debugMode then Logging.info(MOD_NAME .. ":SETTINGS.publishNewSettings SERVER") end
        -- Broadcast to other clients, if any are connected
        g_server:broadcastEvent(SettingsChangeEvent.new())
    else
        if self.debugMode then Logging.info(MOD_NAME .. ":SETTINGS.publishNewSettings CLIENT") end
        -- Ask the server to broadcast the event
        g_client:getServerConnection():sendEvent(SettingsChangeEvent.new())
    end
end


---Recevies the initial settings from the server when joining a multiplayer game
---@param streamId any @The ID of the stream to read from
---@param connection any @Unused
function Settings:onReadStream(streamId, connection)
    if self.debugMode then Logging.info(MOD_NAME .. ":SETTINGS :: Receiving new settings", streamId) end

    -- set via console command
    self.debugMode = streamReadBool(streamId)
    
    -- private, can only be set manually
    self.enableInGameSettingsMenu = streamReadBool(streamId)

    -- set via in-gmae menu
    self.enableContractValueOverrides = streamReadBool(streamId)
    self.rewardFactor = streamReadFloat32(streamId)
    self.maxContractsPerFarm = streamReadInt16(streamId)
    self.maxContractsPerType = streamReadInt16(streamId)
    self.maxContractsOverall = streamReadInt16(streamId)

    -- boolean settings 
    self.enableStrawFromHarvestMissions = streamReadBool(streamId)
    self.enableSwathingForHarvestMissions = streamReadBool(streamId)
    self.enableGrassFromMowingMissions = streamReadBool(streamId)
    self.enableHayFromTedderMissions = streamReadBool(streamId)
    self.enableStonePickingFromMissions = streamReadBool(streamId)
    self.enableCollectingBalesFromMissions = streamReadBool(streamId)
    self.enableFieldworkToolFillItems = streamReadBool(streamId)
    self.enableCustomGrassFieldsForMissions = streamReadBool(streamId)
    self.preferStrawHarvestMissions = streamReadBool(streamId)

    -- harvest settings
    self.enableHarvestContractNewCrops = streamReadBool(streamId)
    self.enableHarvestContractPremiumCrops = streamReadBool(streamId)
    self.enableHarvestContractRootCrops = streamReadBool(streamId)
    self.enableHarvestContractSugarcane = streamReadBool(streamId)
    self.enableHarvestContractCotton = streamReadBool(streamId)

    -- custom settings
    self.customRewards = {}
    for _, missionType in SettingsManager.missionTypes do
        if streamReadBool(streamId) then
            self.customRewards[missionType] = streamReadInt16(streamId)
        else
            self.customRewards[missionType] = nil
        end
    end

    self.customMaxPerType = {}
    for _, missionType in SettingsManager.missionTypes do
        if streamReadBool(streamId) then
            self.customMaxPerType[missionType] = streamReadInt16(streamId)
        else
            self.customMaxPerType[missionType] = nil
        end
    end

    Logging.info(MOD_NAME .. ":SETTINGS :: Completed recieving new settings", streamId)
    SettingsManager.logBoostSettings(self, 1)

    -- ensure that we keep the visual settings up to date
    ContractBoost:syncSettings()

end

---Sends the current settings to a client which is connecting to a multiplayer game
---@param streamId any @The ID of the stream to write to
---@param connection any @Unused
function Settings:onWriteStream(streamId, connection)
    if self.debugMode then Logging.info(MOD_NAME .. ":SETTINGS :: Sending new settings", streamId) end

    -- set via console command
    streamWriteBool(streamId, self.debugMode)
    
    -- private, can only be set manually
    streamWriteBool(streamId, self.enableInGameSettingsMenu)

    -- set via in-game menu
    streamWriteBool(streamId, self.enableContractValueOverrides)
    streamWriteFloat32(streamId, self.rewardFactor)
    streamWriteInt16(streamId, self.maxContractsPerFarm)
    streamWriteInt16(streamId, self.maxContractsPerType)
    streamWriteInt16(streamId, self.maxContractsOverall)

    -- boolean settings
    streamWriteBool(streamId, self.enableStrawFromHarvestMissions)
    streamWriteBool(streamId, self.enableSwathingForHarvestMissions)
    streamWriteBool(streamId, self.enableGrassFromMowingMissions)
    streamWriteBool(streamId, self.enableHayFromTedderMissions)
    streamWriteBool(streamId, self.enableStonePickingFromMissions)
    streamWriteBool(streamId, self.enableCollectingBalesFromMissions)
    streamWriteBool(streamId, self.enableFieldworkToolFillItems)
    streamWriteBool(streamId, self.enableCustomGrassFieldsForMissions)
    streamWriteBool(streamId, self.preferStrawHarvestMissions)

    -- harvest settings
    streamWriteBool(streamId, self.enableHarvestContractNewCrops)
    streamWriteBool(streamId, self.enableHarvestContractPremiumCrops)
    streamWriteBool(streamId, self.enableHarvestContractRootCrops)
    streamWriteBool(streamId, self.enableHarvestContractSugarcane)
    streamWriteBool(streamId, self.enableHarvestContractCotton)

    -- custom settings
    for _, missionType in SettingsManager.missionTypes do
        if streamWriteBool(streamId, self.customRewards[missionType] ~= nil) then
            streamWriteInt16(streamId, self.customRewards[missionType])
        end
    end

    for _, missionType in SettingsManager.missionTypes do
        if streamWriteBool(streamId, self.customMaxPerType[missionType] ~= nil) then
            streamWriteInt16(streamId, self.customMaxPerType[missionType])
        end
    end

    Logging.info(MOD_NAME .. ":SETTINGS :: Completed sending new settings", streamId)
end


function Settings:initializeListeners()
    if self.debugMode then Logging.info(MOD_NAME .. ":SETTINGS :: initialize read/write listeners") end
    local settings = self

    Player.readStream = Utils.appendedFunction(Player.readStream, function(player, streamId, connection)
        settings:onReadStream(streamId, connection)
    end)

    Player.writeStream = Utils.appendedFunction(Player.writeStream, function(player, streamId, connection)
        settings:onWriteStream(streamId, connection)
    end)
end