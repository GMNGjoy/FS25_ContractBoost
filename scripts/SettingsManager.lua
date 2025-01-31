--- XML Config Loader
-- @author GMNGjoy
-- @copyright 12/16/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal
---This class is responsible for loading User Settings
---@class SettingsManager
---@field loadComplete boolean @Have we loaded the configuration?
---@field loadDebug boolean @Is debugging turned on for this class
---@field defaultConfig table @default values for all settings
---@field loadedConfig table|nil @loaded values for all settings
---@field modSettingsConfigFile string @depreciated user configuration filename previously located in modSettings 
---@field savegameConfigFile string @savegame configuration file
---@field xmlTag string @the root xml tag
---@field xmlSchema table @the configured xml schema
---@field missionTypes table @re-used set of mission types
SettingsManager = {}
local XMLTAG = "contractBoost"
SettingsManager.missionTypes = {
    "baleMission",
    "baleWrapMission",
    "plowMission",
    "cultivateMission",
    "sowMission",
    "harvestMission",
    "hoeMission",
    "weedMission",
    "herbicideMission",
    "fertilizeMission",
    "mowMission",
    "tedderMission",
    "stonePickMission",
    "deadwoodMission",
    "treeTransportMission",
    "destructibleRockMission"
}
SettingsManager.defaultConfig = {
    debugMode = false,
    enableInGameSettingsMenu = true,
    enableContractValueOverrides = true,
    rewardFactor = 1.5,
    maxContractsPerFarm = 10,
    maxContractsPerType = 5,
    maxContractsOverall = 50,
    enableStrawFromHarvestMissions = true,
    enableSwathingForHarvestMissions = true,
    enableGrassFromMowingMissions = true,
    enableHayFromTedderMissions = true,
    enableStonePickingFromMissions = true,
    enableFieldworkToolFillItems = true,
    enableCollectingBalesFromMissions = false,
    enableCustomGrassFieldsForMissions = true,
    preferStrawHarvestMissions = true,
    enableHarvestContractNewCrops = true,
    enableHarvestContractPremiumCrops = true,
    enableHarvestContractRootCrops = true,
    enableHarvestContractSugarcane = true,
    enableHarvestContractCotton = true,
    customRewards = {},
    customMaxPerType = {},
}


-- Create a meta table to get basic Class-like behavior
local SettingsManager_mt = Class(SettingsManager)


---Creates the xml configuration manager object
---@return SettingsManager @The new object
function SettingsManager.new()
    local self = setmetatable({}, SettingsManager_mt)
    self.loadDebug = true

    -- configuration files and loading states
    self.loadComplete = false
    self.loadedConfig = {}

    -- xmlConfigFiles
    self.modSettingsConfigFile = "modSettings/ContractBoost.xml"
    self.savegameConfigFile = MOD_NAME..".xml"

    if self.loadDebug then Logging.info(MOD_NAME..":MANAGER initialized") end

    return self
end


--- Load the user's configuration file from either the savegame or modSettingsFile
function SettingsManager:restoreSettings()
    -- setup the xml schema
    self:initXmlSchema()

    if self.loadDebug then Logging.info(MOD_NAME..":LOAD :: read user configurations") end

    -- don't load it twice if the config is already loaded.
    if self.loadComplete and self.loadedConfig then
        if self.loadDebug then Logging.info(MOD_NAME..":LOAD :: exit early!") end
        return self.loadedConfig
    end

    -- determine the proper path for the user's settings file
    local modSettingsFile = self:getModSettingsXmlFilePath()
    local savegameSettingsFile = self.getSavegameXmlFilePath()

    -- if we're a client and the settings have already been loaded, don't load again.
    if not g_currentMission:getIsServer() then
        Logging.info(MOD_NAME .. ":LOAD isCLIENT, using server settings")
        return
    end

    -- pull the settings from memory if needed
    local settings = g_currentMission.contractBoostSettings
    if settings == nil or savegameSettingsFile == nil then
        Logging.warning(MOD_NAME .. ":LOAD :: Could not read ContractBoost settings from either g_currentMission or savegameSettingsFile")

        self:useDefaultConfig(settings)
        Logging.info(MOD_NAME..":LOAD :: DEFAULT configuration used")

    -- Default is to load from the savegameSettingsFile
    elseif savegameSettingsFile and fileExists(savegameSettingsFile) then
        self:importConfig(savegameSettingsFile, settings)
        Logging.info(MOD_NAME..":LOAD :: SAVEGAME configuration from: %s", savegameSettingsFile)

    -- If they loaded a previous version, they may have modSettings file
    elseif modSettingsFile and fileExists(modSettingsFile) then
        self:importConfig(modSettingsFile, settings)
        Logging.info(MOD_NAME..":LOAD :: MODSETTINGS configuration from: %s", modSettingsFile)

    end

    Logging.info(MOD_NAME..":LOAD :: Debug mode: %s", settings.debugMode and "true" or "false")
    Logging.info(MOD_NAME..':LOAD :: Loaded configuration:')
    SettingsManager.logBoostSettings(settings, 1)

    -- make sure we don't load it twice
    self.loadedConfig = settings
    self.loadComplete = true
    --g_currentMission.contractBoostSettings = settings  -- is this needed?
    Logging.info(MOD_NAME..':LOAD complete.')
