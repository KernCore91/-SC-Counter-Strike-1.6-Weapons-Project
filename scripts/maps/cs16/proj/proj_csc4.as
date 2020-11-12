// Counter-Strike 1.6's C4 Projectile Base
// Author: Nero, KernCore (Adapting to another base)

#include "../base"

namespace CS16C4PROJECTILE
{

string DEFAULT_PROJ_NAME 	= "proj_cs16c4";
string EXPLODE_SOUND    	= "cs16/c4/boom.wav";//c4_explode1
string BEEP_SOUND       	= "cs16/c4/beep.wav";//c4_click
float DEFAULT_TIMER     	= 35;//45 by default
int BOMB_RADIUS         	= 750;

class CCs16C4 : ScriptBaseEntity
{
	private float m_flSoundTime;
	private int m_iExplodeSprite;
	private int m_iExplodeSprite2;
	private int m_iExplodeSprite3;
	private int m_iSteamSprite;
	private int m_iGlowSprite;
	float m_flNextBlink;
	float m_flBeepTime;

	void Spawn()
	{
		Precache();
		self.pev.movetype = MOVETYPE_TOSS;
		self.pev.solid = SOLID_BBOX;

		SetThink( ThinkFunction( this.PlantThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;

		g_EntityFuncs.SetSize( self.pev, Vector( -3, -6, 0 ), Vector( 3, 6, 8 ) );
	}

	void Precache()
	{
		//Models
		m_iExplodeSprite 	= g_Game.PrecacheModel( "sprites/fexplo.spr" );
		m_iExplodeSprite2	= g_Game.PrecacheModel( "sprites/eexplo.spr" );
		m_iExplodeSprite3	= g_Game.PrecacheModel( "sprites/zerogxplode.spr" );
		m_iSteamSprite   	= g_Game.PrecacheModel( "sprites/steam1.spr" );
		m_iGlowSprite   	= g_Game.PrecacheModel( "sprites/ledglow.spr" );
		//Sounds
		CS16BASE::PrecacheSound( EXPLODE_SOUND );
		CS16BASE::PrecacheSound( BEEP_SOUND );
	}

	void PlantTouch( CBaseEntity@ pOther ) {}

	void PlantThink()
	{
		//SetThink( null );

		if( self.pev.dmgtime <= g_Engine.time )
		{
			SetThink( ThinkFunction( this.Detonate ) );
			self.pev.nextthink = g_Engine.time + self.pev.dmgtime;
		}

		if( g_Engine.time >= m_flSoundTime )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, BEEP_SOUND, 1, ATTN_NORM );
			m_flSoundTime = g_Engine.time + (m_flBeepTime / 10);
		}

		if( g_Engine.time >= m_flNextBlink )
		{
			m_flNextBlink = g_Engine.time + 2;

			NetworkMessage c4glow( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin() );
				c4glow.WriteByte( TE_GLOWSPRITE );
				c4glow.WriteCoord( self.GetOrigin().x );
				c4glow.WriteCoord( self.GetOrigin().y );
				c4glow.WriteCoord( self.GetOrigin().z + 5 );
				c4glow.WriteShort( m_iGlowSprite );
				c4glow.WriteByte( 1 );
				c4glow.WriteByte( 3 );
				c4glow.WriteByte( 255 );
			c4glow.End();
		}

		m_flBeepTime -= 0.1f;
		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void Explode( TraceResult& in pTrace )
	{
		self.pev.model = string_t();
		self.pev.solid = SOLID_NOT;
		self.pev.takedamage = DAMAGE_NO;
		g_PlayerFuncs.ScreenShake( pTrace.vecEndPos, 25, 150, 1, 3000 );

		entvars_t@ pevOwner;
		if( self.pev.owner !is null )
			@pevOwner = @self.pev.owner.vars;
		else
			@pevOwner = self.pev;

		int iContents = g_EngineFuncs.PointContents( self.GetOrigin() );

		NetworkMessage c4_ex1( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin() );
			c4_ex1.WriteByte( TE_SPRITE );
			c4_ex1.WriteCoord( self.GetOrigin().x );
			c4_ex1.WriteCoord( self.GetOrigin().y );
			c4_ex1.WriteCoord( self.GetOrigin().z - 10 );
			c4_ex1.WriteShort( m_iExplodeSprite );
			c4_ex1.WriteByte( int(self.pev.dmg - 275) );
			c4_ex1.WriteByte( 150 );
		c4_ex1.End();

		NetworkMessage c4_ex2( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin() );
			c4_ex2.WriteByte( TE_SPRITE );
			c4_ex2.WriteCoord( self.GetOrigin().x + Math.RandomFloat( -512, 512 ) );
			c4_ex2.WriteCoord( self.GetOrigin().y + Math.RandomFloat( -512, 512 ) );
			c4_ex2.WriteCoord( self.GetOrigin().z + Math.RandomFloat( -10, 10 ) );
			c4_ex2.WriteShort( m_iExplodeSprite2 );
			c4_ex2.WriteByte( int(self.pev.dmg - 275) );
			c4_ex2.WriteByte( 150 );
		c4_ex2.End();

		NetworkMessage c4_ex3( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin() );
			c4_ex3.WriteByte( TE_SPRITE );
			c4_ex3.WriteCoord( self.GetOrigin().x + Math.RandomFloat( -512, 512 ) );
			c4_ex3.WriteCoord( self.GetOrigin().y + Math.RandomFloat( -512, 512 ) );
			c4_ex3.WriteCoord( self.GetOrigin().z + Math.RandomFloat( -10, 10 ) );
			c4_ex3.WriteShort( m_iExplodeSprite );
			c4_ex3.WriteByte( int(self.pev.dmg - 275) );
			c4_ex3.WriteByte( 150 );
		c4_ex3.End();

		NetworkMessage c4_ex4( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin() );
			c4_ex4.WriteByte( TE_SPRITE );
			c4_ex4.WriteCoord( self.GetOrigin().x + Math.RandomFloat( -512, 512 ) );
			c4_ex4.WriteCoord( self.GetOrigin().y + Math.RandomFloat( -512, 512 ) );
			c4_ex4.WriteCoord( self.GetOrigin().z + Math.RandomFloat( -10, 10 ) );
			c4_ex4.WriteShort( m_iExplodeSprite3 );
			c4_ex4.WriteByte( int(self.pev.dmg - 275) );
			c4_ex4.WriteByte( 17 );
		c4_ex4.End();

		g_SoundSystem.EmitSound( self.edict(), CHAN_WEAPON, EXPLODE_SOUND, 1, 0 );
		g_WeaponFuncs.RadiusDamage( self.GetOrigin(), self.pev, pevOwner, self.pev.dmg, BOMB_RADIUS, CLASS_NONE, DMG_BLAST );
		g_Utility.DecalTrace( pTrace, (Math.RandomLong( 0, 1 ) < 0.5) ? DECAL_SCORCH1 : DECAL_SCORCH2 );

		switch( Math.RandomLong( 0, 2 ) )
		{
			case 0: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/debris1.wav", 0.55f, ATTN_NORM ); break;
			case 1: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/debris2.wav", 0.55f, ATTN_NORM ); break;
			case 2: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/debris3.wav", 0.55f, ATTN_NORM ); break;
		}

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
			NetworkMessage smk_msg( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.GetOrigin() );
				smk_msg.WriteByte( TE_SMOKE ); //MSG type enum
				smk_msg.WriteCoord( self.GetOrigin().x ); //pos
				smk_msg.WriteCoord( self.GetOrigin().y ); //pos
				smk_msg.WriteCoord( self.GetOrigin().z ); //pos
				smk_msg.WriteShort( m_iSteamSprite );
				smk_msg.WriteByte( 150 ); //scale
				smk_msg.WriteByte( 8 ); //framerate
			smk_msg.End();
		}
	}

