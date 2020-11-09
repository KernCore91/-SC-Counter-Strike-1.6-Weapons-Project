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
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( "Glock 18", CS16_GLOCK18::GetName(), 200, "handgun" ) );

	BuyMenu::MoneyInit();
}