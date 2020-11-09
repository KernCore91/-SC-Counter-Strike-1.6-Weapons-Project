#include "weapons"
#include "BuyMenu"

void PluginInit()
{
	BuyMenu::RegisterBuyMenuCCVars();
}

void MapInit()
{
	g_CS16Menu.RemoveItems();
	RegisterAll();

	//Melees
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "Badlands Bowie Knife", CS16_KNIFE::GetName(), 100, "melee" ) );
	//Pistols and Handguns
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "Glock 18", CS16_GLOCK18::GetName(), 175, "handgun" ) );
	//Shotguns
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "Leone 12 Gauge Super", CS16_M3::GetName(), 330, "shotgun" ) );
	//Submachine guns
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "Ingram MAC-10", CS16_MAC10::GetName(), 320, "smg" ) );
	//Assault Rifles & Sniper Rifles 
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "GIAT FAMAS F1", CS16_FAMAS::GetName(), 325, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "Steyr Scout", CS16_SCOUT::GetName(), 335, "rifle" ) );
	//Light Machine Guns
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "FN M249 SAW", CS16_M249::GetName(), 600, "lmg" ) );
	//Explosives and Equipment
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "High Explosive Grenade", CS16_HEGRENADE::GetName(), 50, "equip" ) );

	BuyMenu::MoneyInit();
}