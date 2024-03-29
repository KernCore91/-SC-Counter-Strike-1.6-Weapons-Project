# Counter-Strike 1.6 Weapons Project
![](https://i.imgur.com/RBAc53x.png)
> Custom weapons project for Sven Co-op

This project is brought to you by the following super dedicated team members: D.N.I.O. 071, R4to0, and me (KernCore). This project started in late October of 2020. This is a Re-release of the original project that started in 2016.  

# **DO NOT RUN THIS PLUGIN ALONG WITH ANOTHER WEAPON PLUGIN, NO SUPPORT IS GUARANTEED BETWEEN THEM**

## Download Links

Total Size Compressed: 3.7 MB

(.7z) [Dropbox](https://www.dropbox.com/s/6gb8tt3j7vkusyc/Sven-CS16_1-1.7z?dl=0)  
(.7z) [HLDM-BR.NET](https://cdn.hldm-br.net/files/sc/cs16/Sven-CS16_1-1.7z)  
(.7z) [Mega](https://mega.nz/file/q8FF2agB#M1Bmh3buwhCAi-xjQch_UuyGl9KS8zdFiMbKkc04XIw)  
(.7z) [Boderman.net](http://boderman.net/svencoop/Sven-CS16_1-1.7z)  
(.7z) [GitHub](https://github.com/KernCore91/-SC-Counter-Strike-1.6-Weapons-Project/releases/download/v1.1/Sven-CS16_1-1.7z)

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
[![](http://i3.ytimg.com/vi/zQuPdpmHvSY/maxresdefault.jpg)](https://www.youtube.com/watch?v=zQuPdpmHvSY)
*by VitorHunter.*

## Screenshots
[![](https://i.imgur.com/me4gGJCm.png)](https://i.imgur.com/me4gGJC.png)
[![](https://i.imgur.com/OQOFCwMm.png)](https://i.imgur.com/OQOFCwM.png)
[![](https://i.imgur.com/S32ZVIkm.png)](https://i.imgur.com/S32ZVIk.png)
[![](https://i.imgur.com/SV5ILyrm.png)](https://i.imgur.com/SV5ILyr.png)
[![](https://i.imgur.com/h3koWwmm.png)](https://i.imgur.com/h3koWwm.png)
[![](https://i.imgur.com/erqC809m.png)](https://i.imgur.com/erqC809.png)

## Installation Guide

1. Registering the weapons as plugins (Good for server operators, and most people):
	1. Download the pack from one of the download links below
	2. Extract it's contents inside **`Steam\steamapps\common\Sven Co-op\svencoop_addon\`**
	3. Open up *`default_plugins.txt`* located in **`Steam\steamapps\common\Sven Co-op\svencoop\`**
	4. Add these lines to the file:
	```
	"plugin"
	{
		"name"			"Counter-Strike 1.6 Mod"
		"script"		"../maps/cs16/cs16_register"
		"concommandns"	"cs16"
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

## Notes

This pack includes a *.fgd* file and a *.res* file (the .res file should not be needed).  
There are several notable differences here compared to the old project:  
* **Organization**: The project is more organized than ever before. This helps reduce the amount of clutter and resources sent to the player.  
* **Original Rifle Muzzleflashes**: With the knowledge obtained with past projects, we're able to bring you the original X shaped Muzzleflash for rifles back, without conflicting with the original game.  
* **Original HE Grenade Entity**: The HE Grenade projectile thrown by the player should behave closely to the original 1.6 projectile.  
* **Customization without modification of original scripts**: Similarly to the Insurgency Project, you're now able to modify most of the entity data, without modifying the original script, in your own map script.  
* **Original C4 Entity**: Thanks to Nero for making the original projectile, the code has been cleaned up a little bit and it allows for more customization.  
* **Original Scope for Sniper Rifles**: Thanks for D.N.I.O. 071 for making a custom scope viewmodel that fits very well with the original sprites used in 1.6.  
* **Fixed Player Models**: The original 1.6 player models were fixed to fit the Sven's Playermodel skeleton, no more aiming down.  
* **Buy Menu Similar to 1.6**: The menu has been redesigned to closely resemble the original Buy Menu, with the $ added as well, similarly to the Insurgency Project.  
* **Magazine Entities for Every Weapon**: Thanks for D.N.I.O. 071 for compiling the model which includes all magazines for all weapons, unfortunately this means the old magazine entities no longer exist, this was necessary in order to support dropping ammo for each weapon entity.  
* **Knife Backstabbing**: The original backstabbing functionality of the knife has been restored in this project.  

Shoutout for Solokiller for helping me initially in 2016 with this project.  

## Credits

You are authorized to use any assets in this pack as you see fit, as long as you credit us and whoever contributed to the making of this pack.  
There's a very long list of people/teams in the file: *cs16_credits.txt*, this file specifies the authors of every single asset that is being used in the making of this project.

### You are authorized to use any assets in this pack as you see fit, as long as:
* You credit everyone who contributed to it.

### You are not permitted to:
* Re-pack it without the project author's consent.
* Use any assets included in this project without crediting who made them.
* Earn money from this pack or any other assets used.
* Upload it somewhere else without credits.

## Updates

### Update 1.1:
* Fix player's speed not being affected when aiming with Sniper Rifles.
