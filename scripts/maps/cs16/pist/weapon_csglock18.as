// Counter-Strike 1.6 Glock 18
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve
/ Misc: Valve
/ Script: KernCore
*/

#include "../base"

namespace CS16_GLOCK18
{

// Animations
enum CS16_Glock18_Animations
{
	IDLE1 = 0,
	IDLE2, //Unused
	IDLE3, //Unused
	SHOOT1, //Unused
	SHOOT2, //Unused
	SHOOT3,
	SHOOTEMPTY,
	RELOAD,
	DRAW,
	HOLSTER,
	ADDSILENCER, //Unused
	DRAW2, //Unused
	RELOAD2 //Unused
};

// Models
string W_MODEL  	= "models/cs16/g18/w_glock18.mdl";
string V_MODEL  	= "models/cs16/g18/v_glock18.mdl";
string P_MODEL  	= "models/cs16/g18/p_glock18.mdl";
string A_MODEL  	= "models/cs16/ammo/mags.mdl";
// Sounds
string SHOOT_S  	= "cs16/g18/shoot.wav";
// Information
int MAX_CARRY   	= 120;
int MAX_CLIP    	= 20;
int DEFAULT_GIVE 	= MAX_CLIP * 3;
int WEIGHT      	= 5;
int FLAGS       	= 0;
uint DAMAGE     	= 39;
uint SLOT       	= 1;
uint POSITION   	= 5;
float RPM_SINGLE 	= 0.15f;
float RPM_BURST 	= 0.1f;
string AMMO_TYPE 	= "cs16_9x19mm";

class weapon_csglock18 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
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
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		//Models
		g_Game.PrecacheModel( W_MODEL );
		g_Game.PrecacheModel( V_MODEL );
		g_Game.PrecacheModel( P_MODEL );
		//Sounds
		CS16BASE::PrecacheSound( SHOOT_S );
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
		return Deploy( V_MODEL, P_MODEL, DRAW, "onehanded", GetBodygroup(), (49.0/45.0) );
	}

	bool PlayEmptySound()
	{
		return CommonPlayEmptySound( CS16BASE::EMPTY_PISTOL_S );
	}

	void Holster( int skiplocal = 0 )
	{
		m_iBurstLeft = 0;
		CommonHolster();

		BaseClass.Holster( skiplocal );
	}

	private void FireWeapon()
	{
		
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + RPM_SINGLE;
			return;
		}
	}

	void SecondaryAttack()
	{
		switch( WeaponFireMode )
		{
			case CS16BASE::MODE_NORMAL:
			{
				WeaponFireMode = CS16BASE::MODE_BURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Switched to Burst Fire\n" );
				break;
			}
			case CS16BASE::MODE_BURST:
			{
				WeaponFireMode = CS16BASE::MODE_NORMAL;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, "Switched to Semi Auto\n" );
				break;
			}
		}
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
	}

	void ItemPostFrame()
	{
		BaseClass.ItemPostFrame();
	}

	void Reload()
	{
		if( self.m_iClip == MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		Reload( MAX_CLIP, RELOAD, (75.0/35.0), GetBodygroup() );

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

		self.SendWeaponAnim( IDLE1, 0, GetBodygroup() );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 7 );
	}
}

}