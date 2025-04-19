--- SettingsUI
-- @author Timmeey86, GMNGjoy
-- @copyright 12/16/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal
---This class is responsible for adding UI settings and mapping them to the existing settings variables
---@class SettingsUI
---@field sectionTitle table @The UI control which displays the section title
---@field controls table @A list of UI controls
---@field loadedConfig table @A reference to the loaded configuration object
---@field debugMode boolean @Determined if the component should emit data to the log
---@field enableContractValueOverrides boolean @A UI control
---@field rewardFactor number @A UI control
---@field maxContractsPerFarm number @A UI control
---@field maxContractsPerType number @A UI control
---@field maxContractsOverall number @A UI control
---@field enableStrawFromHarvestMissions boolean @A UI control
---@field enableSwathingForHarvestMissions boolean @A UI control
---@field enableGrassFromMowingMissions boolean @A UI control
---@field enableStonePickingFromMissions boolean @A UI control
---@field enableFieldworkToolFillItems boolean @A UI control
---@field enableCustomGrassFieldsForMissions boolean @A UI control
---@field preferStrawHarvestMissions boolean @A UI control
---@field enableHarvestContractNewCrops boolean @A UI control
---@field enableHarvestContractPremiumCrops boolean @A UI control
---@field enableHarvestContractRootCrops boolean @A UI control
---@field enableHarvestContractSugarcane boolean @A UI control
---@field enableHarvestContractCotton boolean @A UI control
---@field baleMissionReward number @A UI control
---@field baleWrapMissionReward number @A UI control
---@field plowMissionReward number @A UI control
---@field cultivateMissionReward number @A UI control
---@field sowMissionReward number @A UI control
---@field harvestMissionReward number @A UI control
---@field hoeMissionReward number @A UI control
---@field weedMissionReward number @A UI control
---@field herbicideMissionReward number @A UI control
---@field fertilizeMissionReward number @A UI control
---@field mowMissionReward number @A UI control
---@field tedderMissionReward number @A UI control
---@field stonePickMissionReward number @A UI control
---@field deadwoodMissionReward number @A UI control
---@field treeTransportMissionReward number @A UI control
---@field destructibleRockMissionReward number @A UI control
---@field baleMissionMaxPerType number @A UI control
---@field baleWrapMissionMaxPerType number @A UI control
---@field plowMissionMaxPerType number @A UI control
---@field cultivateMissionMaxPerType number @A UI control
---@field sowMissionMaxPerType number @A UI control
---@field harvestMissionMaxPerType number @A UI control
---@field hoeMissionMaxPerType number @A UI control
---@field weedMissionMaxPerType number @A UI control
---@field herbicideMissionMaxPerType number @A UI control
---@field fertilizeMissionMaxPerType number @A UI control
---@field mowMissionMaxPerType number @A UI control
---@field tedderMissionMaxPerType number @A UI control
---@field stonePickMissionMaxPerType number @A UI control
---@field deadwoodMissionMaxPerType number @A UI control
---@field treeTransportMissionMaxPerType number @A UI control
---@field destructibleRockMissionMaxPerType number @A UI control

SettingsUI = {}

-- Create a meta table to get basic Class-like behavior
local SettingsUI_mt = Class(SettingsUI)

---Creates the settings UI object
---@return SettingsUI @The new object
function SettingsUI.new()
    local self = setmetatable({}, SettingsUI_mt)

    self.controls = {}
    self.loadedConfig = nil
    self.isInitialized = false

    return self
end

