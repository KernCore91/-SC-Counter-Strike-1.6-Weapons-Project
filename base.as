// Usage suited for Counter-Strike Weapons in Sven Co-op
// Author: KernCore

namespace CS16BASE
{ //Namespace start

bool ShouldUseCustomAmmo = true; // true = Uses custom ammo values; false = Uses SC's default ammo values.

// Precaches an array of sounds
void PrecacheSound( const array<string> pSound )
{
	for( uint i = 0; i < pSound.length(); i++ )
	{
		g_SoundSystem.PrecacheSound( pSound[i] );
		g_Game.PrecacheGeneric( "sound/" + pSound[i] );
		//g_Game.AlertMessage( at_console, "Precached: sound/" + pSound[i] + "\n" );
	}
}

edict_t@ ENT( const entvars_t@ pev )
{
	return pev.pContainingEntity;
}

mixin class WeaponBase
{

}

mixin class AmmoBase
{

}

} // Namespace end