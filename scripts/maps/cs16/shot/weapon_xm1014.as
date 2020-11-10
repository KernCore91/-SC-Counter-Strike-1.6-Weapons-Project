//Counter-Strike 1.6 Leone YG1265 Auto Shotgun (XM-1014)
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve
/ Misc: Valve, D.N.I.O. 071 (Player Model Fix)
/ Script: KernCore
*/

#include "../base"

namespace CS16_XM1014
{

// Animations
enum CS16_Xm1014_Animations
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	INSERT,
	AFTER_RELOAD,
	START_RELOAD,
	DRAW
};

// Models
string W_MODEL  	= "models/cs16/wpn/xm1014/w_xm1014.mdl";
string V_MODEL  	= "models/cs16/wpn/xm1014/v_xm1014.mdl";
string P_MODEL  	= "models/cs16/wpn/xm1014/p_xm1014.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 1;
// Sprites
string SPR_CAT  	= "shot/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/m3/pump.wav",
					"cs16/m3/shell.wav"
};
string SHOOT_S  	= "cs16/xm1014/shoot.wav";
// Information
int MAX_CARRY   	= 32;
int MAX_CLIP    	= 8;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 9;
uint SLOT       	= 2;
uint POSITION   	= 4;
float RPM_PUMP  	= 0.875f;
uint MAX_SHOOT_DIST	= 3000;
string AMMO_TYPE 	= "cs16_12gauge";
uint PELLETS    	= 9;
Vector CONE( 0.0675f, 0.0675f, 0 );

//Buy Menu Information
string WPN_NAME 	= "Leone YG1265 Auto Shotgun";
uint WPN_PRICE  	= 330;
string AMMO_NAME 	= "Leone 12G 7 Shell Box";
uint AMMO_PRICE  	= 15;

class weapon_xm1014 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{

}

class CSXM1014_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
{
	void Spawn()
	{
		Precache();

		CommonSpawn( A_MODEL, MAG_BDYGRP );
		self.pev.scale = 0.7;
	}

	void Precache()
	{
		//Models
		g_Game.PrecacheModel( A_MODEL );
		//Sounds
		CommonPrecache();
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		return CommonAddAmmo( pOther, MAX_CLIP, (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_BUCK, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_BUCK );
	}
}

string GetAmmoName()
{
	return "ammo_xm1014";
}

string GetName()
{
	return "weapon_xm1014";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_XM1014::", "weapon_xm1014", GetName(), GetAmmoName(), "CSXM1014_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_BUCK );
}

}