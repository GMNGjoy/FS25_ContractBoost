-- ContractBoost:core
-- @author GMNGjoy
-- @copyright 12/16/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal

ContractBoost = {}
ContractBoost.listeners = {}
ContractBoost.debug = false
ContractBoost.modDirectory = g_currentModDirectory or ""
MOD_NAME = g_currentModName or "unknown"

---Initializes Contract Boost!
function ContractBoost:init()
    -- Load the config from xml
    ContractBoost.settings = SettingsManager.new()
    ContractBoost.settings:restoreSettings()
    ContractBoost.debug = g_currentMission.contractBoostSettings.debugMode

    -- print('---- ContractBoost:SettingsManager :: g_currentMission.contractBoostSettings')
    -- DebugUtil.printTableRecursively(g_currentMission.contractBoostSettings)

    Logging.info(MOD_NAME..' :: LOADED. debug: %s', ContractBoost.debug and "on" or "off")

    -- Setup the UIHelper & settings
    if g_currentMission.contractBoostSettings.enableInGameSettingsMenu then
        ContractBoost.uiSettings = SettingsUI.new()
        ContractBoost.uiSettings:injectUiSettings(g_currentMission.contractBoostSettings)
    end

    ContractBoost.initializeListeners()

    Logging.info(MOD_NAME..' :: INIT complete')
end


---Activates individual settings across the mod.
function ContractBoost:syncSettings()
    if ContractBoost.debug then Logging.info(MOD_NAME..' :: syncSettings') end

    -- MissionBalance: on map load apply new mission settings
    if g_currentMission.contractBoostSettings.enableContractValueOverrides then
        MissionBalance:setMissionSettings()
        MissionBalance:scaleMissionReward()
    end

    -- apply the max per type settings to remove any overflow based on new settings.
    -- MissionBalance:applyMaxPerType()

    -- MissionBorrow: on map load add items for fieldwork tools
    if g_currentMission.contractBoostSettings.enableFieldworkToolFillItems then
        MissionBorrow:addFillItemsToMissionTools()
    else
        MissionBorrow:removeFillItemsToMissionTools()
    end

    -- MissionTools: setup to allow more tools based on settings.
    MissionTools:setupAdditionalAllowedVehicles()

    -- Update skip harvest fruit types when settings change
    MissionFields:setupSkipHarvestFruitTypes()

    if ContractBoost.debug then Logging.info(MOD_NAME..' :: syncSettings complete.') end
end


---Initializes all the listeners that will be used to integrate the settings with gameplay
function ContractBoost.initializeListeners()

    -- Setup function overrides
    MissionManager.loadMapData = Utils.appendedFunction(MissionManager.loadMapData, ContractBoost.syncSettings)
    MissionManager.getIsMissionWorkAllowed = Utils.overwrittenFunction(MissionManager.getIsMissionWorkAllowed, MissionTools.getIsMissionWorkAllowed)

    -- Enable extra fieldwork fill items to be added to contract items
    AbstractMission.onSpawnedVehicle = Utils.overwrittenFunction(AbstractMission.onSpawnedVehicle, MissionBorrow.onSpawnedVehicle)

    -- Enable collecting of bales from baling contracts.
    BaleMission.addBale = Utils.overwrittenFunction(BaleMission.addBale, MissionTools.addBale)
    BaleMission.finishField = Utils.overwrittenFunction(BaleMission.finishField, MissionTools.finishBaleField)
    BaleMission.isAvailableForField = Utils.overwrittenFunction(BaleMission.isAvailableForField, MissionTools.isAvailableForFieldBaleMission)

    -- Enable collecting of wrapped bales from bale wrapping contracts.
    BaleWrapMission.getIsPrepared = Utils.overwrittenFunction(BaleWrapMission.getIsPrepared, MissionTools.getIsPrepared)
    BaleWrapMission.finishField = Utils.overwrittenFunction(BaleWrapMission.finishField, MissionTools.finishBaleWrapField)

    -- Make sure to show the details when someone looks at a mission
    AbstractMission.getDetails = Utils.overwrittenFunction(AbstractMission.getDetails, MissionBalance.getDetails)

    -- Allow users to disable certain harvest missions
    HarvestMission.isAvailableForField = Utils.overwrittenFunction(HarvestMission.isAvailableForField, MissionFields.isHarvestAvailableForField)

    -- once the player is loaded, parse through the generated missions
    if g_currentMission:getIsServer() then
        Player.onStartMission = Utils.appendedFunction(Player.onStartMission, function(...)
            MissionFields:scanFieldsOnMissionStart()
            MissionBalance:applyMaxPerType()
        end)
    end

    -- add a console command to toggle debug mode.
    addConsoleCommand("cbDebugToggle", "Toggles the debug mode within the Contract Boost mod", "consoleCommandToggleDebugMode", ContractBoost)
end


function ContractBoost.consoleCommandToggleDebugMode()
    g_currentMission.contractBoostSettings.debugMode = not g_currentMission.contractBoostSettings.debugMode
    ContractBoost.debug = g_currentMission.contractBoostSettings.debugMode
    Logging.info(MOD_NAME..' :: debugMode set %s', g_currentMission.contractBoostSettings.debugMode and "On" or "Off")
end

---Creates a settings object which can be accessed from the UI and the rest of the code
---@param   mission     table   @The object which is later available as g_currentMission
local function createModSettings(mission)
    -- Register the settings object globally so we can access it from the event class and others later
    mission.contractBoostSettings = Settings.new()
    addModEventListener(mission.contractBoostSettings)
end
Mission00.load = Utils.prependedFunction(Mission00.load, createModSettings)


---Destroys the settings object when it is no longer needed.
local function destroyModSettings()
    if g_currentMission ~= nil and g_currentMission.contractBoostSettings ~= nil then
        removeModEventListener(g_currentMission.contractBoostSettings)
        g_currentMission.contractBoostSettings = nil
    end
end
FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, destroyModSettings)


---Initialize ContractBoost when the map has finished loading
BaseMission.loadMapFinished = Utils.prependedFunction(BaseMission.loadMapFinished, function(...)
    ContractBoost:init()
end)


---Save the config when the savegame is being saved
ItemSystem.save = Utils.prependedFunction(ItemSystem.save,  function(...)
    ContractBoost.settings:saveSettings()
    MissionBalance:applyMaxPerType()
end)