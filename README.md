# Contract Boost for FS25
Farming Simulator 25 changed contracts across the board - some things are for the better, and other things are either frustrating or just don't make sense. This mod aims to allow the player to activate / alter the contract system to their needs, allowing customization of the number of contracts available, the limit on active contracts, the reward rate for each type of contract (or all at once), as well as enabling many more contract tools than are currently allowed.

This mod is intended to work alongside **BetterContracts** (once it's updated for FS25), providing some much needed tweaks to the contract system, as well as providing similar functionality to **CollectStrawAtMissions**, but extending that concept to also affect fieldwork tools allowed on harvest, mowing, plow, cultivate & sowing missions. In addition, the mod also adds something completely new - adding fieldwork fill items to the "borrowed" contract items, allowing you to get started with contracts without any money in your pocket!

## Description from the ModDesc
> Boost your contracts by making more money, and allowing collection of the spoils!
> - 50% more profit from every contract
> - 10 max contracts
> - 5 max contracts per type by default
> - Allow setting a custom amount per type of contract
> - 50 total contracts available
> - Borrowed contract equipment comes with free fieldwork items to fill your tools
> - Allow using swathing equipment on harvest missions
> - Allow collecting straw from harvest missionss
> - Allow collecting grass from mowing missions
> - Allow collecting stones from plow, cultivate, and sowing missions
> 
> All of the above settings can be modified via an XML settings file at `/FarmingSimulator2025/modSettings/ContractBoost.xml`
>
> For license & feedback, please visit: https://github.com/GMNGjoy/FS25_ContractBoost


## Installation Instructions
1. Download this package from GitHub on the releases page, save the `FS25_ContractBoost.zip` into your mod folder.
2. Launch the game, and activate the mod.
3. If you wish to customize any of the settings, visit your savegame folder structure, and look for the settings file: `/FarmingSimulator2025/modSettings/ContractBoost.xml`, which is created once you load the mod into any save. Each item above has it's own setting, and the file explains the full settings and what appropriate values for each are.

_Enjoy!_


## Screenshots

![Run more than three active contracts!](/_screenshots/screenshot_activeContractsMenu.png)
<br/><br/>

![Control how many active contracts you can have per farm!](/_screenshots/screenshot_activeContracts.png)
<br/><br/>

![Collect straw during harvest contracts!](/_screenshots/screenshot_straw.png)
<br/><br/>

![Enable the use of Macdon windrower & pickup header on a Harvest contract!](/_screenshots/screenshot_macdon.png)
<br/><br/>

![Windrow, bale & collect grass during mowing contracts!](/_screenshots/screenshot_grass.png)
<br/><br/>

![Fertilizer included on fertilizing contracts!](/_screenshots/screenshot_fertilizer.png)
<br/><br/>

![Herbicide included on spraying contracts!](/_screenshots/screenshot_herbicide.png)
<br/><br/>


## Detailed Configuration Instructions

**Contract Boost** is entirely controlled by a named configuration file (`ContractBoost.xml`) that is copied into your `modSettings/` folder on first usage. The file is located in the same folder that your `savegame##` folder is located, roughly here:

`/FarmingSimulator2025/modSettings/ContractBoost.xml`

The file itself contains documentation for all of the primary settings, which I'll copy here.

```xml
    <settings>
        <!--
            debugMode: turn on extra debug that gets sent to the log
            ~ values: true/false
            ~ default: false
        -->
        <debugMode>false</debugMode>
        
        <!--
            enableContractValueOverrides: enables overriding contract system default setting values;
               disables all of the following settings:
               - rewardFactor
               - maxContractsPerFarm
               - maxContractsPerType
               - maxContractsOverall
            ~ values: true/false
            ~ default: true
        -->
        <enableContractValueOverrides>true</enableContractValueOverrides>

        <!--
            enableStrawFromHarvestMissions: should straw be collectible from during harvest missions?
            ~ values: true/false
            ~ default: true
        -->
        <enableStrawFromHarvestMissions>true</enableStrawFromHarvestMissions>

        <!--
            enableSwathingForHarvestMissions: should you be able to use a Swather for harvest missions?
            ~ values: true/false
            ~ default: true
        -->
        <enableSwathingForHarvestMissions>true</enableSwathingForHarvestMissions>

        <!--
            enableGrassFromMowingMissions: should grass be collectible from during mowing missions?
            ~ values: true/false
            ~ default: true
        -->
        <enableGrassFromMowingMissions>true</enableGrassFromMowingMissions>
        
        <!--
            enableStonePickingFromMissions: should stones be collectible from during tilling & sowing missions?
            ~ values: true/false
            ~ default: true
        -->
        <enableStonePickingFromMissions>true</enableStonePickingFromMissions>

        <!--
            enableFieldworkToolFillItems: should borrowed equipment come with free fieldwork items to fill your tools?
            ~ values: true/false
            ~ default: true
        -->
        <enableFieldworkToolFillItems>true</enableFieldworkToolFillItems>

        <!--
            rewardFactor: applies a multiplier to the base game rewardPer value
            ~ minValue: 0.5 
            ~ maxValue: 5.0
            ~ mod default: 1.5
            ~ game default: 1.0
        -->
        <rewardFactor>1.5</rewardFactor>

        <!--
            maxContractsPerFarm: how many contracts can be active at once
            ~ minValue: 1 
            ~ maxValue: 100
            ~ mod default: 10
            ~ game default: 3
        -->
        <maxContractsPerFarm>10</maxContractsPerFarm>

        <!--
            maxContractsPerType: how many contracts per contract type can be available
            ~ minValue: 1 
            ~ maxValue: 20
            ~ mod default: 5
            ~ game default: 1-4 depending on type
        -->
        <maxContractsPerType>5</maxContractsPerType>

        <!--
            maxContractsOverall: how many contracts overall can be available
            ~ minValue: 1 
            ~ maxValue: 100
            ~ mod default: 50
            ~ game default: 20
        -->
        <maxContractsOverall>50</maxContractsOverall>

    </settings>
```

For the `customRewards` section, the same documentation was not included in the document as it would be somewhat repetitive, but let's include that here!

One thing to call out that may not be obvious - the `<rewardFactor>1.5</rewardFactor>` setting above in the file is already being applied to the contract rates, which means that you're already getting a 150% boost applied to _all contracts_, but the custom rewards allows the player to further customize each of those values to tailor to their needs. any `customReward` value will override the `rewardFactor` setting.... so if the reward factor is set to `1.5`, that means that for bale missions you are already getting a per-hectare rate of `2200 * 1.5 = 3300`. For a 2ha contract, that means you should get roughly `$6600`. 

For the example value that is already set in the file, setting `baleMission` to `3500`, if you have a 2ha contract, then the contract reward should be roughly `$7000`.


### Some settings are calculated "per item" (per bale, per rock)
- `<baleWrapMission />` (per bale) [default value: `300`]
- `<deadwoodMission />` (per tree) [default value: `150`]
- `<destructibleRockMission/>` (per rock) [default value: `550`]


### All remaining settings are calculated per hectare of the contract 
- `<baleMission />` (per HA) [default value: `2200`]
- `<plowMission />` (per HA) [default value: `2800`]
- `<cultivateMission />` (per HA) [default value: `2300`]
- `<sowMission />` (per HA) [default value: `2000`]
- `<harvestMission />` (per HA) [default value: `2500`]
- `<hoeMission />` (per HA) [default value: `1500`]
- `<weedMission />` (per HA) [default value: `2000`]
- `<herbicideMission />` (per HA) [default value: `1500`]
- `<fertilizeMission />` (per HA) [default value: `1500`]
- `<mowMission />` (per HA) [default value: `2500`]
- `<tedderMission />` (per HA) [default value: `1500`]
- `<stonePickMission />` (per HA) [default value: `2200`]


The `customMaxPerType` allows setting a specific maximum amount of contracts per type.
You can stop specific types from showing by setting the value to `0`. Furthermore the mod has a set maximum of 20 contracts per type.

### All Game Defaults for Max Contracts per type 

- `baleMission:` `3`
- `baleWrapMission:` `2`
- `plowMission:` `2`
- `cultivateMission:` `3`
- `sowMission:` `5`
- `harvestMission:` `10`
- `hoeMission:` `2`
- `weedMission:` `2`
- `herbicideMission:` `2`
- `fertilizeMission:` `3`
- `mowMission:` `3`
- `tedderMission:` `2`
- `stonePickMission:` `1`
- `deadwoodMission:` `1`
- `treeTransportMission:` `1`
- `destructibleRockMission:` `1`