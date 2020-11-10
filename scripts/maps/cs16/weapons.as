//Melees
#include "melee/weapon_csknife"
//Pistols and Handguns
#include "pist/weapon_csglock18"
#include "pist/weapon_usp"
//Shotguns
#include "shot/weapon_m3"
#include "shot/weapon_xm1014"
//Submachine guns
#include "smg/weapon_mac10"
#include "smg/weapon_tmp"
//Explosives and Equipment
#include "misc/weapon_hegrenade"
//Assault Rifles
#include "rifl/weapon_famas"
//Sniper Rifles
#include "snip/weapon_scout"
//Light Machine Guns
#include "lmg/weapon_csm249"

void RegisterAll()
{
	//Melees
	CS16_KNIFE::Register();
	//Pistols and Handguns
	CS16_GLOCK18::Register();
	CS16_USP::Register();
	//Shotguns
	CS16_M3::Register();
	CS16_XM1014::Register();
	//Submachine guns
	CS16_MAC10::Register();
	CS16_TMP::Register();
	//Explosives and Equipment
	CS16_HEGRENADE::Register();
	//Assault Rifles
	CS16_FAMAS::Register();
	//Sniper Rifles
	CS16_SCOUT::Register();
	//Light Machine Guns
	CS16_M249::Register();
}