/******************************************************************************
 * The SourceMOD Entertainment System
 * Copyright (C) 2014 Mukunda Johnson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 ******************************************************************************/

//------------------------------------------------------------------------------------------------------------
public OnTVBreak(const String:output[], caller, activator, Float:delay) {
	game_broken = true;
	
	
	AcceptEntityInput( tv_cord_end_ent, "Break" );
	ResetInput();
	APU_Panic();
}

//------------------------------------------------------------------------------------------------------------
CreateTV( const Float:vec[3], const Float:ang[3] ) {
	tv_ent = CreateEntityByName( "prop_physics_multiplayer" );
	DispatchKeyValue( tv_ent, "physdamagescale", "0.0" );
	DispatchKeyValue( tv_ent, "model", TV_MODEL );
	
	DispatchKeyValue( tv_ent, "spawnflags", "257" );
	TeleportEntity( tv_ent, vec, ang, NULL_VECTOR );
	DispatchSpawn( tv_ent );
	
	AcceptEntityInput( tv_ent, "DisableMotion" );
	//AcceptEntityInput( tv_ent, "EnableMotion" );
	
	new hp = GetConVarInt( sm_vg_hp );
	if( hp <= 0 ) {
		SetEntProp( tv_ent, Prop_Data, "m_takedamage", 0 );
	} else { 
		SetVariantInt( hp );
		AcceptEntityInput( tv_ent, "SetHealth" );
	 
	}
		
	SDKHook( tv_ent, SDKHook_UsePost, OnUsePost );
	
	
	//SetEntProp( tv_ent, Prop_Data, "m_CollisionGroup", 2 );
	
	HookSingleEntityOutput( tv_ent, "OnBreak", OnTVBreak, true );
}

//------------------------------------------------------------------------------------------------------------
bool:TryHookTV( ent ) {
	if( tv_ent ) return true;
	decl String:modelname[64];
	GetEntPropString( ent, Prop_Data, "m_ModelName", modelname, sizeof(modelname) );
//	PrintToServer( "TEST NAME, %d=%s", ent, modelname );
	if( !StrEqual( modelname, TV_MODEL, false ) ) return false;
//	PrintToServer( "FOUND TV" );

	tv_ent = ent; 

//	new sf = GetEntProp( tv_ent, Prop_Data, "m_spawnflags" );

	new Float:vec[3], Float:ang[3];
	GetEntPropVector( ent, Prop_Data, "m_vecOrigin", vec );
	GetEntPropVector( ent, Prop_Data, "m_angRotation", ang );
	AcceptEntityInput( ent, "Kill" );

	CreateTV( vec, ang );
	
	return true;
}

//------------------------------------------------------------------------------------------------------------
HookTV() {
	if( tv_ent ) return;
	
	if( tv_create ) {
		CreateTV( tv_creation_point, tv_creation_angles );
		return;
	}
	
	new ent = -1;
	while( (ent = FindEntityByClassname( ent, "prop_physics_multiplayer" )) != -1 ) {
		if( TryHookTV(ent) ) return;
	}
	
}
