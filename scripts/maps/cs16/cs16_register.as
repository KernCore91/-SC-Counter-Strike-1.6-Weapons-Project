#include "weapons"
#include "BuyMenu"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "D.N.I.O. 071/R4to0/KernCore" );
	g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/0wtJ6aAd7XOGI6vI" );

	//Change each weapon's iPosition here so they don't conflict with Map's weapons
	//Melees
	CS16_KNIFE::POSITION 		= 10;
	//Pistols
	CS16_GLOCK18::POSITION 		= 10;
	CS16_USP::POSITION 			= 11;
	CS16_P228::POSITION 		= 12;
	CS16_57::POSITION 			= 13;
	CS16_ELITES::POSITION 		= 14;
	CS16_DEAGLE::POSITION 		= 15;
	//Shotguns
	CS16_M3::POSITION 			= 10;
	CS16_XM1014::POSITION 		= 11;
	//Submachine Guns
	CS16_MAC10::POSITION 		= 10;
	CS16_TMP::POSITION 			= 11;
	CS16_MP5::POSITION 			= 12;
	CS16_UMP45::POSITION 		= 13;
	CS16_P90::POSITION 			= 14;
	//Assault Rifles
	CS16_FAMAS::POSITION 		= 10;
	CS16_GALIL::POSITION 		= 11;
	CS16_AK47::POSITION 		= 12;
	CS16_M4A1::POSITION 		= 13;
	CS16_AUG::POSITION 			= 14;
	CS16_SG552::POSITION 		= 15;
	//Sniper Rifles
	CS16_SCOUT::POSITION 		= 10;
	CS16_AWP::POSITION 			= 11;
	CS16_SG550::POSITION 		= 12;
	CS16_G3SG1::POSITION 		= 13;
	//Light Machine Guns
	CS16_M249::POSITION 		= 10;
	//Misc
	CS16_HEGRENADE::POSITION 	= 10;
	CS16_C4::POSITION 			= 11;

	//Register Buy menu stuff
	BuyMenu::RegisterBuyMenuCCVars();
}

