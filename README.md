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
> - Allow collecting hay from tedding missions
> - Allow collecting stones from plow, cultivate, and sowing missions
> - Allow collecting bales from baling and bale-wrapping missions
> - Allow collecting stones from plow, cultivate, and sowing missions
> 
> All of the above settings can be modified in-game through the General Settings panel.
> 
> NOTE: Setting changes that may affect the reward or number of missions may *not* affect any already generated contracts.
>
> For license & feedback, please visit: https://github.com/GMNGjoy/FS25_ContractBoost


## Installation Instructions
1. Download this package from GitHub on the releases page, save the `FS25_ContractBoost.zip` into your mod folder.
2. Launch the game, and activate the mod.
3. Once you are inside the game, customize any of the _Contract Boost_ settings as needed within the Settings > General Settings tab. When you save, a new configuration file is created in your `savegame##` folder, which will be edited and managed by the _Contract Boost_ mod. In very minor cases, direct editing of this file may be required (as detailed below).

_Enjoy!_


## Screenshots

![Run more than three active contracts!](/_screenshots/screenshot_02_activeContractsMenu.png)
<br/><br/>

![Control how many active contracts you can have per farm!](/_screenshots/screenshot_activeContracts.png)
<br/><br/>

![Collect straw during harvest contracts!](/_screenshots/screenshot_01_straw.png)
<br/><br/>

![Enable the use of Macdon windrower & pickup header on a Harvest contract!](/_screenshots/screenshot_03_macdon.png)
<br/><br/>

![Windrow, bale & collect grass during mowing contracts!](/_screenshots/screenshot_04_grass.png)
<br/><br/>

![Fertilizer included on fertilizing contracts!](/_screenshots/screenshot_05_fertilizer.png)
<br/><br/>

![Herbicide included on spraying contracts!](/_screenshots/screenshot_06_herbicide.png)
<br/><br/>

## CHANGELOG

### Changelog `1.0.0.2`
- Added safety check for custom maps that don't contain every type of contract

### Changelog `1.1.0.0` _(still in development)_
- User contributed translations: `fr`, `cz`, `it`, `pl`, `ru`, `da`
- Allow collecting hay from tedding contracts
- Allow collecting straw bales from baling contracts
- Allow collecting wrapped silage bales from bale-wrapping contracts
- Added cultivator to seeding missions, just in case you mess up
- Added support customizing of the number of contracts for each type of contract individually, with the ability to "disable" contract types you don't want to see.
- Added feature to remove already added fill items when the `enableFieldworkToolFillItems` setting is switched off
- Added feature to remove unwanted contracts when you change the `customMaxPerType` setting. Example: There are `5` deadwood contracts in your list, but you're tired of seeing them... update the `maxPerType` setting for deadwood to `2` and when you save your game, _Contract Boost_ will automatically remove three contract from the bottom of the list. This setting is _checked_ and _cleaned_ both on game load and save.
- Added feature to "prefer" harvesting missions over baling missions as cereal-crop harvesting missions are less frequent due to the new straw baling missions.
- Added feature to enable or disable certain types of harvesting contracts.
- _Contract Boost_ settings are now managed in-game. 
   - All settings previously in the configuration file can be set in the General Settings panel in-game, and will be updated when saving your game.
   - The new `FS25_ContractBoost.xml` configuration file in savegame folder should only be manually edited while game is not running.
   - The old `ContractBoost.xml` configuration file in modSettings folder has been depreciated
   - Settings have been rebuilt to support MP syncronization :: The server is the source of truth for settings, clients recieve settings on connect or change.


## Configuration Instructions (`1.1.0.0`)

All settings are now configurable within the UI. Note: most setting changes _**will not**_ affect existing contracts, only new contracts.

![New in-game Contract Boost settings control.](/_screenshots/screenshot_07_settingsControl.png)

![Detailed customization of the rewards per contract type, as well as the maximum number of contracts that can be generated per type.](/_screenshots/screenshot_08_settingsCustomization.png)

The previous configuration file is now _depreciated_, but will be used if it exists as the "defaults" until the settings are customized in-game.

### Dedicated Server settings
On a dedicated server, the settings are saved on the server within the server's savegame directory, the same as it now is in single player. To edit those settings, you must edit those settings by one of two methods:

#### In game, as admin (preferred method)
1. Join the multiplayer session and login to the server as admin through the game interface
2. Edit the settings as needed on the settings screen.
3. Once settings are changed, save the game to ensure that the `FS25_ContractBoost.xml` settings file is created.
4. Most settings changes are "pushed" to any other players on the server immediately, but it's always safest to save, exit, and restart the dedicated server, as many of those settings affect how the game is loaded, and how contracts are generated.

