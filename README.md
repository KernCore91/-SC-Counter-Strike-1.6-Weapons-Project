# Counter-Strike 1.6 Weapons Project
![](https://i.imgur.com/RBAc53x.png)
> Custom weapons project for Sven Co-op

This project is brought to you by the following super dedicated team members: D.N.I.O. 071, R4to0, and me (KernCore). This project started in late October of 2020. This is a Re-release of the original project that started in 2016.  

## The Weapons

* .228 Compact (weapon_p228)
* .40 Dual Elites (weapon_dualelites)
* 9×19mm Sidearm (weapon_csglock18)
* Bullpup (weapon_aug)
* C4 Bomb (weapon_c4)
* Clarion 5.56 (weapon_famas)
* CV-47 (weapon_ak47)
* D3/AU-1 (weapon_g3sg1)
* ES C90 (weapon_p90)
* ES Five-SeveN (weapon_fiveseven)
* ES M249 SAW (weapon_csm249)
* High Explosive Grenade (weapon_hegrenade)
* IDF Defender (weapon_galil)
* Ingram MAC-10 (weapon_mac10)
* K&M .45 Tactical (weapon_usp)
* K&M Sub-Machine Gun (weapon_mp5navy)
* K&M UMP45 (weapon_ump45)
* Knife (weapon_csknife)
* Krieg 550 Commando (weapon_sg550)
* Krieg 552 (weapon_sg552)
* Leone 12 Gauge Super (weapon_m3)
* Leone YG1265 Auto Shotgun (weapon_xm1014)
* Magnum Sniper Rifle (weapon_awp)
* Maverick M4A1 Carbine (weapon_m4a1)
* Night Hawk .50C (weapon_csdeagle)
* Schmidt Machine Pistol (weapon_tmp)
* Schmidt Scout (weapon_scout)

## Gameplay Video

Video:
[![](http://i3.ytimg.com/vi/LyThjfNqwWs/maxresdefault.jpg)](https://www.youtube.com/watch?v=LyThjfNqwWs)
*by VitorHunter.*

## Screenshots
[![](https://i.imgur.com/XRJbALTm.png)](https://i.imgur.com/XRJbALT.png)
[![](https://i.imgur.com/fogrWZEm.png)](https://i.imgur.com/fogrWZE.png)
[![](https://i.imgur.com/Rwn01Vfm.png)](https://i.imgur.com/Rwn01Vf.png)
[![](https://i.imgur.com/84E0GqLm.png)](https://i.imgur.com/84E0GqL.png)
[![](https://i.imgur.com/yszXhUnm.png)](https://i.imgur.com/yszXhUn.png)
[![](https://i.imgur.com/gYkANMzm.png)](https://i.imgur.com/gYkANMz.png)

## Installation Guide

1. Registering the weapons as plugins (Good for server operators, and most people):
	1. Download the pack from one of the download links below
	2. Extract it's contents inside **`Steam\steamapps\common\Sven Co-op\svencoop_addon\`**
	3. Open up *`default_plugins.txt`* located in **`Steam\steamapps\common\Sven Co-op\svencoop\`**
	4. Add these lines to the file:
	```
	"plugin"
	{
		"name"          "Counter-Strike 1.6 Mod"
		"script"        "../maps/cs16/cs16_register"
		"concommandns"     "cs16"
	}
	```
	5. Load any map of your preference;
	6. Type in chat *\buy* or type in console give *name of the weapon* and enjoy.

2. Registering the weapons as map_scripts (Good for map makers):
	1. Download the pack from one of the download links below
	2. Extract it's contents inside **`Steam\steamapps\common\Sven Co-op\svencoop_addon\`**
	3. Open up any map *.cfg* (i.e: **svencoop1.cfg**) and add this line to it:
	```
	map_script cs16/cs16_register
	```
	4. Load up the map you chose;
	5. Type in chat *\buy* or type in console give *name of the weapon* and enjoy.

## Additional Content

This pack includes a heavily modified Buymenu made specifically for it.  
Here are the following commands that can be used in the Buymenu:

```
// Opening the Buy menu in the chat:
buy
/buy
!buy
.buy
\buy
#buy

// Opening the Buy menu in the console:
.buy

// Buying a specific weapon/ammo (without the weapon_ prefix) without the menu:
<menu opening command here> <entity identifier here> <weapon name here> ie:
!buy w p90 (will directly buy a P90 for you) or 
/buy a p90 (will directly buy ammo for the P90 for you)

// Buying ammo for the current equipped weapon:
<menu opening command here> ammo ie:
!buy ammo or
/buy ammo
```

Server commands (in case you registered the weapons as a plugin):
```
as_command cs16.bm_maxmoney <value>
as_command cs16.bm_moneyperscore <value>
as_command cs16.bm_startmoney <value>
```