end


--- Initiaze the XML file configuration
function SettingsManager:initXmlSchema()
    if self.loadDebug then Logging.info(MOD_NAME..":LOAD :: init xml schema") end

    self.xmlSchema = XMLSchema.new(XMLTAG)

    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.debugMode", "Turn debugMode on for additional log output", SettingsManager.defaultConfig.debugMode)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableInGameSettingsMenu", "enable or disable the in-game settings menu?", SettingsManager.defaultConfig.enableInGameSettingsMenu)

    self.xmlSchema:register(XMLValueType.FLOAT, XMLTAG..".settings.rewardFactor", "applies a multiplier to the base game rewardPer value", SettingsManager.defaultConfig.rewardFactor)
    self.xmlSchema:register(XMLValueType.INT, XMLTAG..".settings.maxContractsPerFarm", "how many contracts can be active at once", SettingsManager.defaultConfig.maxContractsPerFarm)
    self.xmlSchema:register(XMLValueType.INT, XMLTAG..".settings.maxContractsPerType", "how many contracts per contract type can be available", SettingsManager.defaultConfig.maxContractsPerType)
    self.xmlSchema:register(XMLValueType.INT, XMLTAG..".settings.maxContractsOverall", "how many contracts overall can be available", SettingsManager.defaultConfig.maxContractsOverall)

    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableContractValueOverrides", "enables overriding contract system default setting values", SettingsManager.defaultConfig.enableContractValueOverrides)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableStrawFromHarvestMissions", "should straw be collectible from during harvest missions?", SettingsManager.defaultConfig.enableStrawFromHarvestMissions)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableSwathingForHarvestMissions", "should you be able to use a Swather for harvest missions?", SettingsManager.defaultConfig.enableSwathingForHarvestMissions)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableGrassFromMowingMissions", "should grass be collectible from during mowing missions?", SettingsManager.defaultConfig.enableGrassFromMowingMissions)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableHayFromTedderMissions", "should hay be collectible from during tedder missions?", SettingsManager.defaultConfig.enableHayFromTedderMissions)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableStonePickingFromMissions", "should stones be collectible from during tilling & sowing missions?", SettingsManager.defaultConfig.enableStonePickingFromMissions)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableCollectingBalesFromMissions", "should you be able to collect bales from baling and baleWrapping contracts?", SettingsManager.defaultConfig.enableCollectingBalesFromMissions)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableFieldworkToolFillItems", "should borrowed equipment come with free fieldwork items to fill your tools", SettingsManager.defaultConfig.enableFieldworkToolFillItems)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableCustomGrassFieldsForMissions", "should custom or dynamic grass fields work for contracts?", SettingsManager.defaultConfig.enableCustomGrassFieldsForMissions)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.preferStrawHarvestMissions", "do you want to enable staw baling contracts (which may lower the number of harvest contracts)?", SettingsManager.defaultConfig.preferStrawHarvestMissions)

    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableHarvestContractNewCrops", "do you want contracts to harvest the new crops from FS25?", SettingsManager.defaultConfig.enableHarvestContractNewCrops)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableHarvestContractPremiumCrops", "do you want contracts to harvest the premium dlc crops?", SettingsManager.defaultConfig.enableHarvestContractPremiumCrops)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableHarvestContractRootCrops", "do you want contracts to harvest root crops?", SettingsManager.defaultConfig.enableHarvestContractRootCrops)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableHarvestContractSugarcane", "do you want contracts to harvest sugarcane ?", SettingsManager.defaultConfig.enableHarvestContractSugarcane)
    self.xmlSchema:register(XMLValueType.BOOL, XMLTAG..".settings.enableHarvestContractCotton", "do you want contracts to harvest cotton?", SettingsManager.defaultConfig.enableHarvestContractCotton)

    
    -- loop through the mission types to setup the customRewards
    for _, missionType in SettingsManager.missionTypes do
        self.xmlSchema:register(XMLValueType.INT, XMLTAG..".customRewards."..missionType, "custom rewards for "..missionType, nil)
    end

    -- loop through the mission types to setup the customMaxPerType
    for _, missionType in SettingsManager.missionTypes do
        self.xmlSchema:register(XMLValueType.INT, XMLTAG..".customMaxPerType."..missionType, "custom maxPerType for "..missionType, nil)
    end

    if self.loadDebug then Logging.info(MOD_NAME..":LOAD :: init xml complete") end