---Injects the UI controls into the general settings menu
---@param loadedConfig table @The loaded config
function SettingsUI:injectUiSettings(loadedConfig)
    if g_dedicatedServer then
        return
    end

    -- Remember the settings object
    self.loadedConfig = loadedConfig

    if self.isInitialized then
        return
    end
    self.isInitialized = true

    -- Get a reference to the base game general settings page
    local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings

    -- Define the UI controls. For bool values, supply just the name, for ranges, supply min, max and step, and for choices, supply a values table
    -- For every name, a <prefix>_<name>_long and _short text must exist in the l10n files
    -- The _short text will be the title of the setting, the _long" text will be its tool tip
    -- For each control, a on_<name>_changed callback will be called on change
    local controlProperties = {
        { name = "enableContractValueOverrides", autoBind = true },
        { name = "rewardFactor", min = 0.5, max = 5.0, step = 0.1, autoBind = true },
        { name = "maxContractsPerFarm", values = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100 }, autoBind = true },
        { name = "maxContractsPerType", min = 1, max = 25, step = 1, autoBind = true },
        { name = "maxContractsOverall", values = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100 }, autoBind = true },
        { name = "enableStrawFromHarvestMissions", autoBind = true },
        { name = "enableSwathingForHarvestMissions", autoBind = true },
        { name = "enableGrassFromMowingMissions", autoBind = true },
        { name = "enableHayFromTedderMissions", autoBind = true },
        { name = "enableStonePickingFromMissions", autoBind = true },
        { name = "enableCollectingBalesFromMissions", autoBind = true },
        { name = "enableFieldworkToolFillItems", autoBind = true },
        { name = "enableCustomGrassFieldsForMissions", autoBind = true },
        { name = "preferStrawHarvestMissions", autoBind = true },
        { name = "enableHarvestContractNewCrops", autoBind = true },
        { name = "enableHarvestContractPremiumCrops", autoBind = true },
        { name = "enableHarvestContractRootCrops", autoBind = true },
        { name = "enableHarvestContractSugarcane", autoBind = true },
        { name = "enableHarvestContractCotton", autoBind = true },
    }

    -- Dynamically add the rest since they're all the same
    local missionTypes = {
        "baleMission", "baleWrapMission", "plowMission", "cultivateMission", "sowMission", "harvestMission", "hoeMission", "weedMission",
        "herbicideMission", "fertilizeMission", "mowMission", "tedderMission", "stonePickMission",
        "deadwoodMission", "treeTransportMission", "destructibleRockMission"
    }

    local missionTypesCalculatedPerItem = {
        baleWrapMission = true,
        deadwoodMission = true,
        treeTransportMission = true,
        destructibleRockMission = true,
    }

    -- Add in the customRewards types
    for _, prop in missionTypes do
        if missionTypesCalculatedPerItem[prop] then 
            table.insert(controlProperties, {
                name = prop .. "Reward",
                nillable = true,
                min = 0,
                max = 1000,
                step = 50,
                autoBind = true,
                subTable = "customRewards",
                propName = prop
            })
        else 
            table.insert(controlProperties, {
                name = prop .. "Reward",
                nillable = true,
                min = 0,
                max = 5000,
                step = 100,
                autoBind = true,
                subTable = "customRewards",
                propName = prop
            })
        end
    end

    -- Add in the customMaxPerType
    for _, prop in missionTypes do
        table.insert(controlProperties, {
            name = prop .. "MaxPerType",
            nillable = true,
            -- values = { '-', 0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50 },
            min = 0,
            max = 50,
            step = 1,
            autoBind = true,
            subTable = "customMaxPerType",
            propName = prop
        })
    end

    UIHelper.createControlsDynamically(settingsPage, "contract_boosted", self, controlProperties, "cb_")
    UIHelper.setupAutoBindControls(self, self.loadedConfig, SettingsUI.onSettingsChange)

    -- Apply initial values
    self:updateUiElements()

    -- Update any additional settings whenever the frame gets opened
    InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameOpen, function()
        self:updateUiElements(true) -- We can skip autobind controls here since they are already registered to onFrameOpen
    end)
end

function SettingsUI:onSettingsChange(control)
    self:updateUiElements()

    -- Grab the setting and new value from the UI element
    local setting = control.elements[1]
    local subTable = setting.parent.subTable or nil
    -- local newValue = setting.texts[setting.state]

    Logging.info(MOD_NAME .. ':SETTINGSUI %s%s', control.subTable and control.subTabe.."." or "", control.name)

    -- publish the settings change to the object, which publishes to the server.
    g_currentMission.contractBoostSettings:onSettingsChange(control.name, subTable)
end

---Updates the UI elements to reflect the current settings
---@param skipAutoBindControls boolean|nil @True if controls with the autoBind properties shall not be newly populated
function SettingsUI:updateUiElements(skipAutoBindControls)

    if not skipAutoBindControls then
        -- Note: This method is created dynamically by UIHelper.setupAutoBindControls
        self.populateAutoBindControls()
    end

    -- Disable settings if required
    local contractValueOverrideRewards = {
        self.rewardFactor, self.maxContractsPerFarm, self.maxContractsPerType, self.maxContractsOverall,
        self.baleMissionReward, self.baleWrapMissionReward, self.plowMissionReward, self.cultivateMissionReward,
        self.sowMissionReward, self.harvestMissionReward, self.hoeMissionReward, self.weedMissionReward, 
        self.herbicideMissionReward, self.fertilizeMissionReward, self.mowMissionReward, self.tedderMissionReward,
        self.stonePickMissionReward, self.deadwoodMissionReward, self.treeTransportMissionReward, self.destructibleRockMissionReward
    }

    for _, control in ipairs(contractValueOverrideRewards) do
        control:setDisabled(not self.loadedConfig.enableContractValueOverrides)
    end

    local isAdmin = g_currentMission:getIsServer() or g_currentMission.isMasterUser
	for _, control in ipairs(self.controls) do
        if not control.disabled then
		    control:setDisabled(not isAdmin)
        end
	end

    -- Update the focus manager
    local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings
    settingsPage.generalSettingsLayout:invalidateLayout()
end