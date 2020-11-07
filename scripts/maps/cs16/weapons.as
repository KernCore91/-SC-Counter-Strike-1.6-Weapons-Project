//Pistols and Handguns
#include "pist/weapon_csglock18"
//Shotguns
#include "shot/weapon_m3"
//Submachine guns
#include "smg/weapon_mac10"
//Assault Rifles
#include "rifl/weapon_famas"
//Sniper Rifles
#include "snip/weapon_scout"
//Light Machine Guns
#include "lmg/weapon_csm249"

void RegisterAll()
{
	//Pistols and Handguns
	CS16_GLOCK18::Register();
	//Shotguns
	CS16_M3::Register();
	//Submachine guns
	CS16_MAC10::Register();
	//Assault Rifles
	CS16_FAMAS::Register();
	//Sniper Rifles
	CS16_SCOUT::Register();
	//Light Machine Guns
	CS16_M249::Register();
}