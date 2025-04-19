-- ContractBoost:MissionTools
-- @author GMNGjoy
-- @copyright 11/15/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal

WorkAreaTypes = {
    BALER = 1,
    COMBINECHOPPER = 2,
    COMBINESWATH = 3,
    CULTIVATOR = 4,
    CUTTER = 5,
    HAULMDROP = 6,
    FORAGEWAGON = 7,
    FRUITPREPARER = 8,
    MULCHER = 9,
    MOWER = 10,
    PLOW = 11,
    PLOWSHARE = 12,
    RIDGEFORMER = 13,
    RIDGEMARKER = 14,
    ROLLER = 15,
    SALTSPREADER = 16,
    SOWINGMACHINE = 17,
    SPRAYER = 18,
    STONEPICKER = 19,
    STUMPCUTTER = 20,
    TEDDER = 21,
    WEEDER = 22,
    WINDROWER = 23,
    DEFAULT = 24,
    AUXILIARY = 25,
}

WorkAreaNames = {}
for type, id in pairs(WorkAreaTypes) do
    WorkAreaNames[id] = type
end

MissionTools = {}
MissionTools.additionalAllowedVehicles = {}

-- Determine which additional allowed vehicles will be allowed based on user settings.
function MissionTools:setupAdditionalAllowedVehicles()

    if g_currentMission.contractBoostSettings.enableStrawFromHarvestMissions then
        MissionTools.additionalAllowedVehicles.harvestMission = {
            [WorkAreaTypes.FORAGEWAGON] = true,
            [WorkAreaTypes.BALER] = true,
            [WorkAreaTypes.WINDROWER] = true,
            [WorkAreaTypes.WEEDER] = true
        }
    end

    if g_currentMission.contractBoostSettings.enableSwathingForHarvestMissions then
        if not MissionTools.additionalAllowedVehicles.harvestMission then
            MissionTools.additionalAllowedVehicles.harvestMission = {}
        end
        MissionTools.additionalAllowedVehicles.harvestMission[WorkAreaTypes.MOWER] = true
    end

    if g_currentMission.contractBoostSettings.enableGrassFromMowingMissions then
        MissionTools.additionalAllowedVehicles.mowMission = {
            [WorkAreaTypes.COMBINECHOPPER] = true,
            [WorkAreaTypes.CUTTER] = true,
            [WorkAreaTypes.FORAGEWAGON] = true,
            [WorkAreaTypes.BALER] = true,
            [WorkAreaTypes.WINDROWER] = true,
            [WorkAreaTypes.TEDDER] = true
        }
    end

    if g_currentMission.contractBoostSettings.enableStonePickingFromMissions then
        MissionTools.additionalAllowedVehicles.plowMission = {
            [WorkAreaTypes.STONEPICKER] = true
        }
        MissionTools.additionalAllowedVehicles.cultivateMission = {
            [WorkAreaTypes.STONEPICKER] = true
        }
        MissionTools.additionalAllowedVehicles.sowMission = {
            [WorkAreaTypes.STONEPICKER] = true
        }
    end

    if g_currentMission.contractBoostSettings.enableHayFromTedderMissions then
        MissionTools.additionalAllowedVehicles.tedderMission = {
            [WorkAreaTypes.FORAGEWAGON] = true,
            [WorkAreaTypes.BALER] = true,
            [WorkAreaTypes.WINDROWER] = true
        }
    end

    -- allow cultivating when seeding in case you plant the wrong crop
    if not MissionTools.additionalAllowedVehicles.sowMission then
        MissionTools.additionalAllowedVehicles.sowMission = {}
    end
    MissionTools.additionalAllowedVehicles.sowMission[WorkAreaTypes.CULTIVATOR] = true

    -- allow windrowing for baling missions
    if not MissionTools.additionalAllowedVehicles.baleMission then
        MissionTools.additionalAllowedVehicles.baleMission = {}
    end
    MissionTools.additionalAllowedVehicles.baleMission[WorkAreaTypes.WINDROWER] = true

    -- baleMission = {},
    -- baleWrapMission = {},
    -- hoeMission = {},
    -- weedMission = {},
    -- herbicideMission ={},
    -- fertilizeMission ={},
    -- tedderMission = {},
    -- stonePickMission = {},
    -- deadwoodMission = {},
    -- treeTransportMission = {},
    -- destructibleRockMission = {},
end

function MissionTools:getMissionByFarmlandId(curentFarmlandId)
	for _, mission in g_missionManager.missions do
		if mission.activeMissionId and mission.field and mission.field.farmland.id == curentFarmlandId then
		    return mission
		end
	end
	return nil
end