void MapInit()
{
	g_CS16Menu.RemoveItems();

	//Helper method to register all weapons
	RegisterAll();

	//Melees
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_KNIFE::WPN_NAME, CS16_KNIFE::GetName(), CS16_KNIFE::WPN_PRICE, "melee" ) );


	//Pistols and Handguns
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_GLOCK18::WPN_NAME, CS16_GLOCK18::GetName(), CS16_GLOCK18::WPN_PRICE, "handgun" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_GLOCK18::AMMO_NAME, CS16_GLOCK18::GetAmmoName(), CS16_GLOCK18::AMMO_PRICE, "ammo", "handgun" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_USP::WPN_NAME, CS16_USP::GetName(), CS16_USP::WPN_PRICE, "handgun" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_USP::AMMO_NAME, CS16_USP::GetAmmoName(), CS16_USP::AMMO_PRICE, "ammo", "handgun" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_P228::WPN_NAME, CS16_P228::GetName(), CS16_P228::WPN_PRICE, "handgun" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_P228::AMMO_NAME, CS16_P228::GetAmmoName(), CS16_P228::AMMO_PRICE, "ammo", "handgun" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_57::WPN_NAME, CS16_57::GetName(), CS16_57::WPN_PRICE, "handgun" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_57::AMMO_NAME, CS16_57::GetAmmoName(), CS16_57::AMMO_PRICE, "ammo", "handgun" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_ELITES::WPN_NAME, CS16_ELITES::GetName(), CS16_ELITES::WPN_PRICE, "handgun" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_ELITES::AMMO_NAME, CS16_ELITES::GetAmmoName(), CS16_ELITES::AMMO_PRICE, "ammo", "handgun" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_DEAGLE::WPN_NAME, CS16_DEAGLE::GetName(), CS16_DEAGLE::WPN_PRICE, "handgun" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_DEAGLE::AMMO_NAME, CS16_DEAGLE::GetAmmoName(), CS16_DEAGLE::AMMO_PRICE, "ammo", "handgun" ) );


	//Shotguns
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_M3::WPN_NAME, CS16_M3::GetName(), CS16_M3::WPN_PRICE, "shotgun" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_M3::AMMO_NAME, CS16_M3::GetAmmoName(), CS16_M3::AMMO_PRICE, "ammo", "shotgun" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_XM1014::WPN_NAME, CS16_XM1014::GetName(), CS16_XM1014::WPN_PRICE, "shotgun" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_XM1014::AMMO_NAME, CS16_XM1014::GetAmmoName(), CS16_XM1014::AMMO_PRICE, "ammo", "shotgun" ) );


	//Submachine guns
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_MAC10::WPN_NAME, CS16_MAC10::GetName(), CS16_MAC10::WPN_PRICE, "smg" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_MAC10::AMMO_NAME, CS16_MAC10::GetAmmoName(), CS16_MAC10::AMMO_PRICE, "ammo", "smg" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_TMP::WPN_NAME, CS16_TMP::GetName(), CS16_TMP::WPN_PRICE, "smg" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_TMP::AMMO_NAME, CS16_TMP::GetAmmoName(), CS16_TMP::AMMO_PRICE, "ammo", "smg" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_MP5::WPN_NAME, CS16_MP5::GetName(), CS16_MP5::WPN_PRICE, "smg" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_MP5::AMMO_NAME, CS16_MP5::GetAmmoName(), CS16_MP5::AMMO_PRICE, "ammo", "smg" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_UMP45::WPN_NAME, CS16_UMP45::GetName(), CS16_UMP45::WPN_PRICE, "smg" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_UMP45::AMMO_NAME, CS16_UMP45::GetAmmoName(), CS16_UMP45::AMMO_PRICE, "ammo", "smg" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_P90::WPN_NAME, CS16_P90::GetName(), CS16_P90::WPN_PRICE, "smg" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_P90::AMMO_NAME, CS16_P90::GetAmmoName(), CS16_P90::AMMO_PRICE, "ammo", "smg" ) );


	//Assault Rifles & Sniper Rifles
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_FAMAS::WPN_NAME, CS16_FAMAS::GetName(), CS16_FAMAS::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_FAMAS::AMMO_NAME, CS16_FAMAS::GetAmmoName(), CS16_FAMAS::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_GALIL::WPN_NAME, CS16_GALIL::GetName(), CS16_GALIL::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_GALIL::AMMO_NAME, CS16_GALIL::GetAmmoName(), CS16_GALIL::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_AK47::WPN_NAME, CS16_AK47::GetName(), CS16_AK47::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_AK47::AMMO_NAME, CS16_AK47::GetAmmoName(), CS16_AK47::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_M4A1::WPN_NAME, CS16_M4A1::GetName(), CS16_M4A1::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_M4A1::AMMO_NAME, CS16_M4A1::GetAmmoName(), CS16_M4A1::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_AUG::WPN_NAME, CS16_AUG::GetName(), CS16_AUG::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_AUG::AMMO_NAME, CS16_AUG::GetAmmoName(), CS16_AUG::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_SG552::WPN_NAME, CS16_SG552::GetName(), CS16_SG552::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_SG552::AMMO_NAME, CS16_SG552::GetAmmoName(), CS16_SG552::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_SCOUT::WPN_NAME, CS16_SCOUT::GetName(), CS16_SCOUT::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_SCOUT::AMMO_NAME, CS16_SCOUT::GetAmmoName(), CS16_SCOUT::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_AWP::WPN_NAME, CS16_AWP::GetName(), CS16_AWP::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_AWP::AMMO_NAME, CS16_AWP::GetAmmoName(), CS16_AWP::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_SG550::WPN_NAME, CS16_SG550::GetName(), CS16_SG550::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_SG550::AMMO_NAME, CS16_SG550::GetAmmoName(), CS16_SG550::AMMO_PRICE, "ammo", "rifle" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_G3SG1::WPN_NAME, CS16_G3SG1::GetName(), CS16_G3SG1::WPN_PRICE, "rifle" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_G3SG1::AMMO_NAME, CS16_G3SG1::GetAmmoName(), CS16_G3SG1::AMMO_PRICE, "ammo", "rifle" ) );


	//Light Machine Guns
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_M249::WPN_NAME, CS16_M249::GetName(), CS16_M249::WPN_PRICE, "lmg" ) );
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_M249::AMMO_NAME, CS16_M249::GetAmmoName(), CS16_M249::AMMO_PRICE, "ammo", "lmg" ) );


	//Explosives and Equipment
	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_HEGRENADE::WPN_NAME, CS16_HEGRENADE::GetName(), CS16_HEGRENADE::WPN_PRICE, "equip" ) );

	g_CS16Menu.AddItem( BuyMenu::BuyableItem( CS16_C4::WPN_NAME, CS16_C4::GetName(), CS16_C4::WPN_PRICE, "equip" ) );

	//Initializes hooks and precaches used by the Buy Menu Plugin
	BuyMenu::MoneyInit();
}