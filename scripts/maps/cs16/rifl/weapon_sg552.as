// Counter-Strike 1.6 Krieg 552 (SIG SG 552)
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve, R4to0
/ Misc: Valve, D.N.I.O. 071 (Magazine Model Rip, Player Model Fix)
/ Script: KernCore
*/

namespace CS16_SG552
{

// Animations
enum CS16_Sg552_Animations
{
	IDLE = 0,
	RELOAD,
	DRAW,
	SHOOT1,
	SHOOT2,
	SHOOT3
};

// Models
string W_MODEL  	= "models/cs16/wpn/sg552/w_sg552.mdl";
string V_MODEL  	= "models/cs16/wpn/sg552/v_sg552.mdl";
string P_MODEL  	= "models/cs16/wpn/sg552/p_sg552.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 22;
// Sprites
string SPR_CAT  	= "rifl/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/sg552/bltbk.wav",
					"cs16/sg552/magin.wav",
					"cs16/sg552/magout.wav"
};
string SHOOT_S  	= "cs16/sg552/shoot.wav";
// Information
int MAX_CARRY   	= 90;
int MAX_CLIP    	= 30;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 26;
uint SLOT       	= 5;
uint POSITION   	= 10;
float RPM       	= 0.0825f;
float RPM_ZOOMED 	= 0.135f;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "cs16_5.56nato";
float AIM_SPEED 	= 270;

//Buy Menu Information
string WPN_NAME 	= "SIG SG 552";
uint WPN_PRICE  	= 420;
string AMMO_NAME 	= "SG 552 5.56 Magazine";
uint AMMO_PRICE  	= 30;

class weapon_sg552 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
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
		return Deploy( V_MODEL, P_MODEL, DRAW, "m16", GetBodygroup(), (37.0/37.0) );
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
			vecSpread = VECTOR_CONE_1DEGREES * 1.035f * (0.075f + (m_iShotsFired * 0.2f));
		}
		else if( m_pPlayer.pev.velocity.Length2D() > 140 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.035f * (0.045f + (m_iShotsFired * 0.12f));
		}
		else
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.02f;
		}

		vecSpread = vecSpread * (m_iShotsFired * 0.2f); // do vector math calculations here to make the Spread worse

		self.m_flNextPrimaryAttack = (WeaponZoomMode != CS16BASE::MODE_FOV_NORMAL) ? WeaponTimeBase() + RPM_ZOOMED : WeaponTimeBase() + RPM;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5f;

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );
		self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 2 ), 0, GetBodygroup() );

		if( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.0, 0.45, 0.28, 0.04, 4.25, 2.5, 7 );
		}
		else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			KickBack( 1.25, 0.45, 0.22, 0.18, 6.0, 4.0, 5 );
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			KickBack( 0.6, 0.35, 0.2, 0.0125, 3.7, 2.0, 10 );
		}
		else
		{
			KickBack( 0.625, 0.375, 0.25, 0.0125, 4.0, 2.25, 9 );
		}

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		ShellEject( m_pPlayer, m_iShell, Vector( 18, 13, -5 ), true, false );
	}

	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;

		switch( WeaponZoomMode )
		{
			case CS16BASE::MODE_FOV_NORMAL:
			{
				WeaponZoomMode = CS16BASE::MODE_FOV_ZOOM;

				ApplyFoVSniper( CS16BASE::DEFAULT_AUG_SG_ZOOM, AIM_SPEED, "m16", false );
				break;
			}
			case CS16BASE::MODE_FOV_ZOOM:
			{
				WeaponZoomMode = CS16BASE::MODE_FOV_NORMAL;

				ResetFoV( "m16" );
				break;
			}
		}
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		if( WeaponZoomMode != CS16BASE::MODE_FOV_NORMAL )
		{
			WeaponZoomMode = CS16BASE::MODE_FOV_NORMAL;
			ResetFoV( "m16" );
		}

		Reload( MAX_CLIP, RELOAD, (118.0/37.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack + 0.1f < g_Engine.time )
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( IDLE, 0, GetBodygroup() );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class SG552_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
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
	return "ammo_sg552";
}

string GetName()
{
	return "weapon_sg552";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_SG552::", "weapon_sg552", GetName(), GetAmmoName(), "SG552_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_556 );
}

}