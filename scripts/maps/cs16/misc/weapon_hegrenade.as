//Counter-Strike 1.6 High Explosive Grenade
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve
/ Misc: Valve, D.N.I.O. 071 (Player Model Fix)
/ Script: KernCore, original base from Nero
*/

namespace CS16_HEGRENADE
{

// Animations
enum CS16_Hegrenades_Animations 
{
	IDLE = 0,
	PULLPIN,
	THROW,
	DRAW
};

// Models
string W_MODEL  	= "models/cs16/wpn/he/w_he.mdl";
string V_MODEL  	= "models/cs16/wpn/he/v_he.mdl";
string P_MODEL  	= "models/cs16/wpn/he/p_he.mdl";
// Sprites
string SPR_CAT  	= "misc/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/he/pin.wav"
};
// Information
int MAX_CARRY   	= 10;
int MAX_CLIP    	= WEAPON_NOCLIP;
int DEFAULT_GIVE 	= 1;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
uint DAMAGE     	= 150;
uint SLOT       	= 4;
uint POSITION   	= 4;
string AMMO_TYPE 	= GetName();
float TIMER      	= 1.5;

class weapon_hegrenade : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private bool m_bInAttack, m_bThrown;
	private float m_fAttackStart, m_flStartThrow;
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();

		self.pev.dmg = DAMAGE;
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
		CS16BASE::PrecacheSounds( WeaponSoundEvents );
		//Sprites
		CommonSpritePrecache();
		g_Game.PrecacheGeneric( CS16BASE::MAIN_SPRITE_DIR + CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT + self.pev.classname + ".txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= MAX_CARRY;
		info.iMaxAmmo2 	= -1;
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

	// Better ammo extraction --- Anggara_nothing
	bool CanHaveDuplicates()
	{
		return true;
	}

	private int m_iAmmoSave;
	bool Deploy()
	{
		m_iAmmoSave = 0; // Zero out the ammo save
		return Deploy( V_MODEL, P_MODEL, HEGRENADE_DRAW, "gren", GetBodygroup(), (20.0/30.0) );
	}

	bool CanHolster()
	{
		if( m_fAttackStart != 0 )
			return false;

		return true;
	}

	bool CanDeploy()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType) == 0 )
			return false;

		return true;
	}

	private CBasePlayerItem@ DropItem()
	{
		m_iAmmoSave = m_pPlayer.AmmoInventory( self.m_iPrimaryAmmoType ); //Save the player's ammo pool in case it has any in DropItem

		return self;
	}

	void Holster( int skipLocal = 0 )
	{
		m_bThrown = false;
		m_bInAttack = false;
		m_fAttackStart = 0;
		m_flStartThrow = 0;

		CommonHolster();

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 ) //Save the player's ammo pool in case it has any in Holster
		{
			m_iAmmoSave = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		}

		if( m_iAmmoSave <= 0 )
		{
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}

		BaseClass.Holster( skipLocal );
	}
}

string GetName()
{
	return "weapon_hegrenade";
}

void Register()
{
	CS16BASE::RegisterCWEntityEX( "CS16_HEGRENADE::", "weapon_hegrenade", GetName(), GetName(), CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, AMMO_TYPE );
}

}