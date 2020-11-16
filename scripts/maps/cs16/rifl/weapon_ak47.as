// Counter-Strike 1.6 CV-47 (AK-47)
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve, R4to0
/ Misc: Valve, D.N.I.O. 071 (Magazine Model Rip, Player Model Fix)
/ Script: KernCore
*/

namespace CS16_AK47
{

// Animations
enum CS16_Ak47_Animations
{
	IDLE = 0,
	RELOAD,
	DRAW,
	SHOOT1,
	SHOOT2,
	SHOOT3
};

// Models
string W_MODEL  	= "models/cs16/wpn/ak47/w_ak47.mdl";
string V_MODEL  	= "models/cs16/wpn/ak47/v_ak47.mdl";
string P_MODEL  	= "models/cs16/wpn/ak47/p_ak47.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 12;
// Sprites
string SPR_CAT  	= "rifl/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/ak47/magout.wav",
					"cs16/ak47/magin.wav",
					"cs16/ak47/bltbk.wav"
};
string SHOOT_S  	= "cs16/ak47/shoot.wav";
// Information
int MAX_CARRY   	= 90;
int MAX_CLIP    	= 30;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 27;
uint SLOT       	= 5;
uint POSITION   	= 7;
float RPM       	= 0.0955f;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "cs16_7.62nato";

//Buy Menu Information
string WPN_NAME 	= "AK-47";
uint WPN_PRICE  	= 365;
string AMMO_NAME 	= "AK-47 7.62 Magazine";
uint AMMO_PRICE  	= 35;

class weapon_ak47 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
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
		self.pev.scale = 1.2;
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		//Models
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		g_Game.PrecacheModel( A_MODEL );
		m_iShell = g_Game.PrecacheModel( CS16BASE::SHELL_RIFLE );
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
		info.iMaxAmmo1 	= (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_556;
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
		return Deploy( V_MODEL, P_MODEL, DRAW, "m16", GetBodygroup(), (30.0/30.0) );
	}

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CS16BASE::EMPTY_RIFLE_S );
	}

	void Holster( int skiplocal = 0 )
	{
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 || m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		Vector vecSpread;

		if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.04f * (0.07f + (m_iShotsFired * 0.21f));
		}
		else if( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.04f * (0.04f + (m_iShotsFired * 0.135f));
		}
		else
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.0275f;
		}

		vecSpread = vecSpread * (m_iShotsFired * 0.225f); // do vector math calculations here to make the Spread worse

		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5f;

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );
		self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 2 ), 0, GetBodygroup() );

		if( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.5, 0.45, 0.225, 0.05, 6.5, 2.5, 7 );
		}
		else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			KickBack( 2.0, 1.0, 0.5, 0.35, 9.0, 6.0, 5 );
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			KickBack( 0.9, 0.35, 0.15, 0.025, 5.5, 1.5, 9 );
		}
		else
		{
			KickBack( 1.0, 0.375, 0.175, 0.0375, 5.75, 1.75, 8 );
		}

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		ShellEject( m_pPlayer, m_iShell, Vector( 21, 12, -9 ), true, false );
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		Reload( MAX_CLIP, RELOAD, (90.0/37.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{	
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack + 0.1 < g_Engine.time )
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class AK47_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_556, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_556 );
	}
}

string GetAmmoName()
{
	return "ammo_ak47";
}

string GetName()
{
	return "weapon_ak47";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_AK47::", "weapon_ak47", GetName(), GetAmmoName(), "AK47_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_556 );
}

}