	void Detonate()
	{
		TraceResult tr;
		Vector vecSpot = self.GetOrigin() + Vector( 0, 0, 8 ); // trace starts here!
		g_Utility.TraceLine( vecSpot, vecSpot + Vector( 0, 0, -40 ), ignore_monsters, self.pev.pContainingEntity, tr );
		Explode( tr );
	}

	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		Detonate();
	}
}

CCs16C4@ PlantC4( entvars_t@ pevOwner, Vector vecOrigin, Vector vecAngles, float flTime, float flDmg, string sModel, const string& in szName = DEFAULT_PROJ_NAME )
{
	CBaseEntity@ cbeCS16C4 = g_EntityFuncs.CreateEntity( szName );
	CCs16C4@ cs16C4 = cast<CCs16C4@>( CastToScriptClass( cbeCS16C4 ) );

	g_EntityFuncs.SetOrigin( cs16C4.self, vecOrigin );
	g_EntityFuncs.SetModel( cs16C4.self, sModel );
	g_EntityFuncs.DispatchSpawn( cs16C4.self.edict() );
	@cs16C4.pev.owner = CS16BASE::ENT( pevOwner );

	cs16C4.pev.velocity = g_vecZero;
	cs16C4.pev.angles = vecAngles;

	cs16C4.pev.dmgtime = g_Engine.time + flTime;
	cs16C4.pev.dmg = flDmg;

	if( cs16C4.pev.dmgtime - g_Engine.time <= 10.0f )
		cs16C4.m_flBeepTime = 5;
	else
		cs16C4.m_flBeepTime = flTime;

	cs16C4.m_flNextBlink = g_Engine.time + 2;

	cs16C4.SetTouch( TouchFunction( cs16C4.PlantTouch ) );

	return cs16C4;
}

void Register( const string& in szName = DEFAULT_PROJ_NAME )
{
	if( g_CustomEntityFuncs.IsCustomEntity( szName ) )
		return;

	g_CustomEntityFuncs.RegisterCustomEntity( "CS16C4PROJECTILE::CCs16C4", szName );
	g_Game.PrecacheOther( szName );
}

}