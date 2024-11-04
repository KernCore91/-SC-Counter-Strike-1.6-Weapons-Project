// Counter-Strike 1.6 C4 Bomb
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve, R4to0
/ Misc: Valve, D.N.I.O. 071 (Player Model Fix)
/ Script: Nero, KernCore (Adapting to another base)
*/

#include "../base"
#include "../proj/proj_csc4"
#include "CInfoBombTarget"

namespace CS16_C4
{

// Animations
enum CS16_C4_Animations 
{
	IDLE = 0,
	DRAW,
	DROP,
	ARM
};

// Models
string W_MODEL  	= "models/cs16/wpn/c4/w_bp.mdl";
string V_MODEL  	= "models/cs16/wpn/c4/v_c4.mdl";
string P_MODEL  	= "models/cs16/wpn/c4/p_c4.mdl";
string C_MODEL  	= "models/cs16/wpn/c4/w_c4.mdl";
// Sprites
string SPR_CAT  	= "misc/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/c4/click.wav"
};
string PLANT_S   	= "cs16/c4/plant.wav"; //c4_plant
// Information
int MAX_CARRY   	= 1;
int MAX_CLIP    	= WEAPON_NOCLIP;
int DEFAULT_GIVE 	= 1;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
uint DAMAGE     	= 99999;
uint SLOT       	= 4;
uint POSITION   	= 5;
string AMMO_TYPE 	= GetName();
float TIMER      	= 35;
float DELAY_FAIL 	= 1;

//Buy Menu Information
string WPN_NAME 	= "C4 Explosive";
uint WPN_PRICE  	= 600;

//Strings
const string PLANT_AT_BOMB_SPOT      	= "C4 must be planted at a bomb site!\n";
const string PLANT_MUST_BE_ON_GROUND 	= "You must be standing on\nthe ground to plant the C4!\n";
const string ARMING_CANCELLED        	= "Arming Sequence Cancelled\nC4 can only be placed at a Bomb Target.\n";
const string BOMB_PLANTED           	= "The bomb has been planted!\n";

