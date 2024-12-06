--- XML Config Loader
-- @author GMNGjoy
-- @copyright 11/15/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal

XmlConfigLoader = {}
XmlConfigLoader.path = g_currentModDirectory;
XmlConfigLoader.modName = g_currentModName;
XmlConfigLoader.loadComplete = false;
XmlConfigLoader.loadDebug = true;

-- configuration files and loading states
XmlConfigLoader.userConfig = {};
XmlConfigLoader.userConfigLoaded = false;

-- defaults for existing settings
XmlConfigLoader.rewardFactor = 1.5
XmlConfigLoader.maxContractsPerFarm = 10
XmlConfigLoader.maxContractsPerType = 5
XmlConfigLoader.maxContractsOverall = 50
XmlConfigLoader.enableContractValueOverrides = true
XmlConfigLoader.enableStrawFromHarvestMissions = true
XmlConfigLoader.enableSwathingForHarvestMissions = true
XmlConfigLoader.enableGrassFromMowingMissions = true
XmlConfigLoader.enableStonePickingFromMissions = true
XmlConfigLoader.enableFieldworkToolFillItems = true
XmlConfigLoader.debugMode = false

-- xmlConfigFiles
XmlConfigLoader.defaultConfigFile = "xml/defaultConfig.xml"
XmlConfigLoader.userConfigFile = "modSettings/ContractBoost.xml"
XmlConfigLoader.xmlTag = "contractBoost"

--- Initialize the loader
---@return table
function XmlConfigLoader.init()

	if XmlConfigLoader.loadDebug then print("---- ContractBoost:XmlConfigLoader: read user configurations") end

	-- setup the xml schema
	XmlConfigLoader.initXml()

	-- don't load it twice if the config is already loaded.
	if XmlConfigLoader.userConfigLoaded then 
		return XmlConfigLoader.userConfig
	end

	-- determine the proper path for the user's settings file
	local userSettingsFile = Utils.getFilename(XmlConfigLoader.userConfigFile, getUserProfileAppPath())

	local N = 0
	local loadedConfig = {}
	if fileExists(userSettingsFile) then

		XmlConfigLoader.userConfig = XmlConfigLoader.importConfig(userSettingsFile)
		XmlConfigLoader.userConfigLoaded = true

		loadedConfig = XmlConfigLoader.userConfig

		printf("---- ContractBoost:XmlConfigLoader: IMPORT user configuration from: %s | debug: %s", XmlConfigLoader.userConfigFile, loadedConfig.debugMode and "true" or "false")

	else

		printf("---- ContractBoost:XmlConfigLoader: CREATING user configuration file: %s", XmlConfigLoader.userConfigFile)
		local defaultSettingsFile = Utils.getFilename(XmlConfigLoader.defaultConfigFile, XmlConfigLoader.path)
		copyFile(defaultSettingsFile, userSettingsFile, false)

		loadedConfig = XmlConfigLoader.importConfig(userSettingsFile)
	end

	if XmlConfigLoader.loadDebug then
        print('-- ContractBoost:XmlConfigLoader :: returned config')
        DebugUtil.printTableRecursively(loadedConfig)
    end

	return loadedConfig
end

