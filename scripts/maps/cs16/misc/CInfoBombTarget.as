// Counter-Strike 1.6's Info Bomb Target
// Author: Nero, KernCore (Adapting to another base)

namespace CS16_BOMBTARGET
{

string ENTITY_NAME  	= "info_bomb_target";
bool USE_BOMB_ZONES 	= false;//Set this to true to only allow the C4 to be placed within range of an info_bomb_target
const string INBOMB_KV 	= "$i_inBombZone";

class CInfoBombTarget : ScriptBaseEntity
{
	private float m_flRadius = 256;
	private int m_iVisible = 0, m_iRingType = 1;
	private string SPRITE_RING = "sprites/laserbeam.spr";
	private int m_iRingSprite;
	private array<int> m_iRingColor =
	{
		250,
		179,
		209,
		100
	};

	CustomKeyvalues@ pCustom;

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "radius" )
		{
			m_flRadius = abs( atof( szValue ) );
			return true;
		}
		else if( szKey == "visible" )
		{
			m_iVisible = atoi(szValue);
			return true;
		}
		else if( szKey == "ringtype" )
		{
			m_iRingType = Math.clamp( 1, 3, atoi(szValue) );
			return true;
		}
		else if( szKey == "color" )
		{
			for( uint i = 0; i <= 3; i++ )
				m_iRingColor[i] = Math.clamp( 0, 255, atoi(szValue.Split( " " )[i]) );

			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}

	void Spawn()
	{
		Precache();

		self.pev.solid = SOLID_NOT;
		SetThink( ThinkFunction( this.BombTargetThink ) );
		pev.nextthink = g_Engine.time + 0.1f;

		g_EntityFuncs.SetOrigin( self, pev.origin );
	}

	void Precache()
	{
		BaseClass.Precache();
		m_iRingSprite = g_Game.PrecacheModel( SPRITE_RING );
	}

	void BombTargetThink()
	{
		if( m_iVisible == 1 )
		{
			if( m_iRingType == 1 )
			{
				NetworkMessage ringmsg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, pev.origin );
					ringmsg.WriteByte( TE_BEAMDISK );
					ringmsg.WriteCoord( pev.origin.x );//center position
					ringmsg.WriteCoord( pev.origin.y );//center position
					ringmsg.WriteCoord( pev.origin.z );//center position
					ringmsg.WriteCoord( pev.origin.x );//axis and radius
					ringmsg.WriteCoord( pev.origin.y );//axis and radius
					ringmsg.WriteCoord( pev.origin.z + m_flRadius );//radius
					ringmsg.WriteShort( m_iRingSprite );
					ringmsg.WriteByte( 0 );//starting frame
					ringmsg.WriteByte( 0 );//frame rate
					ringmsg.WriteByte( int(m_flRadius/23) );//life
					ringmsg.WriteByte( 32 );//line width
					ringmsg.WriteByte( 0 );//noise
					ringmsg.WriteByte( m_iRingColor[0] );//red
					ringmsg.WriteByte( m_iRingColor[1] );//green
					ringmsg.WriteByte( m_iRingColor[2] );//blue
					ringmsg.WriteByte( m_iRingColor[3] );//brightness
					ringmsg.WriteByte( 0 );//scroll speed
				ringmsg.End();
			}
			else if( m_iRingType == 2 )
			{
				NetworkMessage ringmsg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, pev.origin );
					ringmsg.WriteByte( TE_BEAMCYLINDER );
					ringmsg.WriteCoord( pev.origin.x );//center position
					ringmsg.WriteCoord( pev.origin.y );//center position
					ringmsg.WriteCoord( pev.origin.z );//center position
					ringmsg.WriteCoord( pev.origin.x );//axis and radius
					ringmsg.WriteCoord( pev.origin.y );//axis and radius
					ringmsg.WriteCoord( pev.origin.z + m_flRadius );//radius
					ringmsg.WriteShort( m_iRingSprite );
					ringmsg.WriteByte( 0 );//starting frame
					ringmsg.WriteByte( 0 );//frame rate
					ringmsg.WriteByte( int(m_flRadius/25) );//life
					ringmsg.WriteByte( 32 );//line width
					ringmsg.WriteByte( 0 );//noise
					ringmsg.WriteByte( m_iRingColor[0] );//red
					ringmsg.WriteByte( m_iRingColor[1] );//green
					ringmsg.WriteByte( m_iRingColor[2] );//blue
					ringmsg.WriteByte( m_iRingColor[3] );//brightness
					ringmsg.WriteByte( 0 );//scroll speed
				ringmsg.End();
			}
			else if( m_iRingType == 3 )
			{
				NetworkMessage ringmsg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
					ringmsg.WriteByte( TE_BEAMTORUS );
					ringmsg.WriteCoord( pev.origin.x );//center position
					ringmsg.WriteCoord( pev.origin.y );//center position
					ringmsg.WriteCoord( pev.origin.z );//center position
					ringmsg.WriteCoord( pev.origin.x );//axis and radius
					ringmsg.WriteCoord( pev.origin.y );//axis and radius
					ringmsg.WriteCoord( pev.origin.z + m_flRadius );//radius
					ringmsg.WriteShort( m_iRingSprite );
					ringmsg.WriteByte( 0 );//starting frame
					ringmsg.WriteByte( 16 );//frame rate
					ringmsg.WriteByte( int(m_flRadius/24) );//life
					ringmsg.WriteByte( 8 );//line width
					ringmsg.WriteByte( 0 );//noise
					ringmsg.WriteByte( m_iRingColor[0] );//red
					ringmsg.WriteByte( m_iRingColor[1] );//green
					ringmsg.WriteByte( m_iRingColor[2] );//blue
					ringmsg.WriteByte( m_iRingColor[3] );//brightness
					ringmsg.WriteByte( 0 );//scroll speed
				ringmsg.End();
			}
		}

		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			if( (pPlayer.pev.origin - pev.origin).Length() <= m_flRadius )
			{
				@pCustom = pPlayer.GetCustomKeyvalues();
				pCustom.SetKeyvalue( INBOMB_KV, 1 );
			}
			else
			{
				@pCustom = pPlayer.GetCustomKeyvalues();
				pCustom.SetKeyvalue( INBOMB_KV, 0 );
			}			
		}

		pev.nextthink = g_Engine.time + 0.1f;
	}

	void UpdateOnRemove()
	{
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			@pCustom = pPlayer.GetCustomKeyvalues();
			pCustom.SetKeyvalue( INBOMB_KV, 0 );
		}
	}
}

void Register()
{
	if( g_CustomEntityFuncs.IsCustomEntity( ENTITY_NAME ) )
		return;

	g_CustomEntityFuncs.RegisterCustomEntity( "CS16_BOMBTARGET::CInfoBombTarget", ENTITY_NAME );
	g_Game.PrecacheOther( ENTITY_NAME );
}

}