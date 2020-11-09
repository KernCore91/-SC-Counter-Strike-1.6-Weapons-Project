// Counter-Strike 1.6's Grenade Projectile Base
// Author: KernCore

#include "../base"

namespace CS16GRENADEPROJECTILE
{

string DEFAULT_PROJ_NAME 	= "proj_cs16grenade";
string BOUNCE_SOUND      	= "cs16/he/bounce.wav";

class CCs16Grenade : ScriptBaseMonsterEntity
{
	private float m_flBounceTime = 0, m_flNextAttack = 0;
	private bool m_bRegisteredSound = false;
	private int m_iExplodeSprite;
	private int m_iExplodeSprite2;
	private int m_iWaterExSprite;
	private int m_iSteamSprite;

	void Spawn()
	{
		Precache();
		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;

		self.pev.gravity = 0.55f;
		self.pev.friction = 0.7f;
		self.pev.framerate = 1.0f;

		SetThink( ThinkFunction( this.TumbleThink ) );
		self.pev.nextthink = g_Engine.time + 0.1;

		g_EntityFuncs.SetSize( self.pev, Vector( -1, -1, -1 ), Vector( 1, 1, 1 ) );
	}

	void Precache()
	{
		//Models
		m_iExplodeSprite 	= g_Game.PrecacheModel( "sprites/eexplo.spr" );
		m_iExplodeSprite2	= g_Game.PrecacheModel( "sprites/fexplo.spr" );
		m_iSteamSprite   	= g_Game.PrecacheModel( "sprites/steam1.spr" );
		m_iWaterExSprite 	= g_Game.PrecacheModel( "sprites/WXplo1.spr" );
		//Sounds
		CS16BASE::PrecacheSound( BOUNCE_SOUND );
	}

	void BounceTouch( CBaseEntity@ pOther )
	{
		// don't hit the guy that launched this grenade
		if( @pOther.edict() == @self.pev.owner )
			return;

		// Only do damage if we're moving fairly fast
		if( m_flNextAttack < g_Engine.time && self.pev.velocity.Length() > 100 )
		{
			entvars_t@ pevOwner = @self.pev.owner.vars;
			if( pevOwner !is null )
			{
				TraceResult tr = g_Utility.GetGlobalTrace();
				g_WeaponFuncs.ClearMultiDamage();
				pOther.TraceAttack( pevOwner, 1, g_Engine.v_forward, tr, DMG_CLUB );
				g_WeaponFuncs.ApplyMultiDamage( self.pev, pevOwner );
			}
			m_flNextAttack = g_Engine.time + 1.0; // debounce
		}

		/*if( pOther.pev.ClassNameIs( "func_breakable" ) && pOther.pev.rendermode != kRenderNormal )
		{
			self.pev.velocity = self.pev.velocity * -2.0f;
			return;
		}*/

		Vector vecTestVelocity;
		// this is my heuristic for modulating the grenade velocity because grenades dropped purely vertical
		// or thrown very far tend to slow down too quickly for me to always catch just by testing velocity.
		// trimming the Z velocity a bit seems to help quite a bit.
		vecTestVelocity = self.pev.velocity;
		vecTestVelocity.z *= 0.7f;

		if( m_bRegisteredSound == false && vecTestVelocity.Length() <= 60.0f )
		{
			// grenade is moving really slow. It's probably very close to where it will ultimately stop moving.
			// go ahead and emit the danger sound.

			// register a radius louder than the explosion, so we make sure everyone gets out of the way
			GetSoundEntInstance().InsertSound( bits_SOUND_DANGER, self.pev.origin, int(self.pev.dmg / 0.5), 0.3, self );
			//CSoundEnt::InsertSound ( bits_SOUND_DANGER, pev->origin, pev->dmg / 0.5, 0.3, this );
			m_bRegisteredSound = true;
		}

		if( self.pev.flags & FL_ONGROUND != 0 )
		{
			self.pev.velocity = self.pev.velocity * 0.8f;
			self.pev.sequence = 1;//Math.RandomLong( 1, 3 );
		}
		else
		{
			BounceSounds();
			self.pev.flags |= EF_NOINTERP;
		}

		self.pev.framerate = self.pev.velocity.Length() / 200.0f;

		if( self.pev.framerate > 1 )
			self.pev.framerate = 1.0f;
		else if( self.pev.framerate < 0.5f )
			self.pev.framerate = 0;
	}