end


--- Initiaze the a specified xmlFilename as a config
---@param xmlFilename string
---@param settingsObject table
function SettingsManager:importConfig(xmlFilename, settingsObject)
    local xmlFile = XMLFile.load("xmlFile", xmlFilename, self.xmlSchema)

    if SettingsManager.loadDebug then
        Logging.info(MOD_NAME..":LOAD :: loaded file: %s", xmlFilename)
    end

    -- if self.loadDebug then
    --     print('-- ContractBoost:SettingsManager :: settingsObject')
    --     DebugUtil.printTableRecursively(settingsObject)
    -- end

    if xmlFile ~= 0 then
        settingsObject.debugMode = xmlFile:getValue(XMLTAG..".settings.debugMode", SettingsManager.defaultConfig.debugMode)
        settingsObject.enableInGameSettingsMenu = xmlFile:getValue(XMLTAG..".settings.enableInGameSettingsMenu", SettingsManager.defaultConfig.enableInGameSettingsMenu)

        settingsObject.enableContractValueOverrides = xmlFile:getValue(XMLTAG..".settings.enableContractValueOverrides", SettingsManager.defaultConfig.enableContractValueOverrides)
        settingsObject.rewardFactor = xmlFile:getValue(XMLTAG..".settings.rewardFactor", SettingsManager.defaultConfig.rewardFactor)
        settingsObject.maxContractsPerFarm = xmlFile:getValue(XMLTAG..".settings.maxContractsPerFarm", SettingsManager.defaultConfig.maxContractsPerFarm)
        settingsObject.maxContractsPerType = xmlFile:getValue(XMLTAG..".settings.maxContractsPerType", SettingsManager.defaultConfig.maxContractsPerType)
        settingsObject.maxContractsOverall = xmlFile:getValue(XMLTAG..".settings.maxContractsOverall", SettingsManager.defaultConfig.maxContractsOverall)

        settingsObject.enableStrawFromHarvestMissions = xmlFile:getValue(XMLTAG..".settings.enableStrawFromHarvestMissions", SettingsManager.defaultConfig.enableStrawFromHarvestMissions)
        settingsObject.enableSwathingForHarvestMissions = xmlFile:getValue(XMLTAG..".settings.enableSwathingForHarvestMissions", SettingsManager.defaultConfig.enableSwathingForHarvestMissions)
        settingsObject.enableGrassFromMowingMissions = xmlFile:getValue(XMLTAG..".settings.enableGrassFromMowingMissions", SettingsManager.defaultConfig.enableGrassFromMowingMissions)
        settingsObject.enableHayFromTedderMissions = xmlFile:getValue(XMLTAG..".settings.enableHayFromTedderMissions", SettingsManager.defaultConfig.enableHayFromTedderMissions)
        settingsObject.enableStonePickingFromMissions = xmlFile:getValue(XMLTAG..".settings.enableStonePickingFromMissions", SettingsManager.defaultConfig.enableStonePickingFromMissions)
        settingsObject.enableCollectingBalesFromMissions = xmlFile:getValue(XMLTAG..".settings.enableCollectingBalesFromMissions", SettingsManager.defaultConfig.enableCollectingBalesFromMissions)
        settingsObject.enableFieldworkToolFillItems = xmlFile:getValue(XMLTAG..".settings.enableFieldworkToolFillItems", SettingsManager.defaultConfig.enableFieldworkToolFillItems)
        settingsObject.enableCustomGrassFieldsForMissions = xmlFile:getValue(XMLTAG..".settings.enableCustomGrassFieldsForMissions", SettingsManager.defaultConfig.enableCustomGrassFieldsForMissions)
        settingsObject.preferStrawHarvestMissions = xmlFile:getValue(XMLTAG..".settings.preferStrawHarvestMissions", SettingsManager.defaultConfig.preferStrawHarvestMissions)
        
        settingsObject.enableHarvestContractNewCrops = xmlFile:getValue(XMLTAG..".settings.enableHarvestContractNewCrops", SettingsManager.defaultConfig.enableHarvestContractNewCrops)
        settingsObject.enableHarvestContractPremiumCrops = xmlFile:getValue(XMLTAG..".settings.enableHarvestContractPremiumCrops", SettingsManager.defaultConfig.enableHarvestContractPremiumCrops)
        settingsObject.enableHarvestContractRootCrops = xmlFile:getValue(XMLTAG..".settings.enableHarvestContractRootCrops", SettingsManager.defaultConfig.enableHarvestContractRootCrops)
        settingsObject.enableHarvestContractSugarcane = xmlFile:getValue(XMLTAG..".settings.enableHarvestContractSugarcane", SettingsManager.defaultConfig.enableHarvestContractSugarcane)
        settingsObject.enableHarvestContractCotton = xmlFile:getValue(XMLTAG..".settings.enableHarvestContractCotton", SettingsManager.defaultConfig.enableHarvestContractCotton)

        -- loop through the mission types to pull the customRewards
        settingsObject.customRewards = {}
        for _, missionType in SettingsManager.missionTypes do
            settingsObject.customRewards[missionType] = xmlFile:getValue(XMLTAG..".customRewards."..missionType, nil)
        end

        -- loop through the mission types to pull the customMaxPerType
        settingsObject.customMaxPerType = {}
        for _, missionType in SettingsManager.missionTypes do
            settingsObject.customMaxPerType[missionType] = xmlFile:getValue(XMLTAG..".customMaxPerType."..missionType, nil)
        end

        -- ensure that values are within limits for numerical values
        if settingsObject.rewardFactor < 0.1 or settingsObject.rewardFactor > 5.0 then
            Logging.info(MOD_NAME..':LOAD :: user configured rewardFactor (%s) outside of limits, reset to default.', settingsObject.rewardFactor)
            settingsObject.rewardFactor = SettingsManager.defaultConfig.rewardFactor
        end

        if settingsObject.maxContractsPerFarm < 1 or settingsObject.maxContractsPerFarm > 100 then
            Logging.info(MOD_NAME..':LOAD :: user configured maxContractsPerFarm (%s) outside of limits, reset to default.', settingsObject.maxContractsPerFarm)
            settingsObject.maxContractsPerFarm = SettingsManager.defaultConfig.maxContractsPerFarm
        end

        if settingsObject.maxContractsPerType < 1 or settingsObject.maxContractsPerType > 25 then
            Logging.info(MOD_NAME..':LOAD :: user configured maxContractsPerType (%s) outside of limits, reset to default.', settingsObject.maxContractsPerType)
            settingsObject.maxContractsPerType = SettingsManager.defaultConfig.maxContractsPerType
        end

        if settingsObject.maxContractsOverall < 1 or settingsObject.maxContractsOverall > 100 then
            Logging.info(MOD_NAME..':LOAD :: user configured maxContractsOverall (%d) outside of limits, reset to default.', settingsObject.maxContractsOverall)
            settingsObject.maxContractsOverall = SettingsManager.defaultConfig.maxContractsOverall
        end

        local missionTypesCalculatedPerItem = {
            baleMission = true,
            baleWrapMission = true,
            deadwoodMission = true,
            treeTransportMission = true,
            destructibleRockMission = true,
        }

        -- Custom rewards must match steps in the new UI settings
        for propName, value in settingsObject.customRewards do
            if value ~= nil and value % 50 ~= 0 and missionTypesCalculatedPerItem[propName] then
                -- Round to steps of 50
                settingsObject.customRewards[propName] = math.round(value / 50) * 50
                Logging.info(MOD_NAME..':LOAD :: Rounded property customRewards.%s from %d to %d (nearest 50)', propName, value, settingsObject.customRewards[propName])
            elseif value ~= nil and value % 100 ~= 0 and not missionTypesCalculatedPerItem[propName] then
                -- Round to steps of 100
                settingsObject.customRewards[propName] = math.round(value / 100) * 100
                Logging.info(MOD_NAME..':LOAD :: Rounded property customRewards.%s from %d to %d (nearest 100)', propName, value, settingsObject.customRewards[propName])
            end
        end
    end

    xmlFile:delete()

    
