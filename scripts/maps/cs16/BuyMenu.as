//Counter-Strike 1.6's Specific BuyMenu
//Author: KernCore, Original script by Solokiller, improved by Zodemon

#include "base"

BuyMenu::BuyMenu g_CS16Menu;

namespace BuyMenu
{

dictionary BuyPoints; // Save the player's current money
dictionary OldScore; // Save the player's score (frags)
const string MoneySignSpr = CS16BASE::MAIN_CSTRIKE_DIR + "640hud7.spr";

//plugin cvars
CCVar@ g_MaxMoney;
CCVar@ g_MoneyPerScore;
CCVar@ g_StartMoney;
//fall back for map_script
const int MaxMoney = 16000;
const int MoneyPerScore = 10;
const int StartMoney = 0;

final class BuyMenuCVARS
{
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

	//Show the Money sign sprite in the player's Hud
	void ShowPointsSprite( CBasePlayer@ pPlayer )
	{
		// Numeric Display
		HUDNumDisplayParams NumDisplayParams;
		NumDisplayParams.channel = 0;
		NumDisplayParams.flags = HUD_ELEM_ABSOLUTE_X | HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_DYNAMIC_ALPHA | HUD_ELEM_EFFECT_ONCE;
		NumDisplayParams.x = 5;
		NumDisplayParams.y = -35;
		NumDisplayParams.spritename = MoneySignSpr;
		NumDisplayParams.defdigits = 0;
		NumDisplayParams.maxdigits = 5;
		NumDisplayParams.left = 192; // Offset
		NumDisplayParams.top = 25; // Offset
		NumDisplayParams.width = 18; // 0: auto; use total width of the sprite
		NumDisplayParams.height = 25; // 0: auto; use total height of the sprite
		NumDisplayParams.color1 = (int(BuyPoints[PlayerID( pPlayer )]) <= 0) ? RGBA_RED : RGBA_SVENCOOP; // Default Sven HUD colors

		if( int(OldScore[PlayerID( pPlayer )]) == int(pPlayer.pev.frags) )
			NumDisplayParams.color2 = RGBA_SVENCOOP; // Default Sven HUD colors
		else if( int(OldScore[PlayerID( pPlayer )]) < int(pPlayer.pev.frags) )
			NumDisplayParams.color2 = RGBA_GREEN; // Default Sven HUD colors
		else if( int(OldScore[PlayerID( pPlayer )]) > int(pPlayer.pev.frags) )
			NumDisplayParams.color2 = RGBA_RED; // Default Sven HUD colors

		NumDisplayParams.fxTime = 0.5;

		if( g_MoneyPerScore is null )
			NumDisplayParams.effect = (int(BuyPoints[PlayerID( pPlayer )]) <= 0 || int(BuyPoints[PlayerID( pPlayer )]) >= MaxMoney) ? HUD_EFFECT_NONE : HUD_EFFECT_RAMP_DOWN;
		else
			NumDisplayParams.effect = (int(BuyPoints[PlayerID( pPlayer )]) <= 0 || int(BuyPoints[PlayerID( pPlayer )]) >= g_MoneyPerScore.GetInt()) ? HUD_EFFECT_NONE : HUD_EFFECT_RAMP_DOWN;

		NumDisplayParams.value = uint(BuyPoints[PlayerID( pPlayer )]);
		g_PlayerFuncs.HudNumDisplay( pPlayer, NumDisplayParams );
	}

	//This method will automatically update the player's points (BuyPoints)
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

	//This will show the player the money hud when first enters the server
	HookReturnCode CS16_ClientPutInServer( CBasePlayer@ pPlayer )
	{
		if( pPlayer is null ) //Null pointer checker
			return HOOK_CONTINUE;

		if( !BuyPoints.exists( PlayerID( pPlayer ) ) )
			BuyPoints[PlayerID( pPlayer )] = (g_StartMoney is null) ? StartMoney : g_StartMoney.GetInt();

		if( !OldScore.exists( PlayerID( pPlayer ) ) )
			OldScore[PlayerID( pPlayer )] = 0;

		ShowPointsSprite( pPlayer );

		return HOOK_CONTINUE;
	}

