-- MissionBorrow
-- @goal to provide fieldwork items with your mission machiery that needs to be filled
-- @author GMNGjoy
-- @copyright 11/15/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal

MissionBorrow = {}
MissionBorrow.pallets = {
    bigBagPallet_fertilizer = true,
    herbicideTank = true,
    bigBagPallet_seeds = true,
}
MissionBorrow.fillMissionTypes = {
    "fertilizeMission",
    "herbicideMission",
    "sowMission",
}
MissionBorrow.palletFilenames = {
    fertilizeMission = 'data/objects/bigBagPallet/fertilizer/bigBagPallet_fertilizer.xml',
    herbicideMission = 'data/objects/pallets/liquidTank/herbicideTank.xml',
    sowMission = 'data/objects/bigBagPallet/seeds/bigBagPallet_seeds.xml',
}

MissionBorrow.fillItemsAdded = false

-- When a "vehicle" is spawned if it's a pallet, ignore the wear and operating time functions.
function MissionBorrow.onSpawnedVehicle(self, superFunc, vehicles, ...)
    if not g_currentMission.contractBoostSettings.enableFieldworkToolFillItems then
        superFunc(self, vehicles, ...)
        return
    end

    if vehicles ~= nil then
        for _, vehicle in ipairs(vehicles) do
            local configNameClean = vehicle.configFileNameClean

            if ContractBoost.debug then
                Logging.info(MOD_NAME..':BORROW :: onSpawnedVehicle: %s | isPallet: %s', configNameClean, MissionBorrow.pallets[configNameClean] and "yes" or "no")
            end

            if MissionBorrow.pallets[configNameClean] then
                vehicle.addWearAmount = function() return true end
                vehicle.setOperatingTime = function() return true end
            end
        end

        superFunc(self, vehicles, ...)
    end
end


-- Adds fill items to the mission tools for each type of mission where needed.
function MissionBorrow:addFillItemsToMissionTools()
    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: addFillItemsToMissionTools') end

    if self:checkForFillItemsToMissionTools() then
        if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: addFillItemsToMissionTools exit, already added') end
        return
    end

    for _, fillMissionType in pairs(self.fillMissionTypes) do
        if g_missionManager.missionVehicles[fillMissionType] ~= nil then
            for size, vehicles in pairs(g_missionManager.missionVehicles[fillMissionType]) do
                for v, vehicle in pairs(vehicles) do

                    if fillMissionType == 'fertilizeMission' then

                        table.insert(vehicle.vehicles, {
                            filename = self.palletFilenames[fillMissionType]
                        })

                        if size ~= "small" then
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                        end

                        if size == "large" then
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                        end

                    elseif fillMissionType == 'herbicideMission' then

                        table.insert(vehicle.vehicles, {
                            filename = self.palletFilenames[fillMissionType]
                        })

                        if size == "large" then
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                        end

                    elseif fillMissionType == 'sowMission' then

                        table.insert(vehicle.vehicles, {
                            filename = self.palletFilenames[fillMissionType]
                        })
                        table.insert(vehicle.vehicles, {
                            filename = self.palletFilenames[fillMissionType]
                        })
                        if size == "large" then
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                        end

                    end
                end
            end
        end
    end

    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: addFillItemsToMissionTools complete') end
end


function MissionBorrow:checkForFillItemsToMissionTools()
    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: checkForFillItemsToMissionTools') end

    for _, fillMissionType in pairs(self.fillMissionTypes) do
        if g_missionManager.missionVehicles[fillMissionType] ~= nil then
            for size, vehicles in pairs(g_missionManager.missionVehicles[fillMissionType]) do
                for v, vehicle in pairs(vehicles) do
                    for v2, spawnVehicle in pairs(vehicle.vehicles) do
                        if spawnVehicle.filename == self.palletFilenames.fertilizeMission 
                            or spawnVehicle.filename == self.palletFilenames.herbicideMission 
                            or spawnVehicle.filename == self.palletFilenames.sowMission then
                                return true
                        end
                    end
                end
            end
        end
    end

    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: checkForFillItemsToMissionTools not found') end

    return false
end

function MissionBorrow:removeFillItemsToMissionTools()
    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: removeFillItemsToMissionTools') end

    for _, fillMissionType in pairs(self.fillMissionTypes) do
        if g_missionManager.missionVehicles[fillMissionType] ~= nil then
            for size, vehicles in pairs(g_missionManager.missionVehicles[fillMissionType]) do
                for v, vehicle in pairs(vehicles) do
                    -- since we're removing items from the table, we have to iterate from the end of the table.
                    for v2 = #vehicle.vehicles, 1, -1 do
                        local spawnVehicle = vehicle.vehicles[v2]
                        if spawnVehicle.filename == self.palletFilenames.fertilizeMission 
                            or spawnVehicle.filename == self.palletFilenames.herbicideMission 
                            or spawnVehicle.filename == self.palletFilenames.sowMission then
                            table.remove(vehicle.vehicles, v2)
                        end
                    end
                end
            end
        end
    end

    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: removeFillItemsToMissionTools complete') end
end