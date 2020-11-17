// Counter-Strike 1.6 Maverick M4A1 Carbine
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

namespace CS16_M4A1
{

// Animations
enum CS16_M4a1_Animations
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	SHOOT3,
	RELOAD,
	DRAW,
	ADD_SILENCER,
	IDLE_UNSIL,
	SHOOT1_UNSIL,
	SHOOT2_UNSIL,
	SHOOT3_UNSIL,
	RELOAD_UNSIL,
	DRAW_UNSIL,
	DETACH_SILENCER
};

// Models
string W_MODEL  	= "models/cs16/wpn/m4a1/w_m4a1.mdl";
string V_MODEL  	= "models/cs16/wpn/m4a1/v_m4a1.mdl";
string P_MODEL  	= "models/cs16/wpn/m4a1/p_m4a1.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 16;
// Sprites
string SPR_CAT  	= "rifl/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/m4a1/magout.wav",
					"cs16/m4a1/magin.wav",
					"cs16/m4a1/bltbk.wav"
					"cs16/m4a1/draw.wav"
					"cs16/m4a1/siloff.wav"
					"cs16/m4a1/silon.wav"
};
string SHOOT_S  	= "cs16/m4a1/shoot.wav";
string SHOOT_S2 	= "cs16/m4a1/shoot2.wav";
// Information
int MAX_CARRY   	= 90;
int MAX_CLIP    	= 30;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 24;
uint DAMAGE2    	= 21;
uint SLOT       	= 5;
uint POSITION   	= 8;
float RPM       	= 0.0875f;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "cs16_5.56nato";

//Buy Menu Information
string WPN_NAME 	= "M4A1 Carbine";
uint WPN_PRICE  	= 375;
string AMMO_NAME 	= "M4A1 5.56 Magazine";
uint AMMO_PRICE  	= 30;

class weapon_m4a1 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
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
		WeaponSilMode = CS16BASE::MODE_SUP_OFF;
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
		self.pev.scale = 1.3;
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
		CS16BASE::PrecacheSound( SHOOT_S2 );
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
		return Deploy( V_MODEL, P_MODEL, (WeaponSilMode == CS16BASE::MODE_SUP_OFF) ? DRAW_UNSIL : DRAW, "m16", GetBodygroup(), (40.0/40.0) );
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
			self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
			return;
		}

		Vector vecSpread;

		if( WeaponFireMode == CS16BASE::MODE_SUP_OFF )
		{
			if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.35 * (0.4 + (m_iShotsFired * 0.2));
			}
			else if( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.35 * (0.07 + (m_iShotsFired * 0.125));
			}
			else
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.05;
			}
		}
		else
		{
			if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.35 * (0.4 + (m_iShotsFired * 0.2));
			}
			else if( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.35 * (0.07 + (m_iShotsFired * 0.125));
			}
			else
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.09;
			}
		}

		vecSpread = vecSpread * (m_iShotsFired * 0.2); // do vector math calculations here to make the Spread worse

		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;

		if( WeaponSilMode == CS16BASE::MODE_SUP_ON )
		{
			ShootWeapon( SHOOT_S2, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE2, DMG_GENERIC, true );
			self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 2 ), 0, GetBodygroup() );
		}
		else
		{
			ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );
			self.SendWeaponAnim( SHOOT1_UNSIL + Math.RandomLong( 0, 2 ), 0, GetBodygroup() );
		}

		m_pPlayer.m_iWeaponVolume = (WeaponSilMode == CS16BASE::MODE_SUP_OFF) ? NORMAL_GUN_VOLUME : 0;
		m_pPlayer.m_iWeaponFlash = (WeaponSilMode == CS16BASE::MODE_SUP_OFF) ? BRIGHT_GUN_FLASH : 0;

		if( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7 );
		}
		else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			KickBack( 1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6 );
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			KickBack( 0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7 );
		}
		else
		{
			KickBack( 0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7 );
		}

		ShellEject( m_pPlayer, m_iShell, Vector( 15, 10, -5 ), true, false );
	}

	void SecondaryAttack()
	{
		self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + (60.0/30.0);
		switch( WeaponSilMode )
		{
			case CS16BASE::MODE_SUP_OFF:
			{
				WeaponSilMode = CS16BASE::MODE_SUP_ON;
				self.SendWeaponAnim( ADD_SILENCER, 0, GetBodygroup() );
				break;
			}
			case CS16BASE::MODE_SUP_ON:
			{
				WeaponSilMode = CS16BASE::MODE_SUP_OFF;
				self.SendWeaponAnim( DETACH_SILENCER, 0, GetBodygroup() );
				break;
			}
		}
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		Reload( MAX_CLIP, (WeaponSilMode == CS16BASE::MODE_SUP_OFF) ? RELOAD_UNSIL : RELOAD, (113.0/37.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack + 0.1 < g_Engine.time ) // wait 0.1 seconds before reseting how many shots the player fired
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( (WeaponSilMode == CS16BASE::MODE_SUP_OFF) ? IDLE_UNSIL : IDLE, 0, GetBodygroup() );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class M4A1_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
{
	void Spawn()
	{
		Precache();

		CommonSpawn( A_MODEL, MAG_BDYGRP );
		self.pev.scale = 1.2;
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
	return "ammo_m4a1";
}

string GetName()
{
	return "weapon_m4a1";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_M4A1::", "weapon_m4a1", GetName(), GetAmmoName(), "M4A1_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_556 );
}

}