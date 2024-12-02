-- ContractBoost:MissionBalance
-- @author GMNGjoy
-- @copyright 11/15/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal

MissionBalance = {}

--- Initialize the mission setting overrides based on user configuration
function MissionBalance:initMissionSettings()
    MissionManager.MAX_MISSIONS = ContractBoost.config.maxContractsOverall
    MissionManager.MAX_MISSIONS_PER_FARM = ContractBoost.config.maxContractsPerFarm
    MissionManager.MISSION_GENERATION_INTERVAL = 180000 --360000

    if ContractBoost.debug then print('-- ContractBoost:MissionBalance :: settings updated.') end
end

--- Scale the mission rewards based on user configuration
function MissionBalance:scaleMissionReward()
    if ContractBoost.debug then print('-- ContractBoost:MissionBalance :: scaleMissionReward') end

    local rewardFactor = ContractBoost.config.rewardFactor
    printf('---- ContractBoost:MissionBalance :: rewardFactor:%s', rewardFactor)

    if #g_missionManager.missionTypes ~= 0 then
        for _, missionType in ipairs(g_missionManager.missionTypes) do
            
            local typeName = missionType.name
            local prevValue = nil
            local newValue = nil

            
            if ContractBoost.debug then
                printf('---- ContractBoost:MissionBalance :: %s data', typeName)
                DebugUtil.printTableRecursively(missionType.data)
            end

            -- don't process the contract type if there are no instances
            if typeName == "baleWrapMission" and rawget(missionType.data, "rewardPerBale") ~= nil then
                prevValue = missionType.data.rewardPerBale
                newValue = ContractBoost.config.customRewards[typeName] or missionType.data.rewardPerBale * rewardFactor
                missionType.data.rewardPerBale = newValue
            elseif (typeName == "deadwoodMission" or typeName == "treeTransportMission") and rawget(missionType.data, "rewardPerTree") ~= nil then
                prevValue = missionType.data.rewardPerTree
                newValue = ContractBoost.config.customRewards[typeName] or missionType.data.rewardPerTree * rewardFactor
                missionType.data.rewardPerTree = newValue
            elseif typeName == "destructibleRockMission" and rawget(missionType.data, "rewardPerRock") ~= nil  then
                prevValue = missionType.data.rewardPerRock
                newValue = ContractBoost.config.customRewards[typeName] or missionType.data.rewardPerRock * rewardFactor
                missionType.data.rewardPerRock = newValue
            elseif rawget(missionType.data, "rewardPerHa") ~= nil then
                prevValue = missionType.data.rewardPerHa
                newValue = ContractBoost.config.customRewards[typeName] or missionType.data.rewardPerHa * rewardFactor
                missionType.data.rewardPerHa = newValue
            end

            -- update the maximum number of each type to it's custom value if it exists else use the default
            missionType.data.maxNumInstances = math.min(ContractBoost.config.customMaxPerType[typeName] or ContractBoost.config.maxContractsPerType, 20)

            if ContractBoost.debug then 
                if newValue == prevValue and newValue == nil then
                    printf('---- ContractBoost:MissionBalance :: Mission %s: %s | skipped, not founnd on map', missionType.typeId, missionType.name)
                else
                    printf('---- ContractBoost:MissionBalance :: Mission %s: %s | updated %s => %s', missionType.typeId, missionType.name, prevValue, newValue)
                end
            end
        end

        if ContractBoost.debug then print('-- ContractBoost:MissionBalance :: scaleMissionReward complete.') end
    end
end