end

--- Initiaze the a specified xmlFilename as a config
---@param settingsObject table
function SettingsManager:useDefaultConfig(settingsObject)
    settingsObject.debugMode = SettingsManager.defaultConfig.debugMode
    settingsObject.enableInGameSettingsMenu = SettingsManager.defaultConfig.enableInGameSettingsMenu

    settingsObject.enableContractValueOverrides = SettingsManager.defaultConfig.enableContractValueOverrides
    settingsObject.rewardFactor = SettingsManager.defaultConfig.rewardFactor
    settingsObject.maxContractsPerFarm = SettingsManager.defaultConfig.maxContractsPerFarm
    settingsObject.maxContractsPerType = SettingsManager.defaultConfig.maxContractsPerType
    settingsObject.maxContractsOverall = SettingsManager.defaultConfig.maxContractsOverall

    settingsObject.enableStrawFromHarvestMissions = SettingsManager.defaultConfig.enableStrawFromHarvestMissions
    settingsObject.enableSwathingForHarvestMissions = SettingsManager.defaultConfig.enableSwathingForHarvestMissions
    settingsObject.enableGrassFromMowingMissions = SettingsManager.defaultConfig.enableGrassFromMowingMissions
    settingsObject.enableHayFromTedderMissions = SettingsManager.defaultConfig.enableHayFromTedderMissions
    settingsObject.enableStonePickingFromMissions = SettingsManager.defaultConfig.enableStonePickingFromMissions
    settingsObject.enableCollectingBalesFromMissions = SettingsManager.defaultConfig.enableCollectingBalesFromMissions
    settingsObject.enableFieldworkToolFillItems = SettingsManager.defaultConfig.enableFieldworkToolFillItems
    settingsObject.enableCustomGrassFieldsForMissions = SettingsManager.defaultConfig.enableCustomGrassFieldsForMissions
    settingsObject.preferStrawHarvestMissions = SettingsManager.defaultConfig.preferStrawHarvestMissions

    settingsObject.enableHarvestContractNewCrops = SettingsManager.defaultConfig.enableHarvestContractNewCrops
    settingsObject.enableHarvestContractPremiumCrops = SettingsManager.defaultConfig.enableHarvestContractPremiumCrops
    settingsObject.enableHarvestContractRootCrops = SettingsManager.defaultConfig.enableHarvestContractRootCrops
    settingsObject.enableHarvestContractSugarcane = SettingsManager.defaultConfig.enableHarvestContractSugarcane
    settingsObject.enableHarvestContractCotton = SettingsManager.defaultConfig.enableHarvestContractCotton

    settingsObject.customRewards = {}
    settingsObject.customMaxPerType = {}
