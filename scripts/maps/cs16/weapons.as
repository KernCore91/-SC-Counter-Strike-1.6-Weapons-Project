//Melees
#include "melee/weapon_csknife"
//Pistols and Handguns
#include "pist/weapon_csglock18"
#include "pist/weapon_usp"
#include "pist/weapon_p228"
//Shotguns
#include "shot/weapon_m3"
#include "shot/weapon_xm1014"
//Submachine guns
#include "smg/weapon_mac10"
#include "smg/weapon_tmp"
#include "smg/weapon_mp5navy"
//Explosives and Equipment
#include "misc/weapon_hegrenade"
#include "misc/weapon_c4"
//Assault Rifles
#include "rifl/weapon_famas"
#include "rifl/weapon_galil"
//Sniper Rifles
#include "snip/weapon_scout"
#include "snip/weapon_awp"
//Light Machine Guns
#include "lmg/weapon_csm249"

void RegisterAll()
{
	//Melees
	CS16_KNIFE::Register();
	//Pistols and Handguns
	CS16_GLOCK18::Register();
	CS16_USP::Register();
	CS16_P228::Register();
	//Shotguns
	CS16_M3::Register();
	CS16_XM1014::Register();
	//Submachine guns
	CS16_MAC10::Register();
	CS16_TMP::Register();
	CS16_MP5::Register();
	//Explosives and Equipment
	CS16_HEGRENADE::Register();
	CS16_C4::Register();
	//Assault Rifles
	CS16_FAMAS::Register();
	CS16_GALIL::Register();
	//Sniper Rifles
	CS16_SCOUT::Register();
	CS16_AWP::Register();
	//Light Machine Guns
	CS16_M249::Register();
}