	void BounceSounds()
	{
		if( g_Engine.time < m_flBounceTime )
			return;

		m_flBounceTime = g_Engine.time + Math.RandomFloat( 0.2, 0.3 );

		if( g_Utility.GetGlobalTrace().flFraction < 1.0 )
		{
			if( g_Utility.GetGlobalTrace().pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( g_Utility.GetGlobalTrace().pHit );
				if( pHit.IsBSPModel() )
				{
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, BOUNCE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				}
			}
		}
	}

	void TumbleThink()
	{
		if( !self.IsInWorld() )
		{
			g_EntityFuncs.Remove( self );
			return;
		}

		self.StudioFrameAdvance();
		self.pev.nextthink = g_Engine.time + 0.1;

		if( self.pev.dmgtime <= g_Engine.time )
		{
			SetThink( ThinkFunction( this.Detonate ) );
		}

		if( self.pev.waterlevel != WATERLEVEL_DRY )
		{
			self.pev.velocity = self.pev.velocity * 0.5;
			self.pev.framerate = 0.2;

			self.pev.angles = Math.VecToAngles( self.pev.velocity );
		}
	}

	void ExplodeMsg( Vector& in origin, float scale, int framerate )
	{
		int iContents = g_EngineFuncs.PointContents( origin );
		NetworkMessage exp_msg( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin(), null );
			exp_msg.WriteByte( TE_EXPLOSION ); //MSG type enum
			exp_msg.WriteCoord( origin.x ); //pos
			exp_msg.WriteCoord( origin.y ); //pos
			exp_msg.WriteCoord( origin.z ); //pos
			if( iContents == CONTENTS_WATER || iContents == CONTENTS_SLIME || iContents == CONTENTS_LAVA ) //check if entity is in a liquid
				exp_msg.WriteShort( m_iWaterExSprite );
			else
				exp_msg.WriteShort( m_iExplodeSprite2 );
			exp_msg.WriteByte( int(scale) ); //scale
			exp_msg.WriteByte( framerate ); //framerate
			exp_msg.WriteByte( TE_EXPLFLAG_NONE ); //flag
		exp_msg.End();
	}

	void ExplodeMsg2( Vector& in origin, float scale, int framerate )
	{
		int iContents = g_EngineFuncs.PointContents( origin );
		NetworkMessage exp_msg( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin(), null );
			exp_msg.WriteByte( TE_EXPLOSION ); //MSG type enum
			exp_msg.WriteCoord( origin.x ); //pos
			exp_msg.WriteCoord( origin.y ); //pos
			exp_msg.WriteCoord( origin.z ); //pos
			if( iContents == CONTENTS_WATER || iContents == CONTENTS_SLIME || iContents == CONTENTS_LAVA ) //check if entity is in a liquid
				exp_msg.WriteShort( m_iWaterExSprite );
			else
				exp_msg.WriteShort( m_iExplodeSprite );
			exp_msg.WriteByte( int(scale) ); //scale
			exp_msg.WriteByte( framerate ); //framerate
			exp_msg.WriteByte( TE_EXPLFLAG_NONE ); //flag
		exp_msg.End();
	}

	void Explode( TraceResult pTrace )
	{
		self.pev.model = string_t();
		self.pev.solid = SOLID_NOT;
		self.pev.takedamage = DAMAGE_NO;

		entvars_t@ pevOwner;
		if( self.pev.owner !is null )
			@pevOwner = @self.pev.owner.vars;
		else
			@pevOwner = self.pev;

		// Pull out of the wall a bit
		if( pTrace.flFraction != 1.0 )
		{
			self.pev.origin = pTrace.vecEndPos + (pTrace.vecPlaneNormal * (self.pev.dmg - 24.0f) * 0.6f);
		}

		int iContents = g_EngineFuncs.PointContents( self.GetOrigin() );

		ExplodeMsg( Vector( self.GetOrigin().x, self.GetOrigin().y, self.GetOrigin().z + 20.0f ), 25, 30 );
		ExplodeMsg2( Vector( self.GetOrigin().x + Math.RandomFloat( -32, 32 ), self.GetOrigin().y + Math.RandomFloat( -32, 32 ), self.GetOrigin().z + Math.RandomFloat( 30, 35 ) ), 30, 30 );

		g_Utility.Sparks( self.GetOrigin() );
		GetSoundEntInstance().InsertSound( bits_SOUND_COMBAT, self.pev.origin, NORMAL_EXPLOSION_VOLUME, 3, self );

		g_WeaponFuncs.RadiusDamage( self.GetOrigin(), self.pev, pevOwner, self.pev.dmg, self.pev.dmg * 2, CLASS_NONE, DMG_BLAST );
		g_Utility.DecalTrace( pTrace, (Math.RandomLong( 0, 1 ) < 0.5) ? DECAL_SCORCH1 : DECAL_SCORCH2 );

		self.pev.effects |= EF_NODRAW;
		self.pev.velocity = g_vecZero;
		SetThink( ThinkFunction( this.Smoke ) );
		self.pev.nextthink = g_Engine.time + 0.55f;

		if( iContents != CONTENTS_WATER )
		{
			int sparkCount = Math.RandomLong( 1, 3 );
			for( int i = 0; i < sparkCount; i++ )
				g_EntityFuncs.Create( "spark_shower", self.pev.origin, pTrace.vecPlaneNormal, false );
		}
	}