#### Directly on the server via FTP
1. Save the settings at least once via the first method, ensure that the `FS25_ContractBoost.xml` settings file is created.
2. Stop the game server, and download a local copy of the settings file from the appropriate savegame folder.
3. Edit the settings as needed with your favorite text editor
4. Re-upload the updated settings file via FTP
5. Start the server.

This second method assumes a few things: 
#1 you understand how to edit XML
#2 you're at your own risk if you make a mistake
#3 don't be dumb - there are limits on most of the values set in the settings file that are caught when the file is loaded.



### Detailed explanation: `enableCollectingBalesFromMissions`
This boolean (`true|false`) setting will allow the player to collect the bales created from / during both Baling & Bale Wrapping contracts. One major note with this setting - you _MUST_ have this setting turned on _BEFORE_ accepting one of these two types of contracts; It will cause errors if you accept the contract with the seting off, then turning it on after accepting. You _may_ be able to pick up the bales, and as long as the setting is on when you complete the contract, the bales will not be removed... but you will recieve an error in the log when trying to use or sell those bales.


### Detailed explanation: `enableInGameSettingsMenu` (default: `true`) manual setting
This setting can _ONLY_ be changed by manually editing your **Contract Boost** settings file.
1. Load into game with **Contract Boost** `1.0.5.3` or greater
2. Save your game once, exit out
3. Find your `FS25_ContractBoost.xml` settings file in your savegame folder.
4. Update this line to have a `false` value. 
```xml
<enableInGameSettingsMenu>false</enableInGameSettingsMenu>
```
5. Load back into game, and your settings menu will be gone.

> *NOTE*: this means that you won't be able to edit **ContractBoost** settings in-game without either 
> (a) re-enabling the `enableInGameSettingsMenu` by following the steps above but setting the value to true, or 
> (b) editing the settings file directly when you're outside of the game for any settings changes that are needed.

### Detailed explanation: `enableCustomGrassFieldsForMissions`
This boolean (`true|false`) setting will fix what I consider to be a major bug in the field system, that affects grass-based contracts pretty badly. If you play on a map (ie: Hutan Pantai) that has no grass fields specified in the map.i3d itself (relying on random generation), those grass fields will initially have contracts, but quickly will be destroyed by either cultivating or plowing contracts - and since NPC almost never re-plant grass on their own or via seeding contracts - this means you'll quickly lose all grass-based contracts. As a player, this pretty much sucks. This setting will check each time you load the game (and / or change your settings) to make sure two things - one, that every field that has grass in it is setup as `grassMissionOnly` (which prevents the cultivating or plowing steps), but also remove weeds on those same fields if they grow (which should never happen, shame on you Giants!)


### Detailed explanation: `enableHarvestContract**`
This set of boolean (`true|false`) settings stop new harvest contracts from being created for the suggested type of crops (existing contracts will not be affected). All of these settings are in the in-game settings menu as easy on|off toggles. The specified crops are somewhat self explanatory, but I'll call them out here just in case:
    - `enableHarvestContractNewCrops` :: Peas, Green Beans &amp; Spinach
    - `enableHarvestContractPremiumCrops` :: Carrots, Parsnips &amp; Red Beets
    - `enableHarvestContractRootCrops` :: Potatoes &amp; Sugar Beets
    - `enableHarvestContractSugarcane` :: Sugarcane
    - `enableHarvestContractCotton` :: Cotton


### Detailed explanation: `preferStrawHarvestMissions`
This boolean (`true|false`) setting (default `true`) will prevent straw baling contracts from being created on `harvestReady` fields, indirectly allowing those fields to be available for harvesting contracts. This setting also prevents straw baling contracts from being created on `greenBig` field (one state before `harvestReady`), which the game allows for some odd reason. Having this setting on will still allow grass baling missions, and will still allow straw baling missions on harvested fields (which is a base game "feature"). NOTE: this will also affect fields that are enabled for straw that don't typically drop straw, when used alongside the Extended Straw Crops mod.


## Detailed Configuration Instructions (pre `1.0.3.0`)

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




## Known Issues
- [SP|MP] Depending on the in-game month, the game will possibly grant you _Spraying_ contracts on fields that are withered. This is a bug in the base game, not the _Contract Boost_ mod - as you can't spray a withered field even if you own it. I've reported the bug to Giants.

- [SP|MP] Changes to some settings may or may not reflect on contracts that are already either in the available contracts list, or in your accepted contracts list when you make contract boost settings changes; Most will take efffect right away, but depending on how you play - I'd always recommend making the changes you want, saving the game and at least exiting out to the main menu and coming back into your savegame. Especially on dedicated servers, it's always recommended to restart the server after making _Contract Boost_ settings changes.