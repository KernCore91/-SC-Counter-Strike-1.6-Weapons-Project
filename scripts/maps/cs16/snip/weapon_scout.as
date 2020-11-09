// Counter-Strike 1.6 Steyr Scout
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve
/ Misc: Valve, D.N.I.O. 071 (Magazine Model Rip, Player Model Fix)
/ Script: KernCore
*/

namespace CS16_SCOUT
{

// Animations
enum CS16_Scout_Animations
{
	IDLE = 0,
	SHOOT1,
	SHOOT2,
	RELOAD,
	DRAW
};

// Models
string W_MODEL  	= "models/cs16/wpn/scout/w_scout.mdl";
string V_MODEL  	= "models/cs16/wpn/scout/v_scout.mdl";
string P_MODEL  	= "models/cs16/wpn/scout/p_scout.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 4;
// Sprites
string SPR_CAT  	= "snip/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/scout/blt.wav",
					"cs16/scout/magout.wav",
					"cs16/scout/magin.wav"
};
string SHOOT_S  	= "cs16/scout/shoot.wav";
// Information
int MAX_CARRY   	= 90;
int MAX_CLIP    	= 10;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 56;
uint SLOT       	= 6;
uint POSITION   	= 4;
uint MAX_SHOOT_DIST	= 8192;
float RPM       	= 1.25f;
string AMMO_TYPE 	= "cs16_7.62x39mm";
float AIM_SPEED 	= 220;