	void Smoke()
	{
		int iContents = g_EngineFuncs.PointContents( self.GetOrigin() );
		if( iContents == CONTENTS_WATER || iContents == CONTENTS_SLIME || iContents == CONTENTS_LAVA )
		{
			g_Utility.Bubbles( self.GetOrigin() - Vector( 64, 64, 64 ), self.GetOrigin() + Vector( 64, 64, 64 ), 100 );
		}
		else
		{
			NetworkMessage smk_msg( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin(), null );
				smk_msg.WriteByte( TE_SMOKE ); //MSG type enum
				smk_msg.WriteCoord( self.GetOrigin().x ); //pos
				smk_msg.WriteCoord( self.GetOrigin().y ); //pos
				smk_msg.WriteCoord( self.GetOrigin().z - 5.0f ); //pos
				smk_msg.WriteShort( m_iSteamSprite );
				smk_msg.WriteByte( 35 + Math.RandomLong( 0, 10 ) ); //scale
				smk_msg.WriteByte( 5 ); //framerate
			smk_msg.End();
		}

		g_EntityFuncs.Remove( self );
	}

	void Detonate()
	{
		self.pev.flags &= ~EF_NOINTERP;
		TraceResult tr;
		Vector vecSpot;// trace starts here!
		vecSpot = self.GetOrigin() + Vector( 0, 0, 8 );
		g_Utility.TraceLine( vecSpot, vecSpot + Vector( 0, 0, -40 ), ignore_monsters, self.pev.pContainingEntity, tr );
		Explode( tr );
	}

	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		Detonate();
	}
}

CCs16Grenade@ TossGrenade( entvars_t@ pevOwner, Vector vecStart, Vector vecVelocity, float flTime, float flDmg, string sModel, const string& in szName = DEFAULT_PROJ_NAME )
{
	CBaseEntity@ cbeCS16Grenade = g_EntityFuncs.CreateEntity( szName );
	CCs16Grenade@ cs16Grenade = cast<CCs16Grenade@>( CastToScriptClass( cbeCS16Grenade ) );

	g_EntityFuncs.SetOrigin( cs16Grenade.self, vecStart );
	g_EntityFuncs.SetModel( cs16Grenade.self, sModel );
	g_EntityFuncs.DispatchSpawn( cs16Grenade.self.edict() );

	cs16Grenade.pev.velocity = vecVelocity;
	cs16Grenade.pev.angles = Math.VecToAngles( cs16Grenade.pev.velocity );
	@cs16Grenade.pev.owner = CS16BASE::ENT( pevOwner );

	cs16Grenade.pev.dmg = flDmg;
	cs16Grenade.pev.sequence = Math.RandomLong( 3, 6 );

	cs16Grenade.SetTouch( TouchFunction( cs16Grenade.BounceTouch ) );

	if( flTime < 0.1 )
	{
		cs16Grenade.pev.nextthink = g_Engine.time;
		cs16Grenade.pev.velocity = g_vecZero;
	}
	cs16Grenade.pev.dmgtime = g_Engine.time + flTime;

	return cs16Grenade;
}

void Register( const string& in szName = DEFAULT_PROJ_NAME )
{
	if( g_CustomEntityFuncs.IsCustomEntity( szName ) )
		return;

	g_CustomEntityFuncs.RegisterCustomEntity( "CS16GRENADEPROJECTILE::CCs16Grenade", szName );
	g_Game.PrecacheOther( szName );
}

}