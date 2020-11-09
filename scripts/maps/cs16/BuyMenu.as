//Counter-Strike 1.6's Specific BuyMenu
//Author: KernCore, Original script by Solokiller, improved by Zodemon

#include "../base"

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
	BuyMenu::BuyMenuCVARS g_CS16MenuHooks;
	return g_CS16MenuHooks.CS16_PlayerPostThink( pPlayer );
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	BuyMenu::BuyMenuCVARS@ g_CS16MenuHooks = @BuyMenu::BuyMenuCVARS();
	return g_CS16MenuHooks.CS16_ClientPutInServer( pPlayer );
}

void MoneyInit()
{
	BuyPoints.deleteAll(); //Comment out to keep the points in map change
	OldScore.deleteAll();  //Comment out to keep the points in map change

	g_Game.PrecacheModel( "sprites/" + BuyMenu::MoneySignSpr );

	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
	//g_Hooks.RegisterHook( Hooks::Player::ClientSay, @INS2_ClientSay );

	//g_Game.AlertMessage( at_console, "Hooks Registered\n" );
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

	BuyableItem( const string& in szDescription, const string& in szEntityName, const uint uiCost, string sCategory, string sSubCategory )
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

//Primary
const string sSmg	= "Sub Machine Guns";
const string sCbn	= "Carbines";
const string sShg	= "Shotguns";
const string sAsr	= "Assault Rifles";
const string sRfl	= "Rifles";
const string sLmg	= "Light Machine Guns";
const string sLcr	= "Launchers";
//Secondary
const string sMle	= "Melees";
const string sPtl	= "Pistols";
const string sRvl	= "Revolvers";
//Text
const string sChoose	= "Choose";
const string sAmmo  	= "Ammo";

final class BuyMenu
{
	array<BuyableItem@> m_Items;

	private CTextMenu@ m_pMenu      	= null;
	//Primary Menu
	private CTextMenu@ m_pPrimaryMenu 	= null;
	private CTextMenu@ m_pSMGMenu   	= null;
	private CTextMenu@ m_pCARBINEMenu 	= null;
	private CTextMenu@ m_pSHOTGUNMenu 	= null;
	private CTextMenu@ m_pASSAULTMenu 	= null;
	private CTextMenu@ m_pRIFLEMenu 	= null;
	private CTextMenu@ m_pLMGMenu   	= null;
	private CTextMenu@ m_pLAUNCHERMenu 	= null;
	//Secondary Menu
	private CTextMenu@ m_pSecondaryMenu	= null;
	private CTextMenu@ m_pPISTOLMenu 	= null;
	private CTextMenu@ m_pREVOLVERMenu 	= null;
	private CTextMenu@ m_pMELEEMenu 	= null;
	//Equipment Menu
	private CTextMenu@ m_pEquipmentMenu	= null;
	//Ammo Menu
	private CTextMenu@ m_pAmmoMenu  	= null;
	private CTextMenu@ m_pAmPISTOL  	= null;
	private CTextMenu@ m_pAmREVOLVER 	= null;
	private CTextMenu@ m_pAmSMG     	= null;
	private CTextMenu@ m_pAmCARBINE 	= null;
	private CTextMenu@ m_pAmSHOTGUN 	= null;
	private CTextMenu@ m_pAmASSAULT 	= null;
	private CTextMenu@ m_pAmRIFLE   	= null;
	private CTextMenu@ m_pAmLMG     	= null;
	private CTextMenu@ m_pAmLAUNCHER 	= null;

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
		@m_pMenu = CTextMenu( TextMenuPlayerSlotCallback( this.MainCallback ) );
		m_pMenu.SetTitle( "Choose action: " );
		m_pMenu.AddItem( "Buy primary weapon", null );
		m_pMenu.AddItem( "Buy secondary weapon", null );
		m_pMenu.AddItem( "Buy equipment", null );
		m_pMenu.AddItem( "Buy ammo" );
		m_pMenu.Register();

		@m_pPrimaryMenu = CTextMenu( TextMenuPlayerSlotCallback( this.PrimaryCallback ) );
		m_pPrimaryMenu.SetTitle( sChoose + " primary weapon category: " );
		m_pPrimaryMenu.AddItem( sSmg, null );
		m_pPrimaryMenu.AddItem( sCbn, null );
		m_pPrimaryMenu.AddItem( sShg, null );
		m_pPrimaryMenu.AddItem( sAsr, null );
		m_pPrimaryMenu.AddItem( sRfl, null );
		m_pPrimaryMenu.AddItem( sLmg, null );
		m_pPrimaryMenu.AddItem( sLcr, null );
		m_pPrimaryMenu.Register();

		@m_pSecondaryMenu = CTextMenu( TextMenuPlayerSlotCallback( this.SecondaryCallback ) );
		m_pSecondaryMenu.SetTitle( sChoose + " secondary weapon category: " );
		m_pSecondaryMenu.AddItem( sMle, null );
		m_pSecondaryMenu.AddItem( sPtl, null );
		m_pSecondaryMenu.AddItem( sRvl, null );
		m_pSecondaryMenu.Register();

	// Equipment
		@m_pEquipmentMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pEquipmentMenu.SetTitle( sChoose + " equipment: " );
	// Ammo
		@m_pAmmoMenu = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCatCallBack ) );
		m_pAmmoMenu.SetTitle( sChoose + " Ammo: " );
		m_pAmmoMenu.AddItem( sPtl );
		m_pAmmoMenu.AddItem( sRvl );
		m_pAmmoMenu.AddItem( sSmg );
		m_pAmmoMenu.AddItem( sCbn );
		m_pAmmoMenu.AddItem( sShg );
		m_pAmmoMenu.AddItem( sAsr );
		m_pAmmoMenu.AddItem( sRfl );
		m_pAmmoMenu.AddItem( sLmg );
		m_pAmmoMenu.AddItem( sLcr );
	//Primary Menu
		// SMG
		@m_pSMGMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSMGMenu.SetTitle( sChoose + " " + sSmg + ": " );
		@m_pAmSMG = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmSMG.SetTitle( sChoose + " " + sSmg + " " + sAmmo + ": " );
		// Carbine
		@m_pCARBINEMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pCARBINEMenu.SetTitle( sChoose + " " + sCbn + ": " );
		@m_pAmCARBINE = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmCARBINE.SetTitle( sChoose + " " + sCbn + " " + sAmmo + ": " );
		// Shotgun
		@m_pSHOTGUNMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSHOTGUNMenu.SetTitle( sChoose + " " + sShg + ": " );
		@m_pAmSHOTGUN = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmSHOTGUN.SetTitle( sChoose + " " + sShg + " " + sAmmo + ": " );
		// Assault Rifle
		@m_pASSAULTMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pASSAULTMenu.SetTitle( sChoose + " " + sAsr + ": " );
		@m_pAmASSAULT = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmASSAULT.SetTitle( sChoose + " " + sAsr + " " + sAmmo + ": " );
		// Rifle (Bolt Action/Semi Auto/Sniper)
		@m_pRIFLEMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pRIFLEMenu.SetTitle( sChoose + " " + sRfl + ": " );
		@m_pAmRIFLE = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmRIFLE.SetTitle( sChoose + " " + sRfl + " " + sAmmo + ": " );
		// Light Machine Gun
		@m_pLMGMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pLMGMenu.SetTitle( sChoose + " " + sLmg + ": " );
		@m_pAmLMG = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmLMG.SetTitle( sChoose + " " + sLmg + " " + sAmmo + ": " );
		// Launchers (Anti-Tank, Grenade Launcher, Bazooka)
		@m_pLAUNCHERMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pLAUNCHERMenu.SetTitle( sChoose + " " + sLcr + ": " );
		@m_pAmLAUNCHER = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmLAUNCHER.SetTitle( sChoose + " " + sLcr + " " + sAmmo + ": " );
	//Secondary menu
		// Melee
		@m_pMELEEMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pMELEEMenu.SetTitle( sChoose + " " + sMle + ": " );
		// Pistol
		@m_pPISTOLMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pPISTOLMenu.SetTitle( sChoose + " " + sPtl + ": " );
		@m_pAmPISTOL = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmPISTOL.SetTitle( sChoose + " " + sPtl + " " + sAmmo + ": " );
		// Revolver
		@m_pREVOLVERMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pREVOLVERMenu.SetTitle( sChoose + " " + sRvl + ": " );
		@m_pAmREVOLVER = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmREVOLVER.SetTitle( sChoose + " " + sRvl + " " + sAmmo + ": " );

		for( uint i = 0; i < m_Items.length(); i++ )
		{
			BuyableItem@ pItem = m_Items[i];
			if( pItem.Category == "primary" )
			{
				if( pItem.SubCategory == "smg" )
					m_pSMGMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "carbine" )
					m_pCARBINEMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "shotgun" )
					m_pSHOTGUNMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "assault" )
					m_pASSAULTMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "rifle" || pItem.SubCategory == "sniper" )
					m_pRIFLEMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "lmg" )
					m_pLMGMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "launcher" )
					m_pLAUNCHERMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "secondary" )
			{
				if( pItem.SubCategory == "melee" )
					m_pMELEEMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "pistol" )
					m_pPISTOLMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "revolver" )
					m_pREVOLVERMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "equipment" )
				m_pEquipmentMenu.AddItem( pItem.Description, any(@pItem) );
			else if( pItem.Category == "ammo" )
			{
				if( pItem.SubCategory == "pistol" )
					m_pAmPISTOL.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "revolver" )
					m_pAmREVOLVER.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "smg" )
					m_pAmSMG.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "carbine" )
					m_pAmCARBINE.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "shotgun" )
					m_pAmSHOTGUN.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "assault" )
					m_pAmASSAULT.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "rifle" || pItem.SubCategory == "sniper" )
					m_pAmRIFLE.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "lmg" )
					m_pAmLMG.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "launcher" )
					m_pAmLAUNCHER.AddItem( pItem.Description, any(@pItem) );
			}
		}

		m_pEquipmentMenu.Register();
		m_pAmmoMenu.Register();
		//Primary
		m_pSMGMenu.Register();
		m_pCARBINEMenu.Register();
		m_pSHOTGUNMenu.Register();
		m_pASSAULTMenu.Register();
		m_pRIFLEMenu.Register();
		m_pLMGMenu.Register();
		m_pLAUNCHERMenu.Register();
		//Secondary
		m_pMELEEMenu.Register();
		m_pPISTOLMenu.Register();
		m_pREVOLVERMenu.Register();
		//Ammo categories
		m_pAmPISTOL.Register();
		m_pAmREVOLVER.Register();
		m_pAmSMG.Register();
		m_pAmCARBINE.Register();
		m_pAmSHOTGUN.Register();
		m_pAmASSAULT.Register();
		m_pAmRIFLE.Register();
		m_pAmLMG.Register();
		m_pAmLAUNCHER.Register();
	}

	private void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == "Buy primary weapon" )
				m_pPrimaryMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Buy secondary weapon" )
				m_pSecondaryMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Buy equipment" )
				m_pEquipmentMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Buy ammo" )
				m_pAmmoMenu.Open( 0, 0, pPlayer );
		}
	}

	private void PrimaryCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == sSmg )
				m_pSMGMenu.Open( 0, 0, pPlayer );
			else if( sChoice == sCbn )
				m_pCARBINEMenu.Open( 0, 0, pPlayer );
			else if( sChoice == sShg )
				m_pSHOTGUNMenu.Open( 0, 0, pPlayer );
			else if( sChoice == sAsr )
				m_pASSAULTMenu.Open( 0, 0, pPlayer );
			else if( sChoice == sRfl )
				m_pRIFLEMenu.Open( 0, 0, pPlayer );
			else if( sChoice == sLmg )
				m_pLMGMenu.Open( 0, 0, pPlayer );
			else if( sChoice == sLcr )
				m_pLAUNCHERMenu.Open( 0, 0, pPlayer );
		}
	}

	private void SecondaryCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == sMle )
				m_pMELEEMenu.Open( 0, 0, pPlayer );
			else if( sChoice == sPtl )
				m_pPISTOLMenu.Open( 0, 0, pPlayer );
			else if( sChoice == sRvl )
				m_pREVOLVERMenu.Open( 0, 0, pPlayer );
		}
	}

	private void AmmoCatCallBack( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;

			if( sChoice == sPtl )
				m_pAmPISTOL.Open( 0, 0, pPlayer );
			else if( sChoice == sRvl )
				m_pAmREVOLVER.Open( 0, 0, pPlayer );
			else if( sChoice == sSmg )
				m_pAmSMG.Open( 0, 0, pPlayer );
			else if( sChoice == sCbn )
				m_pAmCARBINE.Open( 0, 0, pPlayer );
			else if( sChoice == sShg )
				m_pAmSHOTGUN.Open( 0, 0, pPlayer );
			else if( sChoice == sAsr )
				m_pAmASSAULT.Open( 0, 0, pPlayer );
			else if( sChoice == sRfl )
				m_pAmRIFLE.Open( 0, 0, pPlayer );
			else if( sChoice == sLmg )
				m_pAmLMG.Open( 0, 0, pPlayer );
			else if( sChoice == sLcr )
				m_pAmLAUNCHER.Open( 0, 0, pPlayer );
		}
	}

	private void AmmoCallBack( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;

			pItem.m_pUserData.retrieve( @pBuyItem );

			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );
				menu.Open( 0, 0, pPlayer );
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