	//This hook does the work of updating the player every frame, use the method here 
	HookReturnCode CS16_PlayerPostThink( CBasePlayer@ pPlayer )
	{
		if( pPlayer is null ) //Null pointer checker
			return HOOK_CONTINUE;

		UpdatePlayerPoints( pPlayer, int(OldScore[PlayerID( pPlayer )]), int(pPlayer.pev.frags) );

		return HOOK_CONTINUE;
	}

	HookReturnCode CS16_ClientSay( SayParameters@ pParams )
	{
		CBasePlayer@ pPlayer = pParams.GetPlayer();
		const CCommand@ args = pParams.GetArguments();

		if( args.ArgC() == 1 && FirstArgChecker( args ) )
		{
			pParams.ShouldHide = true;
			g_CS16Menu.Show( pPlayer );
		}

		return HOOK_CONTINUE;
	}
}

void RegisterBuyMenuCCVars()
{
	if( g_MaxMoney is null || g_MoneyPerScore is null || g_StartMoney is null ) //Check if they exist first
	{
		//g_Game.AlertMessage( at_console, "CCVars added\n" );
		@g_MaxMoney = CCVar( "bm_maxmoney", MaxMoney, "Maximum money the player can have", ConCommandFlag::AdminOnly ); //as_command cs16.bm_maxmoney
		@g_MoneyPerScore = CCVar( "bm_moneyperscore", MoneyPerScore, "Money the player will earn per score", ConCommandFlag::AdminOnly ); //as_command cs16.bm_moneyperscore
		@g_StartMoney = CCVar( "bm_startmoney", StartMoney, "Money the player will start once he joins the server", ConCommandFlag::AdminOnly ); //as_command cs16.bm_startmoney
	}
}

//Delegate Object
HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
	BuyMenu::BuyMenuCVARS@ g_CS16MenuHooks = @BuyMenu::BuyMenuCVARS();
	return g_CS16MenuHooks.CS16_PlayerPostThink( pPlayer );
}

//Delegate Object
HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	BuyMenu::BuyMenuCVARS@ g_CS16MenuHooks = @BuyMenu::BuyMenuCVARS();
	return g_CS16MenuHooks.CS16_ClientPutInServer( pPlayer );
}

//Delegate Object
HookReturnCode ClientSay( SayParameters@ pParams )
{
	BuyMenu::BuyMenuCVARS@ g_CS16MenuHooks = @BuyMenu::BuyMenuCVARS();
	return g_CS16MenuHooks.CS16_ClientSay( pParams );
}

void MoneyInit()
{
	BuyPoints.deleteAll(); //Comment out to keep the points in map change
	OldScore.deleteAll();  //Comment out to keep the points in map change

	g_Game.PrecacheModel( CS16BASE::MAIN_SPRITE_DIR + BuyMenu::MoneySignSpr );

	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
	//g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

	//g_Game.AlertMessage( at_console, "Hooks Registered\n" );
}

CClientCommand _buy( "buy", "Opens the BuyMenu", @CS16_Buy );

void CS16_Buy( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	if( args.ArgC() == 1 )
	{
		g_CS16Menu.Show( pPlayer );
	}
}

final class BuyableItem
{
	private string m_szDescription;
	private string m_szEntityName;
	private string m_szCategory;
	private string m_szSubCategory;
	private uint m_uiCost = 0;
	private BuyMenu::BuyMenuCVARS@ g_CS16MenuHooks = @BuyMenu::BuyMenuCVARS();

	string Description
	{
		get const { return m_szDescription; }
		set { m_szDescription = value; }
	}

	string EntityName
	{
		get const { return m_szEntityName; }
		set { m_szEntityName = value; }
	}

	string Category
	{
		get const { return m_szCategory; }
		set { m_szCategory = value; }
	}

	string SubCategory
	{
		get const { return m_szSubCategory; }
		set { m_szSubCategory = value; }
	}

