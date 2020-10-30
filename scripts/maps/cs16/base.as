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

//Weapon Fire Modes
enum FIREMODE_OPTIONS
{
	MODE_NORMAL = 0,
	MODE_BURST
}

//Sound files
const string EMPTY_PISTOL_S 	= "cs16/dryfire_pistol.wav";
const string EMPTY_RIFLE_S  	= "cs16/dryfire_rifle.wav";

mixin class WeaponBase
{
	protected m_iShotsFired = 0;
	protected WeaponFireMode;

	protected float WeaponTimeBase() // map time
	{
		return g_Engine.time;
	}

	void CommonSpawn( const string worldModel, const int GiveDefaultAmmo ) // things that are commonly executed in spawn
	{
		m_iShotsFired = 0;
		g_EntityFuncs.SetModel( self, self.GetW_Model( worldModel ) );
		self.m_iDefaultAmmo = GiveDefaultAmmo;
		//self.pev.scale = 1.3;

		self.FallInit();
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

	void CommonHolster() // things that plays on holster
	{
		self.m_fInReload = false;
		SetThink( null );
		m_iShotsFired = 0;
		m_pPlayer.pev.fuser4 = 0;
	}
}

mixin class AmmoBase
{

}

} // Namespace end