class weapon_scout : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int m_iShell;
	private CScheduledFunction@ CSRemoveBullet = null; //2 think functions can't work at the same time on the same object
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();
		CommonSpawn( W_MODEL, DEFAULT_GIVE );
		self.pev.scale = 1.15;
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		//Models
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		g_Game.PrecacheModel( CS16BASE::SCOPE_MODEL );
		g_Game.PrecacheModel( A_MODEL );
		m_iShell = g_Game.PrecacheModel( CS16BASE::SHELL_SNIPER );
		//Entity
		g_Game.PrecacheOther( GetAmmoName() );
		//Sounds
		CS16BASE::PrecacheSound( SHOOT_S );
		CS16BASE::PrecacheSound( CS16BASE::ZOOM_SOUND );
		CS16BASE::PrecacheSound( CS16BASE::EMPTY_RIFLE_S );
		CS16BASE::PrecacheSounds( WeaponSoundEvents );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CS16BASE::MAIN_SPRITE_DIR + CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_M40A1;
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

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CS16BASE::EMPTY_RIFLE_S );
	}

	bool Deploy()
	{
		return Deploy( V_MODEL, P_MODEL, DRAW, "sniper", GetBodygroup(), (30.0/30.0) );
	}

	void Holster( int skiplocal = 0 )
	{
		g_Scheduler.RemoveTimer( CSRemoveBullet );
		@CSRemoveBullet = @null;

		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	void ReApplyFoVThink()
	{
		SetThink( null );

		if( self.m_iClip <= 0 || WeaponZoomMode == CS16BASE::MODE_FOV_NORMAL )
			return;

		m_pPlayer.pev.viewmodel = CS16BASE::SCOPE_MODEL;

		if( WeaponZoomMode == CS16BASE::MODE_FOV_ZOOM )
		{
			ApplyFoVSniper( CS16BASE::DEFAULT_ZOOM_VALUE, AIM_SPEED );
			self.SendWeaponAnim( CS16BASE::SCP_IDLE_FOV40, 0, GetBodygroup() );
		}
		else if( WeaponZoomMode == CS16BASE::MODE_FOV_2X_ZOOM )
		{
			ApplyFoVSniper( CS16BASE::DEFAULT_2X_ZOOM_VALUE, AIM_SPEED );
			self.SendWeaponAnim( CS16BASE::SCP_IDLE_FOV15, 0, GetBodygroup() );
		}
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		Vector vecSpread;

		if( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
		{
			vecSpread = VECTOR_CONE_4DEGREES * 2.2f * (m_iShotsFired * 0.75f);
		}
		else if( m_pPlayer.pev.velocity.Length2D() > 170 )
		{
			vecSpread = VECTOR_CONE_1DEGREES * 2.075f * (m_iShotsFired * 0.45f);
		}
		else if( m_pPlayer.pev.flags & FL_DUCKING != 0 )
		{
			vecSpread = VECTOR_CONE_1DEGREES;
		}
		else
		{
			vecSpread = VECTOR_CONE_1DEGREES * 1.07f * (m_iShotsFired * 0.4f);
		}

		vecSpread = (WeaponZoomMode != CS16BASE::MODE_FOV_NORMAL) ? vecSpread * (m_iShotsFired * 0.225f) : vecSpread * (m_iShotsFired * 0.15f);

		if( WeaponZoomMode != CS16BASE::MODE_FOV_NORMAL && self.m_iClip > 0 )
		{
			SetThink( null );

			m_pPlayer.pev.viewmodel = V_MODEL;
			ResetFoV();
			SetThink( ThinkFunction( this.ReApplyFoVThink ) );
			self.pev.nextthink = g_Engine.time + (45.0/35.0);
		}

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE, DMG_SNIPER );
		self.SendWeaponAnim( SHOOT1 + Math.RandomLong( 0, 1 ), 0, GetBodygroup() );

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + RPM;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0f;

		m_pPlayer.m_iWeaponVolume = BIG_EXPLOSION_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		m_pPlayer.pev.punchangle.x -= 2;

		@CSRemoveBullet = @g_Scheduler.SetTimeout( @this, "BrassEjectThink", 0.56f );
	}

	void BrassEjectThink()
	{
		g_Scheduler.RemoveTimer( CSRemoveBullet );
		@CSRemoveBullet = @null;
		ShellEject( m_pPlayer, m_iShell, Vector( 13, 9, -8 ), true, false );
	}

	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, CS16BASE::ZOOM_SOUND, 0.9, ATTN_NORM, 0, PITCH_NORM );

		switch( WeaponZoomMode )
		{
			case CS16BASE::MODE_FOV_NORMAL:
			{
				WeaponZoomMode = CS16BASE::MODE_FOV_ZOOM;

				ApplyFoVSniper( CS16BASE::DEFAULT_ZOOM_VALUE, AIM_SPEED );

				m_pPlayer.pev.viewmodel = CS16BASE::SCOPE_MODEL;
				self.SendWeaponAnim( CS16BASE::SCP_IDLE_FOV40, 0, GetBodygroup() );
				break;
			}
			case CS16BASE::MODE_FOV_ZOOM:
			{
				WeaponZoomMode = CS16BASE::MODE_FOV_2X_ZOOM;

				ApplyFoVSniper( CS16BASE::DEFAULT_2X_ZOOM_VALUE, AIM_SPEED );

				m_pPlayer.pev.viewmodel = CS16BASE::SCOPE_MODEL;
				self.SendWeaponAnim( CS16BASE::SCP_IDLE_FOV15, 0, GetBodygroup() );
				break;
			}
			case CS16BASE::MODE_FOV_2X_ZOOM:
			{
				WeaponZoomMode = CS16BASE::MODE_FOV_NORMAL;

				m_pPlayer.pev.viewmodel = V_MODEL;
				self.SendWeaponAnim( IDLE, 0, GetBodygroup() );
				ResetFoV();
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
			m_pPlayer.pev.viewmodel = V_MODEL;
			ResetFoV();
		}

		Reload( MAX_CLIP, RELOAD, (60.0/30.0), GetBodygroup() );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flNextPrimaryAttack + 1.0f < g_Engine.time )
			m_iShotsFired = 0;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( WeaponZoomMode == CS16BASE::MODE_FOV_NORMAL )
			self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class SCOUT_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_M40A1, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_M40A1 );
	}
}

string GetAmmoName()
{
	return "ammo_scout";
}

string GetName()
{
	return "weapon_scout";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_SCOUT::", "weapon_scout", GetName(), GetAmmoName(), "SCOUT_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_M40A1 );
}

}