// Counter-Strike 1.6 Clarion 5.56 (GIAT FAMAS F1)
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve, burken, R4to0
/ Misc: Valve, D.N.I.O. 071 (Magazine Model Rip, Player Model Fix)
/ Script: KernCore
*/

namespace CS16_FAMAS
{

// Animations
enum CS16_Famas_Animations
{
	IDLE = 0,
	RELOAD,
	DRAW,
	SHOOT1,
	SHOOT2,
	SHOOT3
};

// Models
string W_MODEL  	= "models/cs16/wpn/famas/w_famas.mdl";
string V_MODEL  	= "models/cs16/wpn/famas/v_famas.mdl";
string P_MODEL  	= "models/cs16/wpn/famas/p_famas.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 3;
// Sprites
string SPR_CAT  	= "rifl/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/famas/magout.wav",
					"cs16/famas/magin.wav",
					"cs16/famas/bltbk.wav"
};
string SHOOT_S  	= "cs16/famas/shoot.wav";
// Information
int MAX_CARRY   	= 90;
int MAX_CLIP    	= 25;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 21;
uint SLOT       	= 5;
uint POSITION   	= 5;
float RPM_SINGLE 	= 0.0825;
float RPM_BURST  	= 0.05f;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "cs16_5.56nato";

//Buy Menu Information
string WPN_NAME 	= "GIAT FAMAS F1";
uint WPN_PRICE  	= 325;
string AMMO_NAME 	= "FAMAS 5.56 NATO Magazine";
uint AMMO_PRICE  	= 25;

class weapon_famas : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private int m_iBurstCount = 0, m_iBurstLeft = 0;
	private float m_flNextBurstFireTime = 0;
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
		self.pev.scale = 1;
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
		return Deploy( V_MODEL, P_MODEL, DRAW, "m16", GetBodygroup(), (30.0/35.0) );
	}

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CS16BASE::EMPTY_RIFLE_S );
	}

	void Holster( int skiplocal = 0 )
	{
		m_iBurstLeft = 0;
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	private void FireWeapon()
	{
		Vector vecSpread;
		if( WeaponFireMode == CS16BASE::MODE_BURST )
		{
			if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.33 * (0.125 + (m_iShotsFired * 0.2));
			}
			else if( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.13 * (0.07 + (m_iShotsFired * 0.125));
			}
			else
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.15;
			}
		}
		else
		{
			if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.31 * (0.12 + (m_iShotsFired * 0.2));
			}
			else if( m_pPlayer.pev.velocity.Length2D() > 140 )
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.12 * (0.07 + (m_iShotsFired * 0.125));
			}
			else
			{
				vecSpread = VECTOR_CONE_1DEGREES * 1.1;
			}
		}

		vecSpread = vecSpread * (m_iShotsFired * 0.195); // do vector math calculations here to make the Spread worse

		self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 2 ), 0, GetBodygroup() );

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		if( m_pPlayer.pev.velocity.Length2D() > 0 )
		{
			KickBack( 1.0, 0.45, 0.275, 0.05, 4.0, 2.5, 7 );
		}
		else if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			KickBack( 1.25, 0.45, 0.22, 0.18, 5.5, 4.0, 5 );
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			KickBack( 0.575, 0.325, 0.2, 0.011, 3.25, 2.0, 8 );
		}
		else
		{
			KickBack( 0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8 );
		}

		ShellEject( m_pPlayer, m_iShell, Vector( 14, 15, -12 ), false, false );
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 || m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		if( WeaponFireMode == CS16BASE::MODE_BURST )
		{
			//Fire at most 3 bullets.
			m_iBurstCount = Math.min( 3, self.m_iClip );
			m_iBurstLeft = m_iBurstCount - 1;

			m_flNextBurstFireTime = WeaponTimeBase() + RPM_BURST;
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.55f;
		}
		else
		{
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + RPM_SINGLE;
		}

		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;
		FireWeapon();
	}

	void ItemPostFrame()
	{
		if( WeaponFireMode == CS16BASE::MODE_BURST )
		{
			if( m_iBurstLeft > 0 )
			{
				if( m_flNextBurstFireTime < WeaponTimeBase() )
				{
					if( self.m_iClip <= 0 )
					{
						m_iBurstLeft = 0;
						return;
					}
					else
						--m_iBurstLeft;

					FireWeapon();

					if( m_iBurstLeft > 0 )
						m_flNextBurstFireTime = WeaponTimeBase() + RPM_BURST;
					else
						m_flNextBurstFireTime = 0;
				}

				//While firing a burst, don't allow reload or any other weapon actions. Might be best to let some things run though.
				return;
			}
		}

		BaseClass.ItemPostFrame();
	}

	void SecondaryAttack()
	{
		switch( WeaponFireMode )
		{
			case CS16BASE::MODE_NORMAL:
			{
				WeaponFireMode = CS16BASE::MODE_BURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, " Switched to Burst Fire \n" );
				break;
			}
			case CS16BASE::MODE_BURST:
			{
				WeaponFireMode = CS16BASE::MODE_NORMAL;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, " Switched to Full Auto \n" );
				break;
			}
		}
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		Reload( MAX_CLIP, RELOAD, (90.0/30.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{	
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack < g_Engine.time )
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class FAMAS_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
{
	void Spawn()
	{
		Precache();

		CommonSpawn( A_MODEL, MAG_BDYGRP );
		self.pev.scale = 1.1;
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
	return "ammo_famas";
}

string GetName()
{
	return "weapon_famas";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_FAMAS::", "weapon_famas", GetName(), GetAmmoName(), "FAMAS_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_556 );
}

}