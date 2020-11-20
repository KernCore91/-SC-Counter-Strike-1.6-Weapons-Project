//Melees
#include "melee/weapon_csknife"
//Pistols and Handguns
#include "pist/weapon_csglock18"
#include "pist/weapon_usp"
#include "pist/weapon_p228"
#include "pist/weapon_fiveseven"
#include "pist/weapon_dualelites"
//Shotguns
#include "shot/weapon_m3"
#include "shot/weapon_xm1014"
//Submachine guns
#include "smg/weapon_mac10"
#include "smg/weapon_tmp"
#include "smg/weapon_mp5navy"
#include "smg/weapon_ump45"
#include "smg/weapon_p90"
//Explosives and Equipment
#include "misc/weapon_hegrenade"
#include "misc/weapon_c4"
//Assault Rifles
#include "rifl/weapon_famas"
#include "rifl/weapon_galil"
#include "rifl/weapon_ak47"
#include "rifl/weapon_m4a1"
//Sniper Rifles
#include "snip/weapon_scout"
#include "snip/weapon_awp"
#include "snip/weapon_sg550"
#include "snip/weapon_g3sg1"
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
	CS16_57::Register();
	CS16_ELITES::Register();
	//Shotguns
	CS16_M3::Register();
	CS16_XM1014::Register();
	//Submachine guns
	CS16_MAC10::Register();
	CS16_TMP::Register();
	CS16_MP5::Register();
	CS16_UMP45::Register();
	CS16_P90::Register();
	//Explosives and Equipment
	CS16_HEGRENADE::Register();
	CS16_C4::Register();
	//Assault Rifles
	CS16_FAMAS::Register();
	CS16_GALIL::Register();
	CS16_AK47::Register();
	CS16_M4A1::Register();
	//Sniper Rifles
	CS16_SCOUT::Register();
	CS16_AWP::Register();
	CS16_SG550::Register();
	CS16_G3SG1::Register();
	//Light Machine Guns
	CS16_M249::Register();
}