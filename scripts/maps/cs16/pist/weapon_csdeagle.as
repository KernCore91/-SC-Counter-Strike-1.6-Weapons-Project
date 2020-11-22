// Counter-Strike 1.6 Night Hawk .50C (IMI Desert Eagle Mark XIX)
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve, R4to0
/ Misc: Valve, D.N.I.O. 071 (Magazine Model Rip, Player Model Fix)
/ Script: KernCore
*/

#include "../base"

namespace CS16_DEAGLE
{

// Animations
enum CS16_Deagle_Animation
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	EMPTY,
	RELOAD,
	DRAW
};

// Models
string W_MODEL  	= "models/cs16/wpn/eagle/w_eagle.mdl";
string V_MODEL  	= "models/cs16/wpn/eagle/v_eagle.mdl";
string P_MODEL  	= "models/cs16/wpn/eagle/p_eagle.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 21;
// Sprites
string SPR_CAT  	= "pist/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/eagle/magin.wav",
					"cs16/eagle/magout.wav",
					"cs16/eagle/sldbk.wav",
					"cs16/eagle/sldrl.wav"
};
string SHOOT_S  	= "cs16/eagle/shoot.wav";
// Information
int MAX_CARRY   	= 35;
int MAX_CLIP    	= 7;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 39;
uint SLOT       	= 1;
uint POSITION   	= 9;
float RPM       	= 0.145f;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "cs16_.50ae";

//Buy Menu Information
string WPN_NAME 	= "Desert Eagle";
uint WPN_PRICE  	= 215;
string AMMO_NAME 	= "Desert Eagle .50AE Magazine";
uint AMMO_PRICE  	= 15;

class weapon_csdeagle : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
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
		m_iShell = g_Game.PrecacheModel( CS16BASE::SHELL_PISTOL );
		//Entity
		g_Game.PrecacheOther( GetAmmoName() );
		//Sounds
		CS16BASE::PrecacheSound( SHOOT_S );
		CS16BASE::PrecacheSound( CS16BASE::EMPTY_PISTOL_S );
		CS16BASE::PrecacheSounds( WeaponSoundEvents );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CS16BASE::MAIN_SPRITE_DIR + CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_357;
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
		return CommonPlayEmptySound( CS16BASE::EMPTY_PISTOL_S );
	}

	void Holster( int skiplocal = 0 )
	{
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}
}

class DEAGLE_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
{
	void Spawn()
	{
		Precache();

		CommonSpawn( A_MODEL, MAG_BDYGRP );
		self.pev.scale = 1;
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_357, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_357 );
	}
}

string GetAmmoName()
{
	return "ammo_csdeagle";
}

string GetName()
{
	return "weapon_csdeagle";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_DEAGLE::", "weapon_csdeagle", GetName(), GetAmmoName(), "DEAGLE_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_357 );
}

}