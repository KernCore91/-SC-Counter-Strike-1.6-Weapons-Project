// Counter-Strike 1.6 Leone 12 Gauge Super
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

namespace CS16_M3
{

// Animations
enum CS16_M3_Animations
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
string W_MODEL  	= "models/cs16/wpn/m3/w_m3.mdl";
string V_MODEL  	= "models/cs16/wpn/m3/v_m3.mdl";
string P_MODEL  	= "models/cs16/wpn/m3/p_m3.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 0;
// Sprites
string SPR_CAT  	= "shot/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/m3_pump.wav",
					"cs16/m3_insertshell.wav"
};
string SHOOT_S  	= "cs16/m3-1.wav";
// Information
int MAX_CARRY   	= 32;
int MAX_CLIP    	= 8;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 8;
uint SLOT       	= 2;
uint POSITION   	= 10;
float RPM_PUMP1 	= 0.1f;
float RPM_PUMP2 	= 0.05f;
string AMMO_TYPE 	= "cs16_12gauge";
uint PELLETS    	= 9;

class weapon_m3 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private float m_flNextReload;
	private bool m_fShotgunReload;
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		//Models
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		g_Game.PrecacheModel( A_MODEL );
		m_iShell = g_Game.PrecacheModel( CS16BASE::SHELL_SHOTGUN );
		//Entity
		g_Game.PrecacheOther( GetAmmoName() );
		//Sounds
		CS16BASE::PrecacheSound( SHOOT_S );
		CS16BASE::PrecacheSound( CS16BASE::EMPTY_RIFLE_S );
		CS16BASE::PrecacheSounds( WeaponSoundEvents );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CS16BASE::MAIN_SPRITE_DIR + CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_BUCK;
		info.iAmmo1Drop	= MAX_CLIP;
		info.iMaxAmmo2 	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip 	= MAX_CLIP;
		info.iSlot  	= SLOT;
		info.iPosition 	= POSITION;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= FLAGS;
		info.iWeight 	= WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		return Deploy( V_MODEL, P_MODEL, DRAW, "onehanded", GetBodygroup(), (30.0/30.0) );
	}

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CS16BASE::EMPTY_RIFLE_S );
	}

	void Holster( int skiplocal = 0 )
	{
		m_fShotgunReload = false;
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{

	}

	void ItemPostFrame()
	{
		BaseClass.ItemPostFrame();
	}

	void Reload()
	{

	}

	void WeaponIdle()
	{

	}
}

class CSM3_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
{
	void Spawn()
	{
		Precache();

		CommonSpawn( A_MODEL, MAG_BDYGRP );
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
	return "ammo_m3";
}

string GetName()
{
	return "weapon_m3";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_M3::", "weapon_m3", GetName(), GetAmmoName(), "CSM3_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_BUCK );
}

}