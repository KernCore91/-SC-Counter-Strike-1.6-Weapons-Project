//Pistols and Handguns
#include "pist/weapon_csglock18"
//Shotguns
#include "shot/weapon_m3"
//Submachine guns
#include "smg/weapon_mac10"

void RegisterAll()
{
	//Pistols and Handguns
	CS16_GLOCK18::Register();
	//Shotguns
	CS16_M3::Register();
	//Submachine guns
	CS16_MAC10::Register();
}