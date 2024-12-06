-- ContractBoost:core
-- @author GMNGjoy
-- @copyright 11/15/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal

ContractBoost = {}
ContractBoost.config = {}
ContractBoost.debug = false

function ContractBoost:init()
    if ContractBoost.debug then print('-- ContractBoost:ContractBoost :: init.') end

    -- load the config from xml
    source(g_currentModDirectory.."scripts/XmlConfigLoader.lua")
    ContractBoost.config = XmlConfigLoader.init()
    ContractBoost.debug = ContractBoost.config.debugMode

    source(g_currentModDirectory.."scripts/lib/UIHelper.lua")
    source(g_currentModDirectory.."scripts/SettingsUI.lua")
    ContractBoost.uiSettings = SettingsUI.new()
    ContractBoost.uiSettings:injectUiSettings(ContractBoost.config)

    source(g_currentModDirectory.."scripts/MissionBalance.lua")
    source(g_currentModDirectory.."scripts/MissionBorrow.lua")
    source(g_currentModDirectory.."scripts/MissionTools.lua")

    -- setup function overrides
    g_missionManager.loadMapData = Utils.appendedFunction(MissionManager.loadMapData, ContractBoost.loadMapData)
    MissionManager.getIsMissionWorkAllowed = Utils.overwrittenFunction(MissionManager.getIsMissionWorkAllowed, MissionTools.getIsMissionWorkAllowed)

    if ContractBoost.config.enableFieldworkToolFillItems then
        AbstractMission.onSpawnedVehicle = Utils.overwrittenFunction(AbstractMission.onSpawnedVehicle, MissionBorrow.onSpawnedVehicle)
    end

    printf('-- ContractBoost :: loaded. debug: %s', ContractBoost.debug and "on" or "off")
end

function ContractBoost:loadMapData()
    if ContractBoost.debug then print('-- ContractBoost :: loadMapData') end

    -- MissionBalance: on map load apply new mission settings
    if ContractBoost.config.enableContractValueOverrides then
        MissionBalance:initMissionSettings()
        MissionBalance:scaleMissionReward()
    end

    -- MissionBorrow: on map load add items for fieldwork tools
    if ContractBoost.config.enableFieldworkToolFillItems then
        MissionBorrow:addFillItemsToMissionTools()
    end

    -- MissionTools: setup to allow more tools based on settings.
    MissionTools:setupAdditionalAllowedVehicles()

    if ContractBoost.debug then print('-- ContractBoost :: loadMapData complete.') end
end

ContractBoost:init();