-- replace the getIsMissionWorkAllowed with our own function that also checks the additional tools
function MissionTools:getIsMissionWorkAllowed(superFunc, farmId, x, z, workAreaType)
    local farmlandId = g_farmlandManager:getFarmlandIdAtWorldPosition(x, z)
    local mission = MissionTools:getMissionByFarmlandId(farmlandId)
    if ContractBoost.debug and mission ~= nil then 
        printf(MOD_NAME..':MissionTools :: getMissionByFarmlandId %s: %s | farmId: %s', mission.id, mission.title, mission.farmId)
    end

    if mission ~= nil and mission.type ~= nil and mission.farmId == farmId then
        local missionType = mission.type.name

        -- if ContractBoost.debug then 
        --     printf(MOD_NAME..':MissionTools :: missionType: %s | workAreaType: %s', missionType, WorkAreaNames[workAreaType])
        -- end

        local missionWorkAreaTypes = mission.workAreaTypes or {}
        local additionalWorkAreaTypes = MissionTools.additionalAllowedVehicles[missionType] or {}

        if (
            workAreaType == nil
            or missionWorkAreaTypes[workAreaType]
            or additionalWorkAreaTypes[workAreaType]
        ) then
            return true
        end
    end

    return false
end

-- replace the BaleMission.addBale function with our own function that updates the owner of the bale to the player.
function MissionTools.addBale(self, superFunc, bale)
    -- call the overwritten function
    superFunc(self, bale)

    -- exit if not enabled
    if not g_currentMission.contractBoostSettings.enableCollectingBalesFromMissions then
        return
    end

    -- one last check that we have a bale, and change the owner.
    if self.isServer then
        if bale ~= nil then
            if ContractBoost.debug then Logging.info(MOD_NAME..':TOOLS :: BaleMission changeOwner %s: %s', bale.uniqueId, self.farmId) end
            bale:setOwnerFarmId(self.farmId)
        end
    end
end

-- replace the BaleMission.finishField function with our own function that doesn't remove the bales.
function MissionTools.finishBaleField(self, superFunc)
    -- call the original method if collecting bales is not enabled
    if not g_currentMission.contractBoostSettings.enableCollectingBalesFromMissions then
        superFunc(self)
        return
    end

    -- otherwise call the parent finishField fn bypassing the bale removal
    BaleMission:superClass().finishField(self)
end

-- replace the BaleWrapMission.getIsPrepared function with our own function that updates the owner of the spawned bales to the player.
function MissionTools.getIsPrepared(self, superFunc)
    -- call the original method if collecting bales is not enabled
    if not g_currentMission.contractBoostSettings.enableCollectingBalesFromMissions then
        return superFunc(self)
    end

    -- if the field isn't ready yet, just return the same value.
    if not superFunc(self) then
        return false
    end

    -- ensure that we're in the right setting, and reset the owner to the player
    if self.isServer then
		for _, bale in ipairs(self.bales) do
            if ContractBoost.debug then Logging.info(MOD_NAME..':TOOLS :: BaleWrapMission changeOwner %s: %s', bale.uniqueId, self.farmId) end
			bale:setOwnerFarmId(self.farmId)
		end
	end

    return true
end

-- replace the BaleWrapMission.finishField function with our own function that doesn't remove the bales.
function MissionTools.finishBaleWrapField(self, superFunc)
    -- call the original method if collecting bales is not enabled
    if not g_currentMission.contractBoostSettings.enableCollectingBalesFromMissions then
        superFunc(self)
        return
    end

    -- otherwise call the parent finishField fn bypassing the bale removal
    BaleWrapMission:superClass().finishField(self)
end

-- replace the isAvailableForField.finishField function with our own function that doesn't remove the bales.
function MissionTools.isAvailableForFieldBaleMission(self, superFunc, notNil)
    -- call the original method if collecting bales is not enabled
    if not g_currentMission.contractBoostSettings.preferStrawHarvestMissions then
        return superFunc(self, notNil)
    end

    local isAvailableForField = superFunc(self, notNil)
    if not isAvailableForField then
        return false
    end

    -- look up the field state, the windrowFillType and the currentGrowthName for the crop in question
    local fieldState = self:getFieldState()
    local windrowFillType = g_fruitTypeManager:getWindrowFillTypeIndexByFruitTypeIndex(fieldState.fruitTypeIndex)
    local fieldFruitType = g_fruitTypeManager:getFruitTypeByIndex(fieldState.fruitTypeIndex)
    local currentGrowthName = fieldFruitType.growthStateToName[fieldState.growthState]
    local cropHarvestedState = fieldFruitType.nameToGrowthState.HARVESTED

    -- prevent baling missions on cereal crop fields in either harvestReady or greenBig states.
    if windrowFillType == FillType.STRAW and fieldState.growthState ~= cropHarvestedState then
        if ContractBoost.debug then
            Logging.info(MOD_NAME..':TOOLS :: preferStrawHarvestMissions preventing bale mission on farmland: %s | crop: %s | state: %s', self.farmland.name, fieldFruitType.name, currentGrowthName)
        end
        return false
    end
    return isAvailableForField
end
