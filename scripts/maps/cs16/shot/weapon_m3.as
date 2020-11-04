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
int MAG_BDYGRP  	= 1;
// Sprites
string SPR_CAT  	= "shot/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/m3/pump.wav",
					"cs16/m3/shell.wav"
};
string SHOOT_S  	= "cs16/m3/shoot.wav";
// Information
int MAX_CARRY   	= 32;
int MAX_CLIP    	= 8;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 8;
uint SLOT       	= 2;
uint POSITION   	= 10;
float RPM_PUMP  	= 0.875f;
uint MAX_SHOOT_DIST	= 3000;
string AMMO_TYPE 	= "cs16_12gauge";
uint PELLETS    	= 9;
Vector CONE( 0.0675f, 0.0675f, 0 );

class weapon_m3 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
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
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM_PUMP;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5f;

		self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 1 ), 0, GetBodygroup() );
		ShootWeapon( SHOOT_S, PELLETS, CONE, MAX_SHOOT_DIST, DAMAGE );

		if( m_pPlayer.pev.flags & FL_ONGROUND != 0 )
			m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 1, 4, 6 );
		else
			m_pPlayer.pev.punchangle.x -= g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed + 1, 8, 11 );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		SetThink( ThinkFunction( this.EjectBrassThink ) );
		self.pev.nextthink = g_Engine.time + 0.45f;
	}

	void EjectBrassThink()
	{
		SetThink( null );

		ShellEject( m_pPlayer, m_iShell, Vector( 21, 15, -8.5f ), true, false, TE_BOUNCE_SHOTSHELL );
	}

	void ItemPostFrame()
	{
		if( m_pPlayer.pev.button & IN_ATTACK != 0 && m_fShotgunReload && m_flNextReload <= g_Engine.time && self.m_iClip != 0 )
		{
			self.m_flTimeWeaponIdle = g_Engine.time + m_flNextReload;
			m_fShotgunReload = false;
		}
		BaseClass.ItemPostFrame();
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == MAX_CLIP )
			return;

		if( m_flNextReload > WeaponTimeBase() )
			return;

		// don't reload until recoil is done
		if( self.m_flNextPrimaryAttack > WeaponTimeBase() && !m_fShotgunReload )
			return;

		// check to see if we're ready to reload
		if( !m_fShotgunReload )
		{
			self.SendWeaponAnim( START_RELOAD, 0, GetBodygroup() );

			m_pPlayer.m_flNextAttack = (15.0/30.0); //Always uses a relative time due to prediction
			self.m_flTimeWeaponIdle = WeaponTimeBase() + (15.0/30.0);
			m_flNextReload = self.m_flNextPrimaryAttack = WeaponTimeBase() + (15.0/30.0);

			m_fShotgunReload = true;
			return;
		}
		else if( m_fShotgunReload )
		{
			if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
				return;

			if( self.m_iClip == MAX_CLIP )
			{
				m_fShotgunReload = false;
				return;
			}

			self.SendWeaponAnim( INSERT, 0, GetBodygroup() );
			m_flNextReload = self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = WeaponTimeBase() + (27.0/60.0);

			// Add them to the clip
			self.m_iClip += 1;
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
		}
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle < g_Engine.time )
		{
			if( self.m_iClip <= 0 && !m_fShotgunReload && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) != 0 )
			{
				self.Reload();
			}
			else if( m_fShotgunReload )
			{
				if( self.m_iClip != MAX_CLIP && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
				{
					self.Reload();
				}
				else
				{
					// reload debounce has timed out
					self.SendWeaponAnim( AFTER_RELOAD, 0, GetBodygroup() );

					m_fShotgunReload = false;
					self.m_flTimeWeaponIdle = g_Engine.time + 1.5f;
				}
			}
			else
			{
				self.SendWeaponAnim( IDLE, 0, GetBodygroup() );
				self.m_flTimeWeaponIdle = WeaponTimeBase() + (10.0/12.0);
			}
		}
	}
}

class CSM3_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
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