--- Initiaze the XML file configuration
function XmlConfigLoader.initXml()

	XmlConfigLoader.xmlSchema = XMLSchema.new(XmlConfigLoader.xmlTag)

	XmlConfigLoader.xmlSchema:register(XMLValueType.BOOL, XmlConfigLoader.xmlTag..".settings.debugMode", "Turn debugMode on for additional log output", XmlConfigLoader.debugMode)
	
	XmlConfigLoader.xmlSchema:register(XMLValueType.BOOL, XmlConfigLoader.xmlTag..".settings.enableContractValueOverrides", "enables overriding contract system default setting values", XmlConfigLoader.enableContractValueOverrides)
	XmlConfigLoader.xmlSchema:register(XMLValueType.BOOL, XmlConfigLoader.xmlTag..".settings.enableStrawFromHarvestMissions", "should straw be collectible from during harvest missions?", XmlConfigLoader.enableStrawFromHarvestMissions)
	XmlConfigLoader.xmlSchema:register(XMLValueType.BOOL, XmlConfigLoader.xmlTag..".settings.enableSwathingForHarvestMissions", "should you be able to use a Swather for harvest missions?", XmlConfigLoader.enableSwathingForHarvestMissions)
	XmlConfigLoader.xmlSchema:register(XMLValueType.BOOL, XmlConfigLoader.xmlTag..".settings.enableGrassFromMowingMissions", "should grass be collectible from during mowing missions?", XmlConfigLoader.enableGrassFromMowingMissions)
	XmlConfigLoader.xmlSchema:register(XMLValueType.BOOL, XmlConfigLoader.xmlTag..".settings.enableStonePickingFromMissions", "should stones be collectible from during tilling & sowing missions?", XmlConfigLoader.enableStonePickingFromMissions)
	XmlConfigLoader.xmlSchema:register(XMLValueType.BOOL, XmlConfigLoader.xmlTag..".settings.enableFieldworkToolFillItems", "should borrowed equipment come with free fieldwork items to fill your tools", XmlConfigLoader.enableFieldworkToolFillItems)

	XmlConfigLoader.xmlSchema:register(XMLValueType.FLOAT, XmlConfigLoader.xmlTag..".settings.rewardFactor", "applies a multiplier to the base game rewardPer value", XmlConfigLoader.rewardFactor)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".settings.maxContractsPerFarm", "how many contracts can be active at once", XmlConfigLoader.maxContractsPerFarm)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".settings.maxContractsPerType", "how many contracts per contract type can be available", XmlConfigLoader.maxContractsPerType)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".settings.maxContractsOverall", "how many contracts overall can be available", XmlConfigLoader.maxContractsOverall)

	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.baleMission", "custom rewardPerHa for baleMissions", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.baleWrapMission", "custom rewardPerBale for baleWrapMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.plowMission", "custom rewardPerHa for plowMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.cultivateMission", "custom rewardPerHa for cultivateMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.sowMission", "custom rewardPerHa for sowMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.harvestMission", "custom rewardPerHa for harvestMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.hoeMission", "custom rewardPerHa for hoeMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.weedMission", "custom rewardPerHa for weedMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.herbicideMission", "custom rewardPerHa for herbicideMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.fertilizeMission", "custom rewardPerHa for fertilizeMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.mowMission", "custom rewardPerHa for mowMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.tedderMission", "custom rewardPerHa for tedderMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.stonePickMission", "custom rewardPerHa for stonePickMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.deadwoodMission", "custom rewardPerTree for deadwoodMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.treeTransportMission", "custom rewardPerTree for treeTransportMission", nil)
	XmlConfigLoader.xmlSchema:register(XMLValueType.INT, XmlConfigLoader.xmlTag..".customRewards.destructibleRockMission", "custom rewardPerHa for destructibleRockMission", nil)
	
end

