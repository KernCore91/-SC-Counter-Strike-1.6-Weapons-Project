//Counter-Strike 1.6 .40 Dual Elites (Dual Berettas)
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

namespace CS16_ELITES
{

// Animations
enum CS16_Elites_Animations
{
	IDLE = 0,
	IDLE_RIGHT_EMPTY,
	SHOOT_RIGHT1,
	SHOOT_RIGHT2,
	SHOOT_RIGHT3,
	SHOOT_RIGHT4,
	SHOOT_RIGHT5,
	SHOOT_RIGHT_EMPTY,
	SHOOT_LEFT1,
	SHOOT_LEFT2,
	SHOOT_LEFT3,
	SHOOT_LEFT4,
	SHOOT_LEFT5,
	SHOOT_LEFT_EMPTY,
	RELOAD,
	DRAW
};

// Models
string W_MODEL  	= "models/cs16/wpn/elite/w_elite.mdl";
string V_MODEL  	= "models/cs16/wpn/elite/v_elite.mdl";
string P_MODEL  	= "models/cs16/wpn/elite/p_elite.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
int MAG_BDYGRP  	= 18;
// Sprites
string SPR_CAT  	= "pist/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/elite/draw.wav",
					"cs16/elite/maginl.wav",
					"cs16/elite/maginr.wav",
					"cs16/elite/magout.wav",
					"cs16/elite/sldrl.wav",
					"cs16/elite/start.wav"
};
string SHOOT_S  	= "cs16/elite/shoot.wav";
// Information
int MAX_CARRY   	= 120;
int MAX_CLIP    	= 30;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
uint DAMAGE     	= 14;
uint SLOT       	= 1;
uint POSITION   	= 8;
float RPM       	= 0.1f;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "cs16_9mm";

//Buy Menu Information
string WPN_NAME 	= "Dual Berettas";
uint WPN_PRICE  	= 190;
string AMMO_NAME 	= "Berettas 9mm Magazines";
uint AMMO_PRICE  	= 15;

class weapon_dualelites : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
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
		return Deploy( V_MODEL, P_MODEL, DRAW, "uzis", GetBodygroup(), (32.0/30.0) );
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

	private void ResetUzisAnim()
	{
		SetThink( null );
		m_pPlayer.m_szAnimExtension = "uzis";
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

		//KernCore: Hardcoded Player Model Stuff
		m_pPlayer.m_szAnimExtension = (self.m_iClip % 2 == 0) ? "uzis_right" : "uzis_left";
		SetThink( ThinkFunction( this.ResetUzisAnim ) );
		self.pev.nextthink = g_Engine.time + (6.0/24.0);
		//KernCore: End

		ShootWeapon( SHOOT_S, 1, vecSpread, MAX_SHOOT_DIST, DAMAGE );
		self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM;

		if( self.m_iClip == 1 )
		{
			self.SendWeaponAnim( SHOOT_RIGHT_EMPTY, 0, GetBodygroup() );
		}
		else if( self.m_iClip == 0 )
		{
			self.SendWeaponAnim( SHOOT_LEFT_EMPTY, 0, GetBodygroup() );
		}
		else
		{
			int iAnim = (self.m_iClip % 2 == 0) ? SHOOT_LEFT1 : SHOOT_RIGHT1;
			iAnim += g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 4 );
			self.SendWeaponAnim( iAnim, 0, GetBodygroup() );
		}

		m_pPlayer.m_iWeaponVolume = BIG_EXPLOSION_VOLUME;
		m_pPlayer.m_iWeaponFlash = DIM_GUN_FLASH;

		m_pPlayer.pev.punchangle.x -= 2;

		ShellEject( m_pPlayer, m_iShell, (self.m_iClip % 2 == 0) ? Vector( 21, -9, -7 ) : Vector( 21, 9, -7 ), true, false );
	}

	private void SetNextUzisAnim()
	{
		SetThink( null );
		m_pPlayer.m_szAnimExtension = "uzis_left";
		BaseClass.Reload();

		//Reset after we're done reloading the player model
		SetThink( ThinkFunction( this.ResetUzisAnim ) );
		self.pev.nextthink = g_Engine.time + (34.0/14.0);
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		//KernCore: Set it to uzis_right on Reload
		m_pPlayer.m_szAnimExtension = "uzis_right";
		SetThink( ThinkFunction( this.SetNextUzisAnim ) );
		self.pev.nextthink = g_Engine.time + (34.0/14.0);

		Reload( MAX_CLIP, RELOAD, (137.0/30.0), GetBodygroup() );

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

		self.SendWeaponAnim( (self.m_iClip == 1) ? IDLE_RIGHT_EMPTY : IDLE, 0, GetBodygroup() );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

class ELITES_MAG : ScriptBasePlayerAmmoEntity, CS16BASE::AmmoBase
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
		return CommonAddAmmo( pOther, MAX_CLIP, (CS16BASE::ShouldUseCustomAmmo) ? MAX_CARRY : CS16BASE::DF_MAX_CARRY_9MM, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_9MM );
	}
}

string GetAmmoName()
{
	return "ammo_dualelites";
}

string GetName()
{
	return "weapon_dualelites";
}

void Register()
{
	CS16BASE::RegisterCWEntity( "CS16_ELITES::", "weapon_dualelites", GetName(), GetAmmoName(), "ELITES_MAG", 
		CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, (CS16BASE::ShouldUseCustomAmmo) ? AMMO_TYPE : CS16BASE::DF_AMMO_9MM );
}

}