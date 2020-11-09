//Counter-Strike 1.6's Specific BuyMenu
//Author: KernCore, Original script by Solokiller, improved by Zodemon

BuyMenu::BuyMenu g_CS16Menu;

namespace BuyMenu
{

dictionary BuyPoints; // Save the player's current money
dictionary OldScore; // Save the player's score (frags)

//plugin cvars
CCVar@ g_MaxMoney;
CCVar@ g_MoneyPerScore;
CCVar@ g_StartMoney;
//fall back for map_script
const int MaxMoney = 16000;
const int MoneyPerScore = 10;
const int StartMoney = 0;

// Stop using comprar/shop in my buymenus, typing 'buy' is way better than typing 7/4 letters
bool FirstArgChecker( const CCommand@ args )
{
	return args.Arg(0).ToLowercase() == "buy" 
		|| args.Arg(0).ToLowercase() == "/buy" 
		|| args.Arg(0).ToLowercase() == "!buy" 
		|| args.Arg(0).ToLowercase() == ".buy" 
		|| args.Arg(0).ToLowercase() == "\\buy" 
		|| args.Arg(0).ToLowercase() == "#buy";
}

string PlayerID( CBasePlayer@ pPlayer )
{
	return g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
}

void RegisterBuyMenuCCVars()
{
	if( g_MaxMoney is null || g_MoneyPerScore is null || g_StartMoney is null ) //Check if they exist first
	{
		//g_Game.AlertMessage( at_console, "CCVars added\n" );
		@g_MaxMoney = CCVar( "bm_maxmoney", MaxMoney, "Maximum money the player can have", ConCommandFlag::AdminOnly ); //as_command ins2.bm_maxmoney
		@g_MoneyPerScore = CCVar( "bm_moneyperscore", MoneyPerScore, "Money the player will earn per score", ConCommandFlag::AdminOnly ); //as_command ins2.bm_moneyperscore
		@g_StartMoney = CCVar( "bm_startmoney", StartMoney, "Money the player will start once he joins the server", ConCommandFlag::AdminOnly ); //as_command ins2.bm_startmoney
	}
}

void UpdatePlayerPoints( CBasePlayer@ pPlayer, int &in iOldScore, int &in iFrags )
{
	if( iOldScore < iFrags || iOldScore > iFrags )
	{
		int dict = uint(BuyPoints[PlayerID( pPlayer )]);

		//Check if g_MoneyPerScore exists, if it doesn't, use constant MoneyPerScore
		if( g_MoneyPerScore is null )
		{
			if( OldScore.exists( PlayerID( pPlayer ) ) && iOldScore > 0 && pPlayer.pev.frags == 0 ) //Player just reconnected, let him stay with the money
			{

			}
			else if( BuyPoints.exists( PlayerID( pPlayer ) ) && pPlayer.pev.frags != 0 )
			{
				BuyPoints[PlayerID( pPlayer )] = dict + (iFrags - iOldScore) * MoneyPerScore;
			}
		}
		else
		{
			if( OldScore.exists( PlayerID( pPlayer ) ) && iOldScore > 0 && pPlayer.pev.frags == 0 ) //Player just reconnected, let him stay with the money
			{

			}
			else if( BuyPoints.exists( PlayerID( pPlayer ) ) && pPlayer.pev.frags != 0 )
			{
				BuyPoints[PlayerID( pPlayer )] = dict + (iFrags - iOldScore) * g_MoneyPerScore.GetInt();
			}
		}

		if( int(BuyPoints[PlayerID( pPlayer )]) <= 0 )
		{
			BuyPoints[PlayerID( pPlayer )] = 0;
		}

		if( g_MaxMoney is null )
		{
			if( int(BuyPoints[PlayerID( pPlayer )]) > MaxMoney )
				BuyPoints[PlayerID( pPlayer )] = MaxMoney;
		}
		else
		{
			if( int(BuyPoints[PlayerID( pPlayer )]) > g_MaxMoney.GetInt() )
				BuyPoints[PlayerID( pPlayer )] = g_MaxMoney.GetInt();
		}

		ShowPointsSprite( pPlayer );
		OldScore[PlayerID( pPlayer )] = iFrags;
	}
}

}