	uint Cost
	{
		get const { return m_uiCost; }
		set { m_uiCost = value; }
	}

	BuyableItem( const string& in szDescription, const string& in szEntityName, const uint uiCost, string sCategory, string sSubCategory = "" )
	{
		m_szDescription = "$" + string(uiCost) + " " + szDescription;
		m_szEntityName = szEntityName;
		m_uiCost = uiCost;
		m_szCategory = sCategory;
		m_szSubCategory = sSubCategory;
	}

	void Buy( CBasePlayer@ pPlayer = null )
	{
		GiveItem( pPlayer );
	}

	private void GiveItem( CBasePlayer@ pPlayer ) const
	{
		if( uint(BuyPoints[g_CS16MenuHooks.PlayerID( pPlayer )]) < m_uiCost )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[CS16 BUYMENU] Not enough money to buy: " + m_szEntityName + " - Cost: $" +  m_uiCost + "\n" );
			return;
		}

		if( pPlayer.HasNamedPlayerItem( m_szEntityName ) !is null )
		{
			//KernCore start
			if( !(pPlayer.HasNamedPlayerItem( m_szEntityName ).iFlags() < 0) && pPlayer.HasNamedPlayerItem( m_szEntityName ).iFlags() & ITEM_FLAG_EXHAUSTIBLE != 0 )
			{
				if( pPlayer.GiveAmmo( pPlayer.HasNamedPlayerItem( m_szEntityName ).GetWeaponPtr().m_iDefaultAmmo, m_szEntityName, pPlayer.GetMaxAmmo( m_szEntityName ) ) != -1 )
				{
					//pPlayer.HasNamedPlayerItem( m_szEntityName ).CheckRespawn();
					//pPlayer.HasNamedPlayerItem( m_szEntityName ).AttachToPlayer( pPlayer );
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[CS16 BUYMENU] You bought ammo for: " + m_szEntityName + "\n" );
				}
				else
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[CS16 BUYMENU] You already have max ammo for this item!\n" );
					return;
				}
			}
			else
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[CS16 BUYMENU] You already have that item!\n" );
				return;
			}
			//KernCore end
		}

		if( uint(BuyPoints[g_CS16MenuHooks.PlayerID( pPlayer )]) >= m_uiCost )
		{
			int p = int(BuyPoints[g_CS16MenuHooks.PlayerID( pPlayer )]);
			BuyPoints[g_CS16MenuHooks.PlayerID( pPlayer )] = p - m_uiCost;
			g_CS16MenuHooks.ShowPointsSprite( pPlayer );

			pPlayer.GiveNamedItem( m_szEntityName );
			pPlayer.SelectItem( m_szEntityName );
		}
		else
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[CS16 BUYMENU] Not enough money - Cost: $" + m_uiCost + "\n");
			return;
		}
	}
}

final class BuyMenu
{
	array<BuyableItem@> m_Items;

	//First Menu Object
	private CTextMenu@ m_pMenu      	= null;
	//First Menu Items
	private string szOpenPrimWeapMenu 	= "Melees";
	private string szOpenSecoWeapMenu 	= "Pistols";
	private string szOpenTercWeapMenu 	= "Shotguns";
	private string szOpenQuatWeapMenu 	= "Submachine Guns";
	private string szOpenQuinWeapMenu 	= "Rifles";
	private string szOpenSenaWeapMenu 	= "Machine Guns";
	private string szOpenEquiWeapMenu 	= "Equipment";
	private string szOpenAmmoWeapMenu 	= "Ammo";
	//Primary Menu
	private CTextMenu@ m_pFirstMenu  	= null;
	private CTextMenu@ m_pSecondMenu 	= null;
	private CTextMenu@ m_pThirdMenu  	= null;
	private CTextMenu@ m_pFourthMenu 	= null;
	private CTextMenu@ m_pFifthMenu  	= null;
	private CTextMenu@ m_pSixthMenu  	= null;
	private CTextMenu@ m_pEquipMenu  	= null;
	private CTextMenu@ m_pAmmoMenu   	= null;
	//Ammo Menu
	private CTextMenu@ m_pSecondAMenu 	= null;
	private CTextMenu@ m_pThirdAMenu 	= null;
	private CTextMenu@ m_pFourthAMenu 	= null;
	private CTextMenu@ m_pFifthAMenu 	= null;
	private CTextMenu@ m_pSixthAMenu 	= null;