end


---Writes the settings to our own XML file
function SettingsManager:saveSettings()
    local xmlPath = self:getSavegameXmlFilePath()
    if xmlPath == nil then
        Logging.warning(MOD_NAME..':SAVE :: Could not save current settings.') -- another warning has been logged before this
        return
    end

    local boostSettings = g_currentMission.contractBoostSettings

    -- Create an empty XML file in memory
    local xmlFileId = createXMLFile("ContractBoost", xmlPath, XMLTAG)

    setXMLBool(xmlFileId, XMLTAG..".settings.debugMode", boostSettings.debugMode)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableInGameSettingsMenu", boostSettings.enableInGameSettingsMenu)
    
    setXMLBool(xmlFileId, XMLTAG..".settings.enableContractValueOverrides", boostSettings.enableContractValueOverrides)
    setXMLFloat(xmlFileId, XMLTAG..".settings.rewardFactor", boostSettings.rewardFactor)
    setXMLInt(xmlFileId, XMLTAG..".settings.maxContractsPerFarm", boostSettings.maxContractsPerFarm)
    setXMLInt(xmlFileId, XMLTAG..".settings.maxContractsPerType", boostSettings.maxContractsPerType)
    setXMLInt(xmlFileId, XMLTAG..".settings.maxContractsOverall", boostSettings.maxContractsOverall)
    
    setXMLBool(xmlFileId, XMLTAG..".settings.enableStrawFromHarvestMissions", boostSettings.enableStrawFromHarvestMissions)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableSwathingForHarvestMissions", boostSettings.enableSwathingForHarvestMissions)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableGrassFromMowingMissions", boostSettings.enableGrassFromMowingMissions)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableHayFromTedderMissions", boostSettings.enableHayFromTedderMissions)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableStonePickingFromMissions", boostSettings.enableStonePickingFromMissions)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableCollectingBalesFromMissions", boostSettings.enableCollectingBalesFromMissions)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableFieldworkToolFillItems", boostSettings.enableFieldworkToolFillItems)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableCustomGrassFieldsForMissions", boostSettings.enableCustomGrassFieldsForMissions)
    setXMLBool(xmlFileId, XMLTAG..".settings.preferStrawHarvestMissions", boostSettings.preferStrawHarvestMissions)

    setXMLBool(xmlFileId, XMLTAG..".settings.enableHarvestContractNewCrops", boostSettings.enableHarvestContractNewCrops)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableHarvestContractPremiumCrops", boostSettings.enableHarvestContractPremiumCrops)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableHarvestContractRootCrops", boostSettings.enableHarvestContractRootCrops)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableHarvestContractSugarcane", boostSettings.enableHarvestContractSugarcane)
    setXMLBool(xmlFileId, XMLTAG..".settings.enableHarvestContractCotton", boostSettings.enableHarvestContractCotton)

    -- loop through the mission types to pull the customRewards
    for _, missionType in SettingsManager.missionTypes do
        if boostSettings.customRewards[missionType] ~= nil then
            setXMLInt(xmlFileId, XMLTAG..".customRewards."..missionType, boostSettings.customRewards[missionType])
        end
    end

    -- loop through the mission types to pull the customMaxPerType
    for _, missionType in SettingsManager.missionTypes do
        if boostSettings.customMaxPerType[missionType] ~= nil then
            setXMLInt(xmlFileId, XMLTAG..".customMaxPerType."..missionType, boostSettings.customMaxPerType[missionType])
        end
    end

    -- Write the XML file to disk
    saveXMLFile(xmlFileId)

    Logging.info(MOD_NAME..':SAVE :: saved config to savegame: %s', xmlPath)
