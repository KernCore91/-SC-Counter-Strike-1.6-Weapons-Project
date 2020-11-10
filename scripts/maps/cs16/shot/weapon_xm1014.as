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
int MAX_CLIP    	= 7;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 15;
uint SLOT       	= 2;
uint POSITION   	= 4;
float RPM       	= 0.25f;
uint MAX_SHOOT_DIST	= 3048;
string AMMO_TYPE 	= "cs16_12gauge";
uint PELLETS    	= 6;
Vector CONE( 0.0675f, 0.0675f, 0 );

//Buy Menu Information
string WPN_NAME 	= "Leone YG1265 Auto Shotgun";
uint WPN_PRICE  	= 375;
string AMMO_NAME 	= "Leone 12G 7 Shell Box";
uint AMMO_PRICE  	= 15;

class weapon_xm1014 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private float m_flNextReload;
	private bool m_fShotgunReload = false;
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
		return Deploy( V_MODEL, P_MODEL, DRAW, "shotgun", GetBodygroup(), (30.0/30.0) );
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
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5f;

		self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 1 ), 0, GetBodygroup() );
		ShootWeapon( SHOOT_S, PELLETS, CONE, MAX_SHOOT_DIST, DAMAGE, DMG_LAUNCH );

		if( m_pPlayer.pev.flags & FL_ONGROUND != 0 )
			m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 1, 3, 5 );
		else
			m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 1, 7, 10 );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		ShellEject( m_pPlayer, m_iShell, Vector( 19, 12, -7 ), true, false, TE_BOUNCE_SHOTSHELL );
	}
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