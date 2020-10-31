// Usage suited for Counter-Strike Weapons in Sven Co-op
// Author: KernCore

namespace CS16BASE
{ //Namespace start

bool ShouldUseCustomAmmo = true; // true = Uses custom ammo values; false = Uses SC's default ammo values.

//default Ammo
//9mm
const string DF_AMMO_9MM	= "9mm";
const int DF_MAX_CARRY_9MM	= 250;
//buckshot
const string DF_AMMO_BUCK	= "buckshot";
const int DF_MAX_CARRY_BUCK	= 125;
//357
const string DF_AMMO_357	= "357";
const int DF_MAX_CARRY_357	= 36;
//m40a1
const string DF_AMMO_M40A1	= "m40a1";
const int DF_MAX_CARRY_M40A1= 15;
//556
const string DF_AMMO_556	= "556";
const int DF_MAX_CARRY_556	= 600;
//rockets
const string DF_AMMO_RKT	= "rockets";
const int DF_MAX_CARRY_RKT	= 5;
const int DF_MAX_CARRY_RKT2	= 10;
//uranium
const string DF_AMMO_URAN	= "uranium";
const int DF_MAX_CARRY_URAN	= 100;
//ARgrenades
const string DF_AMMO_ARGR	= "ARgrenades";
const int DF_MAX_CARRY_ARGR	= 10;
//sporeclip
const string DF_AMMO_SPOR	= "sporeclip";
const int DF_MAX_CARRY_SPOR	= 30;

// Precaches an array of sounds
void PrecacheSounds( const array<string> pSound )
{
	for( uint i = 0; i < pSound.length(); i++ )
	{
		g_SoundSystem.PrecacheSound( pSound[i] );
		g_Game.PrecacheGeneric( "sound/" + pSound[i] );
		//g_Game.AlertMessage( at_console, "Precached: sound/" + pSound[i] + "\n" );
	}
}

// Precaches a single sound
void PrecacheSound( const string pSound )
{
	g_SoundSystem.PrecacheSound( pSound );
	g_Game.PrecacheGeneric( "sound/" + pSound );
	//g_Game.AlertMessage( at_console, "Precached: sound/" + pSound[i] + "\n" );
}

edict_t@ ENT( const entvars_t@ pev )
{
	return pev.pContainingEntity;
}

//Register Custom weapon entities along with custom ammo entity
void RegisterCWEntity( const string szNameSpace, const string szWeaponClass, const string szWeaponName, const string szAmmoName, const string szAmmoClass, 
	const string& in szSpriteDir, const string szAmmoType1
	/*const string szAmmoType2 = "", const string szAmmoEntity2 = ""*/ )
{
	g_CustomEntityFuncs.RegisterCustomEntity( szNameSpace + szWeaponClass, szWeaponName ); // Register the weapon entity
	g_CustomEntityFuncs.RegisterCustomEntity( szNameSpace + szAmmoClass, szAmmoName ); // Register the ammo entity
	g_ItemRegistry.RegisterWeapon( szWeaponName, szSpriteDir, szAmmoType1, "", szAmmoName/*, szAmmoEntity2*/ ); // Register the weapon
}

//Weapon Fire Modes
enum FIREMODE_OPTIONS
{
	MODE_NORMAL = 0,
	MODE_BURST
};

//Model files
const string SHELL_PISTOL   	= "models/cs16/shells/pshell.mdl";
const string SHELL_RIFLE    	= "models/cs16/shells/rshell.mdl";
const string SHELL_SNIPER   	= "models/cs16/shells/rshell_big.mdl";
const string SHELL_SHOTGUN  	= "models/hlclassic/shotgunshell.mdl";
//Sound files
const string EMPTY_PISTOL_S 	= "cs16/dryfire_pistol.wav";
const string EMPTY_RIFLE_S  	= "cs16/dryfire_rifle.wav";
//Main Sprite Folder
const string MAIN_SPRITE_DIR 	= "sprites/";
const string MAIN_CSTRIKE_DIR 	= "cs16/";

mixin class WeaponBase
{
	protected int m_iShotsFired = 0;
	protected int WeaponFireMode;
	protected int m_iShell;

	protected float WeaponTimeBase() // map time
	{
		return g_Engine.time;
	}

	protected bool m_fDropped;
	CBasePlayerItem@ DropItem() // drops the item
	{
		m_fDropped = true;
		return self;
	}

	void CommonSpawn( const string worldModel, const int GiveDefaultAmmo ) // things that are commonly executed in spawn
	{
		m_iShotsFired = 0;
		g_EntityFuncs.SetModel( self, self.GetW_Model( worldModel ) );
		self.m_iDefaultAmmo = GiveDefaultAmmo;
		self.pev.scale = 1.4;

		self.FallInit();
	}

	void CommonSpritePrecache()
	{
		g_Game.PrecacheGeneric( MAIN_SPRITE_DIR + MAIN_CSTRIKE_DIR + "640hud1.spr" );
		g_Game.PrecacheGeneric( MAIN_SPRITE_DIR + MAIN_CSTRIKE_DIR + "640hud4.spr" );
		g_Game.PrecacheGeneric( MAIN_SPRITE_DIR + MAIN_CSTRIKE_DIR + "640hud7.spr" );
		g_Game.PrecacheGeneric( MAIN_SPRITE_DIR + MAIN_CSTRIKE_DIR + "crosshairs.spr" );
	}

	bool CommonAddToPlayer( CBasePlayer@ pPlayer ) // adds a weapon to the player
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		NetworkMessage weapon( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			weapon.WriteShort( g_ItemRegistry.GetIdForName( self.pev.classname ) );
		weapon.End();

		return true;
	}

	bool Deploy( string vModel, string pModel, int iAnim, string pAnim, int iBodygroup, float flDeployTime ) // deploys the weapon
	{
		m_fDropped = false;
		self.DefaultDeploy( self.GetV_Model( vModel ), self.GetP_Model( pModel ), iAnim, pAnim, 0, iBodygroup );
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = WeaponTimeBase() + flDeployTime;
		return true;
	}

	bool CommonPlayEmptySound( const string emptySound = string_t() ) // plays a empty sound when the player has no ammo left in the magazine
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_STREAM, emptySound, 0.9, 1.5, 0, PITCH_NORM );
		}

		return false;
	}

	void CommonHolster() // things that plays on holster
	{
		self.m_fInReload = false;
		SetThink( null );
		m_iShotsFired = 0;
		m_pPlayer.pev.fuser4 = 0;
	}

	// Precise shell casting
	void GetDefaultShellInfo( CBasePlayer@ pPlayer, Vector& out ShellVelocity, Vector& out ShellOrigin, float forwardScale, float rightScale, float upScale, bool leftShell, bool downShell )
	{
		Vector vecForward, vecRight, vecUp;

		g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vecForward, vecRight, vecUp );

		const float fR = (leftShell == true) ? Math.RandomFloat( -120, -60 ) : Math.RandomFloat( 60, 120 );
		const float fU = (downShell == true) ? Math.RandomFloat( -150, -90 ) : Math.RandomFloat( 90, 150 );

		for( int i = 0; i < 3; ++i )
		{
			ShellVelocity[i] = pPlayer.pev.velocity[i] + vecRight[i] * fR + vecUp[i] * fU + vecForward[i] * Math.RandomFloat( 1, 50 );
			ShellOrigin[i]   = pPlayer.pev.origin[i] + pPlayer.pev.view_ofs[i] + vecUp[i] * upScale + vecForward[i] * forwardScale + vecRight[i] * rightScale;
		}
	}

	void ShellEject( CBasePlayer@ pPlayer, int& in mShell, Vector& in Pos, bool leftShell = false, bool downShell = false, TE_BOUNCE shelltype = TE_BOUNCE_SHELL ) // eject spent shell casing
	{
		Vector vecShellVelocity, vecShellOrigin;
		GetDefaultShellInfo( pPlayer, vecShellVelocity, vecShellOrigin, Pos.x, Pos.y, Pos.z, leftShell, downShell ); //23 4.75 -5.15
		vecShellVelocity.y *= 1;
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, pPlayer.pev.angles.y, mShell, shelltype );
	}

	void ShootWeapon( const string szSound, const uint uiNumShots, const Vector& in CONE, const float flMaxDist, const int iDamage )
	{
		if( szSound != string_t() || szSound != "" )
		{
			--self.m_iClip;
			++m_iShotsFired;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, szSound, Math.RandomFloat( 0.95, 1.0 ), 0.55, 0, 94 + Math.RandomLong( 0, 0xf ) );
		}

		Vector vecSrc   	= m_pPlayer.GetGunPosition();
		Vector vecAiming 	= m_pPlayer.GetAutoaimVector( AUTOAIM_2DEGREES );

		m_pPlayer.FireBullets( uiNumShots, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, flMaxDist, BULLET_PLAYER_CUSTOMDAMAGE, 2, iDamage );

		if( self.m_iClip <= 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		self.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		TraceResult tr;
		float x, y;

		for( uint uiPellet = 0; uiPellet < uiNumShots; ++uiPellet )
		{
			g_Utility.GetCircularGaussianSpread( x, y );

			Vector vecDir = vecAiming + x * CONE.x * g_Engine.v_right + y * CONE.y * g_Engine.v_up;
			Vector vecEnd = vecSrc + vecDir * flMaxDist;

			g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

			if( tr.flFraction < 1.0 )
			{
				if( tr.pHit !is null )
				{
					CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );

					g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + (vecEnd - vecSrc) * 2, BULLET_PLAYER_CUSTOMDAMAGE );

					if( pHit is null || pHit.IsBSPModel() )
					{
						g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_CUSTOMDAMAGE );
					}
				}
			}
		}
	}

	void Reload( int iAmmo, int iAnim, float flTimer, int iBodygroup ) // things commonly executed in reloads
	{
		self.m_fInReload = true;
		self.DefaultReload( iAmmo, iAnim, flTimer, iBodygroup );
		m_iShotsFired = 0;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + flTimer;
	}
}

mixin class AmmoBase
{
	void CommonSpawn( const string worldModel, const int iBodygroup ) // things that are commonly executed in spawn
	{
		g_EntityFuncs.SetModel( self, worldModel );
		self.pev.body = iBodygroup;
		self.pev.scale = 1.5;

		BaseClass.Spawn();
	}

	bool CommonAddAmmo( CBaseEntity& inout pOther, int& in iAmmoClip, int& in iAmmoCarry, string& in iAmmoType )
	{
		if( pOther.GiveAmmo( iAmmoClip, iAmmoType, iAmmoCarry ) != -1 )
		{
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, string_t(), 1, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 0xa ) );
			return true;
		}
		return false;
	}
}

} // Namespace end