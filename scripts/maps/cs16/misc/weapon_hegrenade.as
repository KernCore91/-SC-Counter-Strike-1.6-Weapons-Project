//Counter-Strike 1.6 High Explosive Grenade
/* Model Credits
/ Model: Valve
/ Textures: Valve
/ Animations: Valve
/ Sounds: Valve
/ Sprites: Valve
/ Misc: Valve, D.N.I.O. 071 (Player Model Fix)
/ Script: KernCore, original base from Nero
*/

namespace CS16_HEGRENADE
{

// Animations
enum CS16_Hegrenades_Animations 
{
	IDLE = 0,
	PULLPIN,
	THROW,
	DRAW
};

// Models
string W_MODEL  	= "models/cs16/wpn/he/w_he.mdl";
string V_MODEL  	= "models/cs16/wpn/he/v_he.mdl";
string P_MODEL  	= "models/cs16/wpn/he/p_he.mdl";
// Sprites
string SPR_CAT  	= "misc/"; //Weapon category used to get the sprite's location
// Sounds
array<string> 		WeaponSoundEvents = {
					"cs16/famas/magout.wav",
					"cs16/famas/magin.wav",
					"cs16/famas/bltbk.wav"
};
string SHOOT_S  	= "cs16/famas/shoot.wav";
// Information
int MAX_CARRY   	= 10;
int MAX_CLIP    	= WEAPON_NOCLIP;
int DEFAULT_GIVE 	= 1;
int WEIGHT      	= 5;
int FLAGS       	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
uint DAMAGE     	= 150;
uint SLOT       	= 4;
uint POSITION   	= 4;
float RPM_SINGLE 	= 0.0825;
float RPM_BURST  	= 0.0825;
uint MAX_SHOOT_DIST	= 8192;
string AMMO_TYPE 	= "cs16_5.56x45mm";

class weapon_hegrenade : ScriptBasePlayerWeaponEntity, CS16BASE::WeaponBase
{

}

}