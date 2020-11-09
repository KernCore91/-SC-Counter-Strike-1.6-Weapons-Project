#include "weapons"
#include "BuyMenu"

void PluginInit()
{
	BuyMenu::RegisterBuyMenuCCVars();
}

void MapInit()
{
	RegisterAll();
	BuyMenu::MoneyInit();
}