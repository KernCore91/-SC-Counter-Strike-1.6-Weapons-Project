// Counter-Strike 1.6 ES Five-SeveN (FN Five-seven)
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

namespace CS16_57
{

// Animations
enum CS16_57_Animations
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	SHOOT_EMPTY,
	RELOAD,
	DRAW
};

// Models
string W_MODEL  	= "models/cs16/wpn/57/w_57.mdl";
string V_MODEL  	= "models/cs16/wpn/57/v_57.mdl";
string P_MODEL  	= "models/cs16/wpn/57/p_57.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 10;
// Sprites
string SPR_CAT  	= "pist/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/57/magin.wav",
					"cs16/57/magout.wav",
					"cs16/57/sldbk.wav",
					"cs16/57/sldrl.wav"
};
string SHOOT_S  	= "cs16/57/shoot.wav";
// Information
int MAX_CARRY   	= 100;
int MAX_CLIP    	= 20;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 17;
uint SLOT       	= 1;
uint POSITION   	= 7;
float RPM       	= 0.14f;
uint MAX_SHOOT_DIST	= 4096;
string AMMO_TYPE 	= "cs16_5.7mm";

//Buy Menu Information
string WPN_NAME 	= "FN Five-Seven";
uint WPN_PRICE  	= 185;
string AMMO_NAME 	= "Five-Seven Magazine";
uint AMMO_PRICE  	= 25;

class weapon_fiveseven : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
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
		info.iMaxAmmo1 	= (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_9MM;
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

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
			return;
		}

		if( m_pPlayer.m_afButtonPressed & IN_ATTACK == 0 )
			return;

		Vector vecSpread;

		if( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.255f;
		}
		else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			vecSpread = VECTOR_CONE_2DEGREES * 1.5f;
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.075f;
		}
		else
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.15f;
		}

		vecSpread = vecSpread * (m_iShotsFired * 0.2); // do vector math calculations here to make the Spread worse

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE, DMG_SNIPER | DMG_NEVERGIB );
		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
		
		if( self.m_iClip > 0 )
		{
			self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 1 ), 0, GetBodygroup() );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;
		}
		else
		{
			self.SendWeaponAnim( SHOOT_EMPTY, 0, GetBodygroup() );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 20.0f;
		}

		m_pPlayer.m_iWeaponVolume = BIG_EXPLOSION_VOLUME;
		m_pPlayer.m_iWeaponFlash = DIM_GUN_FLASH;

		m_pPlayer.pev.punchangle.x -= 2;

		ShellEject( m_pPlayer, m_iShell, Vector( 15, 8, -6 ), true, false );
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		Reload( MAX_CLIP, RELOAD, (96.0/30.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack + 0.2 < g_Engine.time ) // wait 0.2 seconds before reseting how many shots the player fired
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( IDLE, 0, GetBodygroup() );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class FIVE7_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_9MM, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_9MM );
	}
}

string GetAmmoName()
{
	return "ammo_fiveseven";
}

string GetName()
{
	return "weapon_fiveseven";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_57::", "weapon_fiveseven", GetName(), GetAmmoName(), "FIVE7_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_9MM );
}

}