class weapon_c4 : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase, CS16BASE::GrenadeWeaponExplode
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private bool m_bStartedArming, m_bBombPlacedAnimation;
	private float m_fArmedTime;
	private int GetBodygroup()
	{
		return 0;
	}

	void Spawn()
	{
		Precache();
		m_bStartedArming = false;
		m_fArmedTime = 0;

		/*if( self.pev.targetname != "" )
		{
			self.pev.effects |= EF_NODRAW;
			g_EngineFuncs.DropToFloor( self.edict() );
			return;
		}*/

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
		g_Game.PrecacheModel( C_MODEL );
		//Entities
		g_Game.PrecacheOther( CS16C4PROJECTILE::DEFAULT_PROJ_NAME );
		//Sounds
		CS16BASE::PrecacheSounds( WeaponSoundEvents );
		CS16BASE::PrecacheSound( PLANT_S );
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

	void ShowC4Sprite( float flHoldTime )
	{
		Vector2D vec2dPos( 0, 300 );

		HUDSpriteParams SpriteParams;
		SpriteParams.channel = 4;
		SpriteParams.flags = HUD_ELEM_ABSOLUTE_X | HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_DYNAMIC_ALPHA;
		SpriteParams.x = vec2dPos.x;
		SpriteParams.y = vec2dPos.y;
		SpriteParams.left = 0; // Offset
		SpriteParams.top = 148; // Offset
		SpriteParams.width = 32; // 0: auto; use total width of the sprite
		SpriteParams.height = 32; // 0: auto; use total height of the sprite
		SpriteParams.spritename = CS16BASE::MAIN_CSTRIKE_DIR + "640hud7.spr";
		SpriteParams.effect = HUD_EFFECT_NONE;
		SpriteParams.color1 = RGBA_SVENCOOP;
		SpriteParams.holdTime = flHoldTime;
		g_PlayerFuncs.HudCustomSprite( m_pPlayer, SpriteParams );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		ShowC4Sprite( -1 );

		NetworkMessage weapon( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			weapon.WriteShort( g_ItemRegistry.GetIdForName( self.pev.classname ) );
		weapon.End();

		return true;
	}

	// Better ammo extraction --- Anggara_nothing
	bool CanHaveDuplicates()
	{
		return true;
	}

	private int m_iAmmoSave;
	bool Deploy()
	{
		ShowC4Sprite( -1 );
		m_iAmmoSave = 0; // Zero out the ammo save
		return Deploy( V_MODEL, P_MODEL, DRAW, "trip", GetBodygroup(), (15.0/30.0) );
	}

	private CBasePlayerItem@ DropItem()
	{
		m_iAmmoSave = m_pPlayer.AmmoInventory( self.m_iPrimaryAmmoType ); //Save the player's ammo pool in case it has any in DropItem
		ShowC4Sprite( 0 );

		return self;
	}

	void Holster( int skipLocal = 0 )
	{
		m_bStartedArming = false;
		m_pPlayer.SetMaxSpeedOverride( -1 ); //m_pPlayer.pev.maxspeed = 0;

		CommonHolster();

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 ) //Save the player's ammo pool in case it has any in Holster
		{
			m_iAmmoSave = m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType );
		}

		if( m_iAmmoSave <= 0 )
		{
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
			ShowC4Sprite( 0 );
		}

		if( !m_pPlayer.IsAlive() )
			ShowC4Sprite( 0 );

		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		bool onGround = (m_pPlayer.pev.flags & FL_ONGROUND) != 0;
		CustomKeyvalues@ pCustom = m_pPlayer.GetCustomKeyvalues();
		bool onBombZone = pCustom.GetKeyvalue( CS16_BOMBTARGET::INBOMB_KV ).GetInteger() == 1;

		if( !m_bStartedArming )
		{
			if( !onBombZone && CS16_BOMBTARGET::USE_BOMB_ZONES )
			{
				g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, PLANT_AT_BOMB_SPOT );
				self.m_flNextPrimaryAttack = g_Engine.time + DELAY_FAIL;
				return;
			}

			if( !onGround )
			{
				g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, PLANT_MUST_BE_ON_GROUND );
				self.m_flNextPrimaryAttack = g_Engine.time + DELAY_FAIL;
				return;
			}

			m_pPlayer.SetMaxSpeedOverride( 0 ); //m_pPlayer.pev.maxspeed = 1;

			m_bStartedArming = true;
			m_bBombPlacedAnimation = false;
			m_fArmedTime = g_Engine.time + 3;
			self.SendWeaponAnim( ARM, 0, GetBodygroup() );
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
			//m_pPlayer.SetProgressBarTime(3);
			self.m_flNextPrimaryAttack = g_Engine.time + 0.3f;
			self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat( 10, 15 );
		}
		else
		{
			if( !onGround || (!onBombZone && CS16_BOMBTARGET::USE_BOMB_ZONES) )
			{
				if( onBombZone && CS16_BOMBTARGET::USE_BOMB_ZONES )
					g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, ARMING_CANCELLED );
				else
					g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, PLANT_MUST_BE_ON_GROUND );

				m_bStartedArming = false;
				self.m_flNextPrimaryAttack = g_Engine.time + 1.5f;
				m_pPlayer.SetMaxSpeedOverride( -1 ); //m_pPlayer.pev.maxspeed = 0;
				//m_pPlayer.SetProgressBarTime(0);
				//m_pPlayer.SetAnimation( PLAYER_HOLDBOMB );

				if( m_bBombPlacedAnimation == true )
					self.SendWeaponAnim( DRAW, 0, GetBodygroup() );
				else
					self.SendWeaponAnim( IDLE, 0, GetBodygroup() );

				return;
			}

			if( g_Engine.time > m_fArmedTime )
			{
				if( m_bStartedArming == true )
				{
					m_bStartedArming = false;
					m_fArmedTime = 0;
					//g_SoundSystem.PlaySound( m_pPlayer.edict(), CHAN_STATIC, C4_SOUND_BOMBPLANT, 1, ATTN_NORM );

					auto pC4 = CS16C4PROJECTILE::PlantC4( m_pPlayer.pev, m_pPlayer.pev.origin, Vector(0, 0, 0), TIMER, DAMAGE, C_MODEL );

					g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, BOMB_PLANTED );

					g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, PLANT_S, VOL_NORM, ATTN_NORM );

					m_pPlayer.SetMaxSpeedOverride( -1 ); //m_pPlayer.pev.maxspeed = 0;
					//m_pPlayer.SetBombIcon(FALSE);
					m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) - 1 );

					if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
					{
						self.RetireWeapon();
						return;
					}
				}
			}
			else
			{
				if( g_Engine.time >= m_fArmedTime - 0.75f )
				{
					if( m_bBombPlacedAnimation == false )
					{
						m_bBombPlacedAnimation = true;
						self.SendWeaponAnim( DROP, 0, GetBodygroup() );
						SetThink( ThinkFunction( this.DrawThink ) );
						self.pev.nextthink = g_Engine.time + 0.5;
						//m_pPlayer.SetAnimation( PLAYER_HOLDBOMB );
					}
				}
			}
		}

		self.m_flNextPrimaryAttack = g_Engine.time + 0.3f;
		self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat( 10, 15 );
	}

	void DrawThink()
	{
		self.SendWeaponAnim( DRAW, 0, GetBodygroup() );
	}

	void WeaponIdle()
	{
		if( m_bStartedArming == true )
		{
			m_bStartedArming = false;
			m_pPlayer.SetMaxSpeedOverride( -1 ); //m_pPlayer.pev.maxspeed = 0;
			self.m_flNextPrimaryAttack = g_Engine.time + 1;
			//m_pPlayer.SetProgressBarTime( 0 );

			if( m_bBombPlacedAnimation == true )
				self.SendWeaponAnim( DRAW, 0, GetBodygroup() );
			else
				self.SendWeaponAnim( IDLE, 0, GetBodygroup() );
		}

		if( self.m_flTimeWeaponIdle <= g_Engine.time )
		{
			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			{
				self.RetireWeapon();
				return;
			}

			self.SendWeaponAnim( DRAW, 0, GetBodygroup() );
			self.SendWeaponAnim( IDLE, 0, GetBodygroup() );
		}
	}
}

string GetName()
{
	return "weapon_c4";
}

void Register()
{
	CS16_BOMBTARGET::Register();
	CS16C4PROJECTILE::Register();
	CS16BASE::RegisterCWEntityEX( "CS16_C4::", "weapon_c4", GetName(), GetName(), CS16BASE::MAIN_CSTRIKE_DIR + SPR_CAT, AMMO_TYPE );
}

}