end


---Builds a path to the XML file.
---@return string|nil @The path to the XML file
function SettingsManager:getModSettingsXmlFilePath()
    return Utils.getFilename(self.modSettingsConfigFile, getUserProfileAppPath())
end


---Builds a path to the XML file.
---@return string|nil @The path to the XML file
function SettingsManager.getSavegameXmlFilePath()
    if g_currentMission and g_currentMission.missionInfo then
        local savegameDirectory = g_currentMission.missionInfo.savegameDirectory
        if savegameDirectory ~= nil then
            return ("%s/%s.xml"):format(savegameDirectory, MOD_NAME)
        -- else: Save game directory is nil if this is a brand new save
        end
    else
        Logging.warning(MOD_NAME .. ":LOAD :: Could not get path to Contract Boost xml settings file since g_currentMission.missionInfo is nil.")
    end
    return nil
end


---Sorts and prints out the current settings to the log.
function SettingsManager.logBoostSettings(t, indent)
    -- sort the table
    local tkeys = {}
    for k in pairs(t) do table.insert(tkeys, k) end
    table.sort(tkeys)

    -- print the table out
    local v = ""
    local key = ""
    for _, k in ipairs(tkeys) do
        v = t[k]
        key = string.rep("   ", indent) .. tostring(k)
        if type(v) == "table" then
            Logging.info(key .. ": ")
            SettingsManager.logBoostSettings(v, indent + 1)
        else
            Logging.info(key .. " :: " .. tostring(v))
        end
    end
end