	void RemoveItems()
	{
		if( m_Items !is null )
		{
			m_Items.removeRange( 0, m_Items.length() );
		}
	}

	void AddItem( BuyableItem@ pItem )
	{
		if( pItem is null )
			return;

		if( m_Items.findByRef( @pItem ) != -1 )
			return;

		m_Items.insertLast( pItem );

		if( m_pMenu !is null )
			@m_pMenu = null;
	}

	void Show( CBasePlayer@ pPlayer = null )
	{
		if( m_pMenu is null )
			CreateMenu();

		if( pPlayer !is null )
			m_pMenu.Open( 0, 0, pPlayer );
	}

	private void CreateMenu()
	{
		//This is the first menu you'll see when opening the Buy Menu Command
		@m_pMenu = CTextMenu( TextMenuPlayerSlotCallback( this.MainCallback ) );
		m_pMenu.SetTitle( "Shop by Category\n" );
		m_pMenu.AddItem( szOpenPrimWeapMenu );
		m_pMenu.AddItem( szOpenSecoWeapMenu );
		m_pMenu.AddItem( szOpenTercWeapMenu );
		m_pMenu.AddItem( szOpenQuatWeapMenu );
		m_pMenu.AddItem( szOpenQuinWeapMenu );
		m_pMenu.AddItem( szOpenSenaWeapMenu );
		m_pMenu.AddItem( szOpenEquiWeapMenu );
		m_pMenu.AddItem( szOpenAmmoWeapMenu );
		m_pMenu.Register();

		//First sub menu to be opened by the player
		@m_pFirstMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pFirstMenu.SetTitle( "Choose Melee (Secondary Weapon)\n" );

		//Second sub menu to be opened by the player
		@m_pSecondMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSecondMenu.SetTitle( "Choose Handgun (Secondary Weapon)\n" );

		//Third sub menu to be opened by the player
		@m_pThirdMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pThirdMenu.SetTitle( "Choose Shotgun (Primary Weapon)\n" );

		//Fourth sub menu to be opened by the player
		@m_pFourthMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pFourthMenu.SetTitle( "Choose SMG (Primary Weapon)\n" );

		//Fifth sub menu to be opened by the player
		@m_pFifthMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pFifthMenu.SetTitle( "Choose Rifle (Primary Weapon)\n" );

		//Sixth sub menu to be opened by the player
		@m_pSixthMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSixthMenu.SetTitle( "Choose Machine Gun (Primary Weapon)\n" );

		//Sixth sub menu to be opened by the player
		@m_pEquipMenu = CTextMenu( TextMenuPlayerSlotCallback( this.EquipCallback ) );
		m_pEquipMenu.SetTitle( "Choose Equipment\n" );

		//Seventh sub menu to be opened by the player
		@m_pAmmoMenu = CTextMenu( TextMenuPlayerSlotCallback( this.MainAmmoCallback ) );
		m_pAmmoMenu.SetTitle( "Shop by Ammo Category\n" );
		m_pAmmoMenu.AddItem( szOpenSecoWeapMenu );
		m_pAmmoMenu.AddItem( szOpenTercWeapMenu );
		m_pAmmoMenu.AddItem( szOpenQuatWeapMenu );
		m_pAmmoMenu.AddItem( szOpenQuinWeapMenu );
		m_pAmmoMenu.AddItem( szOpenSenaWeapMenu );
		m_pAmmoMenu.Register();

		//Sets of Ammo Submenus
		@m_pSecondAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSecondAMenu.SetTitle( "Shop Secondary Ammo\n" );
		@m_pThirdAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pThirdAMenu.SetTitle( "Shop Primary Ammo\n" );
		@m_pFourthAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pFourthAMenu.SetTitle( "Shop Primary Ammo\n" );
		@m_pFifthAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pFifthAMenu.SetTitle( "Shop Primary Ammo\n" );
		@m_pSixthAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSixthAMenu.SetTitle( "Shop Primary Ammo\n" );

		for( uint i = 0; i < m_Items.length(); i++ )
		{
			BuyableItem@ pItem = m_Items[i];
			if( pItem.Category == "melee" )
			{
				m_pFirstMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "handgun" )
			{
				m_pSecondMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "shotgun" )
			{
				m_pThirdMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "smg" )
			{
				m_pFourthMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "rifle" )
			{
				m_pFifthMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "lmg" )
			{
				m_pSixthMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "equip" )
			{
				m_pEquipMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "ammo" )
			{
				if( pItem.SubCategory == "handgun" )
				{
					m_pSecondAMenu.AddItem( pItem.Description, any(@pItem) );
				}
				else if( pItem.SubCategory == "shotgun" )
				{
					m_pThirdAMenu.AddItem( pItem.Description, any(@pItem) );
				}
				else if( pItem.SubCategory == "smg" )
				{
					m_pFourthAMenu.AddItem( pItem.Description, any(@pItem) );
				}
				else if( pItem.SubCategory == "rifle" )
				{
					m_pFifthAMenu.AddItem( pItem.Description, any(@pItem) );
				}
				else if( pItem.SubCategory == "lmg" )
				{
					m_pSixthAMenu.AddItem( pItem.Description, any(@pItem) );
				}
			}
		}

		//Weapon related menus
		m_pFirstMenu.Register();
		m_pSecondMenu.Register();
		m_pThirdMenu.Register();
		m_pFourthMenu.Register();
		m_pFifthMenu.Register();
		m_pSixthMenu.Register();
		m_pEquipMenu.Register();

		//Ammo related menus
		m_pSecondAMenu.Register();
		m_pThirdAMenu.Register();
		m_pFourthAMenu.Register();
		m_pFifthAMenu.Register();
		m_pSixthAMenu.Register();
	}