--- Initiaze the a specified xmlFilename as a config
---@param xmlFilename string
---@return table
function XmlConfigLoader.importConfig(xmlFilename)
	local loadedConfig = {}
	local xmlFile = XMLFile.load("xmlFile", xmlFilename, XmlConfigLoader.xmlSchema)

	if XmlConfigLoader.loadDebug then
        printf('-- ContractBoost:XmlConfigLoader :: loaded file: %s', xmlFilename)
	end

	if xmlFile ~= 0 then

		loadedConfig.debugMode = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.debugMode", XmlConfigLoader.debugMode)

		loadedConfig.enableContractValueOverrides = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.enableContractValueOverrides", XmlConfigLoader.enableContractValueOverrides)
		loadedConfig.enableStrawFromHarvestMissions = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.enableStrawFromHarvestMissions", XmlConfigLoader.enableStrawFromHarvestMissions)
		loadedConfig.enableSwathingForHarvestMissions = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.enableSwathingForHarvestMissions", XmlConfigLoader.enableSwathingForHarvestMissions)
		loadedConfig.enableGrassFromMowingMissions = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.enableGrassFromMowingMissions", XmlConfigLoader.enableGrassFromMowingMissions)
		loadedConfig.enableStonePickingFromMissions = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.enableStonePickingFromMissions", XmlConfigLoader.enableStonePickingFromMissions)
		loadedConfig.enableFieldworkToolFillItems = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.enableFieldworkToolFillItems", XmlConfigLoader.enableFieldworkToolFillItems)
		
		loadedConfig.rewardFactor = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.rewardFactor", XmlConfigLoader.rewardFactor)
		loadedConfig.maxContractsPerFarm = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.maxContractsPerFarm", XmlConfigLoader.maxContractsPerFarm)
		loadedConfig.maxContractsPerType = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.maxContractsPerType", XmlConfigLoader.maxContractsPerType)
		loadedConfig.maxContractsOverall = xmlFile:getValue(XmlConfigLoader.xmlTag..".settings.maxContractsOverall", XmlConfigLoader.maxContractsOverall)

		loadedConfig.customRewards = {}
		loadedConfig.customRewards.baleMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.baleMission", nil)
		loadedConfig.customRewards.baleWrapMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.baleWrapMission", nil)
		loadedConfig.customRewards.plowMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.plowMission", nil)
		loadedConfig.customRewards.cultivateMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.cultivateMission", nil)
		loadedConfig.customRewards.sowMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.sowMission", nil)
		loadedConfig.customRewards.harvestMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.harvestMission", nil)
		loadedConfig.customRewards.hoeMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.hoeMission", nil)
		loadedConfig.customRewards.weedMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.weedMission", nil)
		loadedConfig.customRewards.herbicideMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.herbicideMission", nil)
		loadedConfig.customRewards.fertilizeMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.fertilizeMission", nil)
		loadedConfig.customRewards.mowMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.mowMission", nil)
		loadedConfig.customRewards.tedderMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.tedderMission", nil)
		loadedConfig.customRewards.stonePickMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.stonePickMission", nil)
		loadedConfig.customRewards.deadwoodMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.deadwoodMission", nil)
		loadedConfig.customRewards.treeTransportMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.treeTransportMission", nil)
		loadedConfig.customRewards.destructibleRockMission = xmlFile:getValue(XmlConfigLoader.xmlTag..".customRewards.destructibleRockMission", nil)

		-- ensure that values are within limits for numerical values
		if loadedConfig.rewardFactor < 0.1 or loadedConfig.rewardFactor > 5.0 then
			printf('-- ContractBoost:XmlConfigLoader :: user configured rewardFactor (%s) outside of limits, reset to default.', loadedConfig.rewardFactor)
			loadedConfig.rewardFactor = XmlConfigLoader.rewardFactor
		end

		if loadedConfig.maxContractsPerFarm < 1 or loadedConfig.maxContractsPerFarm > 100 then
			printf('-- ContractBoost:XmlConfigLoader :: user configured maxContractsPerFarm (%s) outside of limits, reset to default.', loadedConfig.maxContractsPerFarm)
			loadedConfig.maxContractsPerFarm = XmlConfigLoader.maxContractsPerFarm
		end

		if loadedConfig.maxContractsPerType < 1 or loadedConfig.maxContractsPerType > 20 then
			printf('-- ContractBoost:XmlConfigLoader :: user configured maxContractsPerType (%s) outside of limits, reset to default.', loadedConfig.maxContractsPerType)
			loadedConfig.maxContractsPerType = XmlConfigLoader.maxContractsPerType
		end

		if loadedConfig.maxContractsOverall < 1 or loadedConfig.maxContractsOverall > 100 then
			printf('-- ContractBoost:XmlConfigLoader :: user configured maxContractsOverall (%d) outside of limits, reset to default.', loadedConfig.maxContractsOverall)
			loadedConfig.maxContractsOverall = XmlConfigLoader.maxContractsOverall
			
		end

		-- Custom rewards now only support steps of 500 since the introduction of UI settings
		for propName, value in loadedConfig.customRewards do
			if value ~= nil and value % 500 ~= 0 then
				-- Round to steps of 500
				loadedConfig.customRewards[propName] = math.floor((value + 250) / 500) * 500
				printf('-- ContractBoost:XmlConfigLoader :: Rounded property customRewards.%s from %d to %d', propName, value, loadedConfig.customRewards[propName])
			end
		end
		
	end

	xmlFile:delete()

	if XmlConfigLoader.loadDebug then
        print('-- ContractBoost:XmlConfigLoader :: loadedConfig')
        DebugUtil.printTableRecursively(loadedConfig)
    end

	return loadedConfig
end