	private void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == szOpenPrimWeapMenu )
			{
				m_pFirstMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenSecoWeapMenu )
			{
				m_pSecondMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenTercWeapMenu )
			{
				m_pThirdMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenQuatWeapMenu )
			{
				m_pFourthMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenQuinWeapMenu )
			{
				m_pFifthMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenSenaWeapMenu )
			{
				m_pSixthMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenEquiWeapMenu )
			{
				m_pEquipMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenAmmoWeapMenu )
			{
				m_pAmmoMenu.Open( 0, 0, pPlayer );
			}
		}
	}

	private void MainAmmoCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == szOpenSecoWeapMenu )
			{
				m_pSecondAMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenTercWeapMenu )
			{
				m_pThirdAMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenQuatWeapMenu )
			{
				m_pFourthAMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenQuinWeapMenu )
			{
				m_pFifthAMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenSenaWeapMenu )
			{
				m_pSixthAMenu.Open( 0, 0, pPlayer );
			}
		}
	}

	private void AmmoCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;

			pItem.m_pUserData.retrieve( @pBuyItem );

			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );
				//m_pMenu.Open( 0, 0, pPlayer);
			}
		}
	}

	private void EquipCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;

			pItem.m_pUserData.retrieve( @pBuyItem );

			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );

				if( pPlayer.m_rgAmmo( pPlayer.HasNamedPlayerItem( pBuyItem.EntityName ).GetWeaponPtr().m_iPrimaryAmmoType ) != pPlayer.GetMaxAmmo( pBuyItem.EntityName ) )
					m_pEquipMenu.Open( 0, 0, pPlayer);
			}
		}
	}

	private void WeaponCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;

			pItem.m_pUserData.retrieve( @pBuyItem );

			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );
				//m_pMenu.Open( 0, 0, pPlayer);
			}
		}
	}
}

}