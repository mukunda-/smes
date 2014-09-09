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

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <videogames>

#include <ghosting>

#pragma semicolon 1

new GAME;
enum {
	GAME_CSS,
	GAME_CSGO
};


// 1.0.6
//   bump
// 1.0.5
//   fixed text/crash glitch
// 1.0.4
//   the new era
//   IMPROVED TEXT GRAPHICS
//   TEXT ALPHA BLENDING
//   standardized model sizes
//   
// 1.0.3
//   shit
// 1.0.2
//   fixed angles when tv isnt oriented like office
//   added hdr disable option
// CHANGES 1.0.1
//   cartridges reset after 6 seconds of holding
//   support for ghost
//   some minor shit
//
//----------------------------------------------------------------------------------------------------------------------
public Plugin:myinfo = {
	name = "videogames",
	author = "mukunda",
	description = "CHALLENGE ACCEPTED",
	version = "1.0.6",
	url = "www.mukunda.com"
};

new Float:timecounter;
new Float:gametime_at_frame;
new Float:last_gameframe_time;
// TV DIMENSIONS:
//
//test 6 -27.9 35.2 15 27.9 2.6

//
// +----------------------+
// |          35.2        |
// |-27.9<----------->27.9|
// |                      |
// |          2.6         |<--6.0
// +----------------------+ 
//                           
// dimensions: 55.8 x 32.6
//
// 558 x 326
// 279 x 163, 280 164
// 140 x 82 = 70 x 41
//
// 12x8
//   48x32

// ACTUAL SCREEN DIMENSIONS: 192 x 128
// screen positions within area:
//   3.9, 1.3, 51.9, 31.3
// 
// layer1 (backdrop) = + 0.0
// layer2 (tiles) = +0.05
// layer3 (sprites) = +0.1
// layer4 (clip) = +0.15

// game loop definition:
// 
// <frame divisor>
//
// <logic>
// <entity update>
// 
// <drawing>
//.,.???

#include "videogames/globals.sp"

new sleep_time;

//enum {
//	CORD_
//}
//new cord_base[NUM_ROPES];
//new cord_end[NUM_ROPES];


#include "videogames/fifo.sp"
#include "videogames/input.sp"
#include "videogames/registration.sp"
#include "videogames/bg.sp"
#include "videogames/tvhook.sp"
#include "videogames/sprites.sp"
#include "videogames/natives.sp"
#include "videogames/bios.sp"
#include "videogames/apu.sp"
#include "videogames/text.sp"

new player_has_cartridge[MAXPLAYERS+1];
new Float:cartridge_pickup_time[MAXPLAYERS+1];

#define PICKUP_TIMEOUT 6.0

new Float:nowhere[3] = {0.0, 0.0, -410.0};
// controller cords
ShowPlug(index) {
	new Float:ang[3] = {180.0,0.0,0.0};
	if( index == 0  )ang[2] += 180.0;
	TeleportEntity( ent_plug[index], controller_plug_mount_point[index], ang, NULL_VECTOR );
}

HidePlug(index) {
	new Float:hidden[3] = {0.0, 0.0, 3.0 };
	TeleportEntity( ent_plug[index], hidden, NULL_VECTOR, NULL_VECTOR );
}

ShowControllerCord( index ) {
	new Float:PlugHookupPoint[3] = {-2.4, 0.0, 0.9};
	new Float:ControllerHookupPoint[3] = {2.3, 0.25, 0.6};
	
	decl String:name2[32];
	decl String:name1[32];
	Format( name2, sizeof(name2), "vgcord_joy%d", 2+index*2 );
	Format( name1, sizeof(name1), "vgcord_joy%d", 1+index*2 );
	
	if( ent_plug_cord1[index] > 0 ) {
	
		AcceptEntityInput( ent_plug_cord1[index], "Kill" );
	} else {
		
		
		
		new rope2 = CreateEntityByName( "keyframe_rope" );
		
		DispatchKeyValue( rope2, "targetname", name2 );
		SetVariantString( "!activator" );
		
		AcceptEntityInput( rope2, "SetParent", ent_plug[index] );
		TeleportEntity( rope2, PlugHookupPoint, NULL_VECTOR, NULL_VECTOR );
		DispatchSpawn( rope2 );
		//ActivateEntity( rope2 );
		ent_plug_cord2[index] = rope2;
	}
		
	new rope1 = CreateEntityByName( "move_rope" );
	DispatchKeyValue( rope1, "targetname", name1 );
	DispatchKeyValue( rope1, "Width", "0.15" );
	
	if( GAME == GAME_CSGO ) {
		DispatchKeyValue( rope1, "Slack", "155" );
		
		DispatchKeyValue( rope1, "Collide", "0" );
	} else {
		DispatchKeyValue( rope1, "Slack", "120" ); /// floor
		DispatchKeyValue( rope1, "Collide", "1" );
	}
	DispatchKeyValue( rope1, "NextKey", name2 );
	DispatchKeyValue( rope1, "Subdiv", "4" );
	
	SetVariantString( "!activator" );
	AcceptEntityInput( rope1, "SetParent", ent_controller[index] );
	TeleportEntity( rope1, ControllerHookupPoint, NULL_VECTOR, NULL_VECTOR );
	DispatchSpawn( rope1 );
	ActivateEntity( rope1 );
	ent_plug_cord1[index] = rope1;
}

ControllerCordThing( index ) {
	
	DispatchKeyValue( ent_plug_cord1[index], "Collide", "1" );
}

//------------------------------------------------------------------------------------------------------------
SetScreenState( newstate ) {
	if( !game_setup ) return false;
	
	if( screen_state == newstate ) return false;
	new oldstate = screen_state;
	screen_state = newstate;
 
	if( newstate == SCREENSTATE_OFF ) {
		
		if( oldstate == SCREENSTATE_ON ) TeleportScroller(true);
		TeleportBackdrop( false );
		Text_TeleportScrollers( true );
		return true;
	} else if( newstate == SCREENSTATE_BLANK ) {
		if( oldstate == SCREENSTATE_ON ) TeleportScroller(true);
		
		TeleportBackdrop( true );
		Text_TeleportScrollers( true );
		return true;
	} else if( newstate == SCREENSTATE_ON ) {
		if( oldstate < SCREENSTATE_ON ) TeleportScroller(true);
		TeleportBackdrop( true );
		Text_TeleportScrollers( true );
		return true;
	}
	return false;
}


//------------------------------------------------------------------------------------------------------------
TurnSystemOff( bool:eject = false ) {
	if( !game_setup ) return false;
	
	if( system_running ) {
		SetScreenState( SCREENSTATE_OFF );
		system_running = false;
		AcceptEntityInput( ent_console_light, "HideSprite" );
		APU_Panic();
		SetEntProp( ent_console, Prop_Send, "m_nSequence", 0 );
		EmitSoundToAll( SOUND_POWERSWITCH_OFF, ent_console );
	}
	
	if( eject ) {
		EjectCartridge();
	}

	return true;
}

//------------------------------------------------------------------------------------------------------------
TurnSystemOn() {
	if( !game_setup ) return false;
	
	if( system_running ) return false;
	system_running = true;
	
	AcceptEntityInput( ent_console_light, "ShowSprite" );
	
	SetEntProp( ent_console, Prop_Send, "m_nSequence", 1 );
	
	EmitSoundToAll( SOUND_POWERSWITCH_ON, ent_console );
	
	BootSystem();
	return true;
}

//------------------------------------------------------------------------------------------------------------
bool:InsertCartridge( index ) {

	if( !game_setup ) return false;
	
 
	if( system_cartridge_inserted != 0 ) return false; // eject cartridge first!
	 
	if( system_running ) return false; // turn system off first!
	 
	system_cartridge_inserted = index+1;
	cartridge_usable[index] = false;
	
	SetVariantString( "!activator" );
	AcceptEntityInput( ent_cartridge[index], "SetParent", ent_console );
	
	
	new Float:vel[3];
	
	TeleportEntity( ent_cartridge[index], cartridge_mount_point, cartridge_mount_point_angles, vel );
	 
	
	return true;
}

//------------------------------------------------------------------------------------------------------------
EjectCartridge() {
	if( !game_setup ) return false;
	
	if( system_cartridge_inserted == 0 ) return false;
	
	new index = system_cartridge_inserted-1;
	system_cartridge_inserted = 0;
	decl Float:vec[3];
	for( new i = 0; i < 3; i++ )vec[i] = cartridge_mount_point[i];
	vec[2] += 10.0;
	
	decl Float:vel[3];
	vel[0] = GetRandomFloat( -20.0, 20.0 );
	vel[1] = GetRandomFloat( -20.0, 20.0 );
	vel[2] = 250.0 + GetRandomFloat( -0.0, 25.0 );
	
	
	TeleportEntity( ent_cartridge[index], vec, NULL_VECTOR, NULL_VECTOR );
	
	AcceptEntityInput( ent_cartridge[index], "ClearParent" );
	AcceptEntityInput( ent_cartridge[index], "EnableMotion" );
	
	TeleportEntity( ent_cartridge[index], NULL_VECTOR, NULL_VECTOR, vel );
	
	cartridge_usable[index] = true;
	
	
	EmitSoundToAll( SOUND_EJECT, ent_console );

	return true;
}

//------------------------------------------------------------------------------------------------------------
ConsoleTouched( client ) {
	if( !game_setup ) return false;
	
	if( system_running ) {
		// try to eject
		if( AreClientsPlaying() && system_cartridge_inserted != 0 ) {
			PrintCenterText( client, "Can't turn off while people are playing!" );
			return false;
		} else {
			TurnSystemOff( true );
		} 
		
		EjectCartridge();
	} else { 
		if( player_has_cartridge[client] ) {
			if( InsertCartridge(player_has_cartridge[client]-1) ) {
				player_has_cartridge[client] = 0;
			}
		}
		TurnSystemOn();
	}
	return true;

}

//------------------------------------------------------------------------------------------------------------
public Action:PickupCartridgeTimer( Handle:timer, any:data ) {
	if( !game_setup ) return Plugin_Handled; 
	new client = GetClientOfUserId( data );
	if( client == 0 ) return Plugin_Handled;

	if( !player_has_cartridge[client] ) return Plugin_Handled;

	if( (GetGameTime() - cartridge_pickup_time[client]) < PICKUP_TIMEOUT - 2.0 ) return Plugin_Handled;

	ResetCartridge( client );

	return Plugin_Handled;
}
	
//------------------------------------------------------------------------------------------------------------
PickupCartridge( client, index ) {
	if( !game_setup ) return; 
	if( !cartridge_usable[index] ) return; 
	if( player_has_cartridge[client] ) DropCartridge(client); 
//	decl String:gamename[128];
//	GetArrayString( romlist_title, index, gamename, sizeof(gamename) );
	
	player_has_cartridge[client] = index+1;
	cartridge_pickup_time[client] = GetGameTime();
	CreateTimer( PICKUP_TIMEOUT, PickupCartridgeTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE );
	
	TeleportEntity( ent_cartridge[index], nowhere, NULL_VECTOR, NULL_VECTOR );
	
	AcceptEntityInput( ent_cartridge[index], "DisableMotion" );
	cartridge_usable[index] = false;
	
}

//------------------------------------------------------------------------------------------------------------
ResetCartridge( client ) {
	if( !game_setup ) return;
	if( !player_has_cartridge[client] ) return;
	new index = player_has_cartridge[client]-1;
	player_has_cartridge[client] = 0;
	new spawnpoint = cartridge_spawn_point[index];
	TeleportEntity( ent_cartridge[index], cartridge_spawn[spawnpoint], cartridge_spawn_ang[spawnpoint], NULL_VECTOR );
	AcceptEntityInput( ent_cartridge[index], "EnableMotion" );
	cartridge_usable[index] = true;
}

//------------------------------------------------------------------------------------------------------------
DropCartridge( client ) {
	if( !game_setup ) return false;
	if( !player_has_cartridge[client] ) return false;
	new index = player_has_cartridge[client]-1;
	
	player_has_cartridge[client] = 0;
	
	new Float:vec[3];
	GetClientEyePosition( client, vec );
	
	TeleportEntity( ent_cartridge[index], vec, NULL_VECTOR, NULL_VECTOR );
	AcceptEntityInput( ent_cartridge[index], "EnableMotion" );
	
	cartridge_usable[index] = true;
	return true;
}

HostageHack() {
	new ent = -1;
	while( (ent = FindEntityByClassname( ent, "hostage_entity" )) != -1 ) {
		decl Float:vec[3];
		GetEntPropVector( ent, Prop_Data, "m_vecAbsOrigin", vec );
		if( GetVectorDistance( console_creation_point, vec ) < 150.0 ) {
			// move this fucking hostage out of the way
			vec[1] += 100.0;
			TeleportEntity(ent, vec, NULL_VECTOR, NULL_VECTOR );
			return;
		}
	}
}


//------------------------------------------------------------------------------------------------------------
public Action:RoundStartDelayed( Handle:timer ) {
	
	HookTV(); 
	
	SetupSystem();  
	
	HostageHack();
	return Plugin_Handled;
}

//------------------------------------------------------------------------------------------------------------
CleanupRopes() {
	new ent = -1;
	while( (ent = FindEntityByClassname(ent, "move_rope")) != -1 ) {
		decl String:targetname[64];
		GetEntPropString( ent, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		if( strncmp( targetname, "vgcord", 6 ) == 0 ) {
			AcceptEntityInput( ent, "kill" );
		}
	}
	ent = -1;
	while( (ent = FindEntityByClassname(ent, "keyframe_rope")) != -1 ) {
		decl String:targetname[64];
		GetEntPropString( ent, Prop_Data, "m_iName", targetname, sizeof( targetname ) );
		if( strncmp( targetname, "vgcord", 6 ) == 0 ) {
			AcceptEntityInput( ent, "kill" );
		}
	}
}

//------------------------------------------------------------------------------------------------------------
SetFramerate( Float:rate ) {
	framerate = 1.0/rate;
}

SetUpdateTime( updatetime ) {
	g_updatetime = updatetime;
}

SetSleep( frames ) {
	if( frames > 0 ) {
		sleep_time += frames;
	}
}

//------------------------------------------------------------------------------------------------------------
PostCleanup() {

	CleanupRopes();
	backdrop_ent = -1;
	game_setup = false;
	tv_ent = 0;
//	bg_ready = false;
//	bg_setup_state = 0;
//	bg_delete_state = 0;
	
	controller_being_used[0] = false;
	controller_being_used[1] = false;
	
	for( new i = 0; i < 2; i++ ) {
		ent_plug[i] = 0;
		ent_plug_cord1[i] = 0;
		ent_plug_cord2[i] = 0;
	}
	
	system_running = false;
	system_cartridge_inserted = 0;
	screen_state = SCREENSTATE_OFF;
	
	ResetInput();
	
	for( new i = 1; i <= MaxClients; i++ ) {
		player_has_cartridge[i] = 0;
	}
}

//------------------------------------------------------------------------------------------------------------
AddTVCord() {
	new Float:TVHookupPoint[3] = {2.2, -8.55, 6.8};
	new Float:SNESHookupPoint[3] = { -11.8, -4.55, 3.8};
	
	new rope2 = CreateEntityByName( "keyframe_rope" );
	DispatchKeyValue( rope2, "targetname", "vgcord_tvcord2" );
	SetVariantString( "!activator" );
	
	AcceptEntityInput( rope2, "SetParent", tv_ent );
	TeleportEntity( rope2, TVHookupPoint, NULL_VECTOR, NULL_VECTOR );
	DispatchSpawn( rope2 );
	//ActivateEntity( rope2 );
	tv_cord_end_ent=rope2;
	
	new rope1 = CreateEntityByName( "move_rope" );
	DispatchKeyValue( rope1, "targetname", "vgcord_tvcord1" );
	DispatchKeyValue( rope1, "Width", "0.3" );
	DispatchKeyValue( rope1, "Slack", "110" );
	DispatchKeyValue( rope1, "NextKey", "vgcord_tvcord2" );
	DispatchKeyValue( rope1, "Collide", "1" );
	DispatchKeyValue( rope1, "Subdiv", "4" );
	
	SetVariantString( "!activator" );
	AcceptEntityInput( rope1, "SetParent", ent_console );
	TeleportEntity( rope1, SNESHookupPoint, NULL_VECTOR, NULL_VECTOR );
	DispatchSpawn( rope1 );
	ActivateEntity( rope1 );
	 
}

//------------------------------------------------------------------------------------------------------------
TeleportBackdrop( bool:show ) {
	if( game_broken ) return;
	decl Float:vec[3];
	for( new i =0 ; i < 3; i++ ) {
		vec[i] = screen_origin[i] + LAYER1_Z;
	}
	if( !show ) {
		vec[0] -= 1.5;
	}
	
	new Float:ang[3];
	
	TeleportEntity( backdrop_ent, vec, ang, NULL_VECTOR );
}

//------------------------------------------------------------------------------------------------------------
SetupSystem() {
	// create tilemap props
	if( game_setup  )return ;// already active!
	
	system_running = false;
	update_time = 0;
	// cleanup first
	ResetSprites();
	
	FIFO_Reset( bg_dirty_fifo_read, bg_dirty_fifo_write );
	FIFO_Reset( text_dirty_fifo_read, text_dirty_fifo_write );
	
	// proceed with actual operations
	if( tv_ent <= 0 ) return; //no tv!
	if( !IsValidEntity(tv_ent) ) return;
	
	AddTVCord();
	
	SetScreenRefresh();
	game_broken = false;
	scroll_position = 0;
	last_scroll_position = 0;
	desired_scroll_position = 0;

	controller_plugged_in[0] = false;
	controller_plugged_in[1] = false;
	
//	bg_draw_offset = 0;
//	bg_tilemap_offset = 0;
//	scroller_offset = 0;
	
	{
		//scroller = CreateEntityByName( "env_sprite" );
		scroller = CreateEntityByName( "prop_dynamic" );
		DispatchKeyValue( scroller, "targetname", "thisistheworkofawizard" );
		SetEntityModel( scroller, MODEL_TILEMESH );
		SetVariantString( "!activator" );
		AcceptEntityInput( scroller, "SetParent", tv_ent );
		SetEntPropFloat( scroller, Prop_Send, "m_flModelScale", PIXEL_UNIT*16.0 );
		
		decl Float:vec[3];
		vec[0] = screen_origin_adjusted[0];
		vec[0] -= 1.5;
		vec[1] = screen_origin_adjusted[1];// - float(scroll_position) / 16.0 * 4.0 - float(scroller_offset) * 4.0;
		vec[2] = screen_origin_adjusted[2];
		
		new Float:ang[3];
	
		TeleportEntity(scroller, vec, ang, NULL_VECTOR);

		DispatchSpawn(scroller);
		//SetEdictFlags( scroller, GetEdictFlags( scroller ) | FL_EDICT_DONTSEND );
		 
	}
	
	{
		// backdrop
	
		backdrop_ent = CreateEntityByName("prop_dynamic");
		SetVariantString( "!activator" );
		AcceptEntityInput( backdrop_ent, "SetParent", tv_ent );
		SetEntityModel( backdrop_ent, MODEL_TVCOVER ); 
		//DispatchKeyValue( backdrop_ent, "rendercolor", "0 0 0" );
		//DispatchKeyValue( backdrop_ent, "rendermode", "2" );
		SetEntityRenderMode( backdrop_ent, RENDER_NORMAL );
		SetEntityRenderColor( backdrop_ent, 0, 0, 0 );
		DispatchKeyValue( backdrop_ent, "renderamt", "255" );
		DispatchSpawn(backdrop_ent);
		
		TeleportBackdrop( false );
		//TeleportEntity(backdrop_ent, screen_origin, NULL_VECTOR, NULL_VECTOR);
		//SetEntityRenderMode( backdrop_ent, RENDER_NONE );
		//SetEdictFlags( tv_ent, GetEdictFlags( tv_ent ) | FL_EDICT_DONTSEND );
	}
	
	for( new i = 0; i < BG_WIDTH*BG_HEIGHT; i++ ) {

		new x = i % BG_WIDTH;
		new y = i / BG_WIDTH;
		
		new ent = CreateEntityByName( "prop_dynamic" );
		 
		new Float:vec[3] = {LAYER2_Z, 0.0, 0.0};
		new Float:ang[3];
		
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", scroller );

		decl String:slot[32];
		Format( slot, sizeof(slot), "slot%d", x );
		SetVariantString( slot );
		AcceptEntityInput( ent, "SetParentAttachment" );
		vec[1] = 0.0;//float(x) * PIXEL_UNIT * 16.0;
		vec[2] = -float(y) * PIXEL_UNIT * 16.0;
		TeleportEntity(ent, vec, ang, NULL_VECTOR);
		SetEntityModel( ent, MODEL_DEFONT );
		
		if( c_vg_hdr ) {
			DispatchKeyValue( ent, "rendercolor", "128 128 128" );
		} else {
			DispatchKeyValue( ent, "rendercolor", "255 255 255" );
		}
		DispatchKeyValue( ent, "rendermode", "2" );
		DispatchKeyValue( ent, "renderamt", "255" );
		SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", 0 );
		SetEntPropFloat( ent, Prop_Send, "m_flModelScale", PIXEL_UNIT  );
		DispatchSpawn(ent);
		
		bg_ents[i] = ent;
		bg_tile[i] = 0;
		bg_dirty[i] = 0;
		//SetBgDirtyIndex( i, BGD_POS );
	}
	
	for( new i =0 ; i < TSCROLL_ENTS; i++ ) {
		new ent = CreateEntityByName( "env_sprite" );
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", tv_ent );

		decl String:targetname[32];
		Format(targetname,sizeof(targetname), "vgtscroll%d", i );
		DispatchKeyValue( ent, "targetname", targetname );
		
		decl Float:vec[3];
		new Float:ang[3];
		vec[0] = screen_origin_adjusted[0];
		vec[1] = screen_origin_adjusted[1];
		vec[2] = screen_origin_adjusted[2];
	
		TeleportEntity(ent, vec, ang, NULL_VECTOR);
		tscroll_ents[i] = ent;
		tscroll_pos[i][0] = 0;
		tscroll_pos[i][1] = 0;
		tscroll_dirty[i] = 0;
	}
	
	for( new i =0 ; i < TEXT_ENTS; i++ ) {
		new ent = CreateEntityByName( "prop_dynamic" );
		new Float:vec[3] = {-1.0,0.0,0.0};
		new Float:ang[3];
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", tscroll_ents[0] );
		TeleportEntity( ent, vec, ang, NULL_VECTOR );
		SetEntityModel( ent, MODEL_DEFONT );
		
		if( c_vg_hdr ) {
			DispatchKeyValue( ent, "rendercolor", "128 128 128" );
		} else {
			DispatchKeyValue( ent, "rendercolor", "255 255 255" );
		}
		DispatchKeyValue( ent, "rendermode", "2" );
		DispatchKeyValue( ent, "renderamt", "255" );
		SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", 0 );
		SetEntPropFloat( ent, Prop_Send, "m_flModelScale", PIXEL_UNIT );
		DispatchSpawn( ent );
		
	//	SetEdictFlags( ent, GetEdictFlags(ent) | FL_EDICT_DONTSEND );
		
		text_ents[i] = ent;
		text_offset[i] = 0;
		//text_layer[i] = 1;
		text_on[i] = false;
		text_pos[i][0] = 0;
		text_pos[i][1] = 0;
		text_color[i] = 0x808080;
		text_frame[i] = 0;
		strcopy( text_model[i], sizeof(text_model[]), MODEL_DEFONT );
		text_flags[i] = 0;
		text_size[i] = 16;
	}
	
	// sprites
	for( new i = 0; i < MAX_SPRITES; i++ ) {
		new ent = CreateEntityByName( "prop_dynamic" );
		new Float:vec[3] = {0.0,0.0,0.0};
		vec[0] = - 1.5;
		vec[1] =0.0 ;
		vec[2] = 0.0 ;
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", scroller );
		SetEntityModel( ent, MODEL_DEFONT );  
		DispatchKeyValue( ent, "rendermode", "2" );
		if( c_vg_hdr ) {
			SetEntityRenderColor(ent, 128 ,128,128,255 );
		} else {
			SetEntityRenderColor(ent, 255,255,255,255 );
		}
		SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", 0 );
		SetEntPropFloat( ent, Prop_Send, "m_flModelScale", PIXEL_UNIT );
		
		//SetEdictFlags( ent, GetEdictFlags(ent) | FL_EDICT_DONTSEND );
		AcceptEntityInput( ent, "TurnOff" );
		
		new Float:ang[3];
		TeleportEntity( ent, vec, ang, NULL_VECTOR );
		
		DispatchSpawn( ent );
		sprite_ent[i] = ent;
	}
	
	apu_num_channels = 6;
	APU_CreateChannels();
	
	game_setup = true;
	
}

//------------------------------------------------------------------------------------------------------------
bool:GameActive() {
	if( !game_setup ) return false;
	if( game_broken ) return false;
	if( !IsValidEntity(tv_ent) ) {
		game_broken = true;
		return false;
	}
	return true;
}

UpdateGame() {
	Call_StartFunction( controlling_plugin, romfunc_onframe );
	Call_Finish();
}

//============================================================================================================
// LOGIC/ENTITIES
//

GameMain() {
	UpdateInput();
		
	if( !GameActive() ) return;
	if( !system_running ) return;
	
	
	// add and clamp (keep negative time last frame)
	update_time += g_updatetime > c_vg_updatetime ? c_vg_updatetime : g_updatetime;
	if( update_time > c_vg_updatetime ) update_time = c_vg_updatetime;
	
	
	if( !sleep_time ) {
		  
		UpdateGame();
	
	} else {
		sleep_time--;
	}
	//
	// rendering
	//
	UpdateBgScroll();
	
	if( screen_refresh ) {
		ScreenRefreshBg();
		ScreenRefreshSprites();
		screen_refresh = 0;
	}
	
	UpdateSprites();
	Text_Update();
	UpdateBgDirty();
	TeleportScroller();
	scroll_changed = false;
	
	if( g_disable_blanking ) {
		g_disable_blanking--;
		if( g_disable_blanking == 0 ) {
			SetScreenState( SCREENSTATE_ON );
		}
	}
}
 
//------------------------------------------------------------------------------------------------------------
public OnGameFrame() {
	
	gametime_at_frame = GetGameTime();
	
	timecounter += gametime_at_frame - last_gameframe_time;
	last_gameframe_time = gametime_at_frame;
	if( timecounter < -1.0 ) timecounter = -1.0; // JUST IN CASE... resync if last_gameframe_time fucked up
	
	if( timecounter > framerate ) {
		if( timecounter > 1.0 ) { // resync
			timecounter = 0.0;
		}
		timecounter -= framerate;
		
		
		GameMain();
	}
	  
}  

OnPlayerUse( client, ent ) {
	decl String:targetname[64];
	GetEntPropString( ent, Prop_Data, "m_iName", targetname, sizeof(targetname) );
	if( strncmp( targetname, "vgcartridge", 11 ) == 0 ) {
		// its a cartridge
		
		
		new index = StringToInt( targetname[11] );
		PickupCartridge( client, index );
	} else if( ent == ent_console ) {
		// console touched
		ConsoleTouched( client );
	} else if( ent == ent_controller[0] || ent == ent_controller[1] ) {
		if( controller_being_used[0] && ent == ent_controller[0] ||
			controller_being_used[1] && ent == ent_controller[1] ) {
			return;
		} 
		// wants to play
		HookClient( client, ent );
	} else if( ent == tv_ent ) {
		HookClient( client, 0 );
	}
}

//------------------------------------------------------------------------------------------------------------
public OnUsePost(entity, activator, caller, UseType:type, Float:value) {
	new client = activator;
	if( client == 0 || client > MaxClients ) return;
	OnPlayerUse( client, entity );
}
	

//------------------------------------------------------------------------------------------------------------
public Event_PlayerUse( Handle:event, const String:name[], bool:dontBroadcast ) {
	new client = GetClientOfUserId( GetEventInt( event, "userid" ) );
	if( client <= 0 ) return;
	new ent = GetEventInt( event, "entity" );
	OnPlayerUse( client ,ent );
	
	
	
}

//------------------------------------------------------------------------------------------------------------
public Event_PlayerDeath( Handle:event, const String:name[], bool:dontBroadcast ) {
	new client = GetClientOfUserId( GetEventInt( event,"userid" ) );
	UnhookClient( client );
	
	if( player_has_cartridge[client] ) {
		DropCartridge(client);
	}
}

//------------------------------------------------------------------------------------------------------------
public OnClientDisconnect( client ) {
	UnhookClient( client, false );
}

//------------------------------------------------------------------------------------------------------------
SetCartridgeModel( ent, const String:id[] ) {
	decl String:model[256];
	Format( model, sizeof(model), "models/videogames/%s/cartridge.mdl", id );
	DispatchKeyValue( ent, "model", model ); 
}

//------------------------------------------------------------------------------------------------------------
CreateConsoleStuff() {
	// spawn console
	
	new ent = CreateEntityByName( "prop_physics_override" );
	DispatchKeyValue( ent, "model", MODEL_SMES ); 
	if( c_vg_hdr ) {
		DispatchKeyValue( ent, "rendercolor", "128 128 128" ); 
	} else {
		DispatchKeyValue( ent, "rendercolor", "255 255 255" ); 
	}
	TeleportEntity( ent, console_creation_point, console_creation_angles, NULL_VECTOR );
	DispatchSpawn( ent );
	AcceptEntityInput( ent, "DisableMotion" );
	DispatchKeyValue( ent, "spawnflags", "256" ); // make usable
	ent_console = ent;
	SDKHook( ent, SDKHook_UsePost, OnUsePost );
	
	
	// cotrollers
	for( new i = 0; i < 2; i++ ) {
		ent = CreateEntityByName( "prop_physics_override" );
		DispatchKeyValue( ent, "model", MODEL_SMES_CONTROLLER ); 
		if( c_vg_hdr ) {
			DispatchKeyValue( ent, "rendercolor", "128 128 128" ); 
		} else {
			DispatchKeyValue( ent, "rendercolor", "255 255 255" ); 
		}
		TeleportEntity( ent, controller_creation_point[i], controller_creation_angles[i], NULL_VECTOR );
		DispatchKeyValue( ent, "spawnflags", "256" ); // make usable
		DispatchSpawn( ent );
		
		SDKHook( ent, SDKHook_UsePost, OnUsePost );
		
		//AcceptEntityInput( ent, "DisableMotion" );
		AcceptEntityInput( ent, "DisableDamageForces" );
		SetEntProp( ent, Prop_Data, "m_CollisionGroup", 2 );
		ent_controller[i] = ent;
		
		new Float:vec[3];
		
		ent = CreateEntityByName( "prop_dynamic" );
		DispatchKeyValue( ent, "model", MODEL_SMES_CONTROLLER_BUTTONS );
		if( c_vg_hdr ) {
			DispatchKeyValue( ent, "rendercolor", "128 128 128" );
		} else {
			DispatchKeyValue( ent, "rendercolor", "255 255 255" );
		}
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", ent_controller[i] );
		TeleportEntity( ent, vec, vec, vec );
		DispatchSpawn( ent );
		ent_controller_buttons[i] = ent;
		
		ent = CreateEntityByName( "prop_dynamic" );
		DispatchKeyValue( ent, "model", MODEL_SMES_CONTROLLER_BUTTONS2 );
		if( c_vg_hdr ) {
			DispatchKeyValue( ent, "rendercolor", "128 128 128" );
		} else {
			DispatchKeyValue( ent, "rendercolor", "255 255 255" );
		}
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", ent_controller[i] );
		TeleportEntity( ent, vec, vec, vec );
		DispatchSpawn( ent );
		ent_controller_buttons2[i] = ent;
		
		
		ent = CreateEntityByName( "prop_dynamic" );
		DispatchKeyValue( ent, "model", MODEL_SMES_CONTROLLER_PAD );
		if( c_vg_hdr ) {
			DispatchKeyValue( ent, "rendercolor", "128 128 128" );
		} else {
			DispatchKeyValue( ent, "rendercolor", "255 255 255" );
		}
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", ent_controller[i] );
		TeleportEntity( ent, vec, vec, vec );
		DispatchSpawn( ent );
		ent_controller_dpad[i] = ent;
	}
	
	// plugs
	for( new i = 0; i < 2; i++ ) {
		ent = CreateEntityByName( "prop_dynamic" );
		DispatchKeyValue( ent, "model", MODEL_SMES_PLUG ); 
		if( c_vg_hdr ) {
			DispatchKeyValue( ent, "rendercolor", "128 128 128" ); 
		} else {
			DispatchKeyValue( ent, "rendercolor", "255 255 255" );
		}
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", ent_console );
		ent_plug[i] = ent;
		HidePlug(i);
		
		
		DispatchSpawn( ent );
		
		
	}
	
	
	// spawn cartridges
	ent_cartridge_count = 0;
	new spawnpoint = 0;
	new size = GetArraySize( romlist_ids );
	for( new i = 0; i < size; i++ ) {
	
		decl String:idstring[64];
	
		GetArrayString( romlist_ids, i, idstring,  sizeof( idstring) ); 
		if( StrEqual( idstring, "bios" ) ) {
			continue; // do not create a cartridge for the bios
		}
		 
		if( spawnpoint >= cartridge_count ) break;
		ent = CreateEntityByName( "prop_physics_override" );
		
		decl String:targetname[64];
		Format( targetname, sizeof(targetname), "vgcartridge%d", i );
		
		DispatchKeyValue( ent, "targetname", targetname );
		SetCartridgeModel( ent, idstring );
		if( c_vg_hdr ) {
			DispatchKeyValue( ent, "rendercolor", "128 128 128" );  
		} else {
			DispatchKeyValue( ent, "rendercolor", "255 255 255" );
		}
		cartridge_spawn_point[i] = spawnpoint;
		TeleportEntity( ent, cartridge_spawn[spawnpoint], cartridge_spawn_ang[spawnpoint], NULL_VECTOR );
		SetEntProp( ent, Prop_Data, "m_CollisionGroup", 2 );
		DispatchKeyValue( ent, "spawnflags", "256" ); // make usable
		DispatchSpawn( ent ); 
		AcceptEntityInput( ent, "DisableDamageForces" );
		
		
		SDKHook( ent, SDKHook_UsePost, OnUsePost );
		
		ent_cartridge[i] = ent;
		cartridge_usable[i] = true;
		ent_cartridge_count++;

		spawnpoint++;
		
		if( spawnpoint >= cartridge_count ) break;
	}
	
	{
		// create LED glow
		ent = CreateEntityByName( "env_sprite" );
		
		SetEntityModel( ent, MATERIAL_GLOW );
		if( c_vg_hdr ) {
			SetEntityRenderColor( ent,10,90,30 );
		} else {
			SetEntityRenderColor( ent,20,180,60 );
		}
		SetEntityRenderMode( ent, RENDER_WORLDGLOW );
	//	DispatchKeyValue( ent, "model", MATERIAL_GLOW );
	//	DispatchKeyValue( ent, "rendermode", "2" );
	//	DispatchKeyValue( ent, "rendercolor", "255 255 255" );
		DispatchKeyValue( ent, "renderamt", "255" );
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", ent_console );
		
		
		DispatchKeyValue(  ent, "scale", "4.0" );
		DispatchKeyValue( ent, "GlowProxySize", "2.0" );
		SetEntProp(  ent, Prop_Data, "m_bWorldSpaceScale", 1 );
		

		DispatchSpawn( ent );
		new Float:pos[3] = {10.0, 5.525, 5.9};
		TeleportEntity( ent, pos, NULL_VECTOR, NULL_VECTOR );
		
		ent_console_light = ent;
		AcceptEntityInput( ent, "HideSprite" );
	}
}


//------------------------------------------------------------------------------------------------------------
public Event_RoundStart( Handle:event, const String:name[], bool:dontBroadcast ) {
	PostCleanup();
	
	if( c_vg_enabled && plugin_enabled ) {
		CreateConsoleStuff();
	
		CreateTimer( 0.1, RoundStartDelayed, 0, TIMER_FLAG_NO_MAPCHANGE );
	}
}

//------------------------------------------------------------------------------------------------------------
bool:GetPosAng( Handle:kv, const String:key[], Float:pos[3], Float:ang[3], bool:mandatory ) {
	if( !KvJumpToKey( kv, key ) ) {
		if( mandatory ) {
			SetFailState( "%s missing in config", key );
		}
		return false;
	}
	
	KvGetVector( kv, "position", pos );
	KvGetVector( kv, "angles", ang );
	
	KvGoBack(kv);
	return true;
}

//------------------------------------------------------------------------------------------------------------
LoadConfig() {
	decl String:map[64];
	GetCurrentMap( map, sizeof(map) );
	
	// load config
	decl String:filepath[256];
	BuildPath( Path_SM, filepath, sizeof(filepath), "configs/videogames.txt" );
	
	new Handle:kv = CreateKeyValues( "videogames" );
	if( !FileExists(filepath) ) {
		CloseHandle(kv);
		SetFailState( "configs/videogames.txt missing" );
		return;
	}
	
	if( !FileToKeyValues( kv, filepath ) ) {
		CloseHandle(kv);
		SetFailState( "Couldn't Load Config" );
		return;
	}
	
	if( !KvJumpToKey( kv, map ) ) {
		// map not found, plugin disabled
		CloseHandle(kv);
		return;
	}
	
	GetPosAng( kv, "player1", player_vectors[0], player_vectors[1], true );
	GetPosAng( kv, "player2", player_vectors[2], player_vectors[3], true );
	tv_create = GetPosAng( kv, "tv", tv_creation_point, tv_creation_angles, false );
	
	GetPosAng( kv, "console", console_creation_point, console_creation_angles, true );
	GetPosAng( kv, "controller1", controller_creation_point[0], controller_creation_angles[0], true );
	GetPosAng( kv, "controller2", controller_creation_point[1], controller_creation_angles[1], true );
	
	cartridge_count = 0;
	if( KvJumpToKey( kv, "cartridges" ) ) {
		// load cartridge list
		if( !KvGotoFirstSubKey( kv ) ) {
			KvGoBack(kv);// no cartrdiges
		} else {
			do {
				KvGetVector( kv, "position", cartridge_spawn[cartridge_count] );
				KvGetVector( kv, "angles", cartridge_spawn_ang[cartridge_count] );
				
				cartridge_count++;

			} while( KvGotoNextKey(kv) );
			KvGoBack(kv);
		}
		KvGoBack(kv);
	}
	
	KvGoBack(kv);
	 
	CloseHandle( kv );

	plugin_enabled = true;
}
/*
//------------------------------------------------------------------------------------------------------------
PrecacheCartridgeModel( const String:id[] ) {
	decl String:model[256];
	Format( model, sizeof(model), "models/videogames/%s/cartridge.mdl"
	PrecacheModle( model );
}

//------------------------------------------------------------------------------------------------------------
PrecacheAllCartridgeModels() {
	new size = GetArraySize( romlist_ids );
	for( new i = 0; i < size; i++ ) {
		decl String:id[64];
		GetArrayString( romlist_ids, i, id, sizeof(id) );
		PrecacheModel( id );
	}
}*/

//------------------------------------------------------------------------------------------------------------
public OnMapStart() {

	gametime_at_frame = 0.0;
	plugin_enabled = false;

	timecounter = 0.0;
	last_gameframe_time = 0.0;
	
	LoadConfig();
	
	PrecacheModel( TV_MODEL ); 
	
	BIOS_Precache();
	
	PrecacheSound( "*doom/doom_screaming.mp3" ); // test 
	PrecacheSound( "items/suitcharge1.wav" ); // test
	
	for( new i = 0; i < sizeof( soundlist ); i++ ) {	
		PrecacheSound( soundlist[i] );
	}
		
	
	
	
//	PrecacheModel( "materials/videogames/TEST12.vmt" );
	
	// precache cartridges
	
	//g_laser_texture = PrecacheModel( LASER_TEXTURE );
	//g_decal = PrecacheDecal( "sprites/laserbeam" );
	
	for( new i = 0; i < sizeof(materials_list); i++ ) {
		PrecacheModel( materials_list[i] );
	}
	
	for( new i = 0; i < sizeof(downloads_list); i++ ) {
		AddFileToDownloadsTable( downloads_list[i] );
	}

	Event_RoundStart( INVALID_HANDLE, "", false );
}

//------------------------------------------------------------------------------------------------------------
public RecacheConVar(Handle:convar, const String:oldValue[], const String:newValue[]) {
	if( convar == sm_vg_updatetime ) {
		c_vg_updatetime = GetConVarInt( sm_vg_updatetime );
	} else if( convar == sm_vg_enabled ) {
		c_vg_enabled = GetConVarBool( sm_vg_enabled );
	} else if( convar == sm_vg_hdr ) {
		c_vg_hdr = GetConVarBool( sm_vg_hdr );
	}
}

//------------------------------------------------------------------------------------------------------------
public OnPluginStart() { 
	
	decl String:gamedir[PLATFORM_MAX_PATH];
	GetGameFolderName(gamedir, sizeof(gamedir));
 
	if(strcmp(gamedir, "cstrike") == 0)
	{
		GAME = GAME_CSS;
	}
	else
	{
		GAME = GAME_CSGO;
	}
	
	sm_vg_hp = CreateConVar( "sm_vg_hp", "1", "How much HP to give the TV, 0 = invulnerable", FCVAR_PLUGIN );
	//sm_vg_roundreset = CreateConVar( "sm_vg_roundreset", "1", "Round-end reboot mode, 0 = do nothing, 1 = soft reset (reboot same game), 2 = hard reset (run boot rom)", FCVAR_PLUGIN );
	sm_vg_updatetime = CreateConVar( "sm_vg_updatetime", "35", "Network update time allowed per frame", FCVAR_PLUGIN );
	g_updatetime = 35;
	sm_vg_fastbios = CreateConVar( "sm_vg_fastbios", "0", "Skip BIOS scene", FCVAR_PLUGIN );
	sm_vg_enabled = CreateConVar( "sm_vg_enabled", "1", "Enable/Disable videogames module", FCVAR_PLUGIN );
	sm_vg_hdr = CreateConVar( "sm_vg_hdr", GAME==GAME_CSGO?"1":"0", "Enable HDR color divider", FCVAR_PLUGIN );	// TODO: 
	
	HookConVarChange( sm_vg_updatetime, RecacheConVar );
	HookConVarChange( sm_vg_enabled, RecacheConVar );
	HookConVarChange( sm_vg_hdr, RecacheConVar );
	c_vg_updatetime = GetConVarInt( sm_vg_updatetime );
	c_vg_enabled = GetConVarBool( sm_vg_enabled );
	c_vg_hdr = GetConVarBool( sm_vg_hdr );

	
	//GetConVarString( sm_vg_rom, c_vg_rom, sizeof(c_vg_rom) );
	
	//entities = CreateArray( ENTITY_FIELDS );
	
	HookEvent( "round_start", Event_RoundStart );
	//HookEvent( "player_use", Event_PlayerUse );
	HookEvent( "player_death", Event_PlayerDeath );
	
	
	InitRegistration();
	InitBGSystem();
	
	RegisterGame( GetMyHandle(), "bios", "SMES BIOS ROM" );
//	LoadTilemap();

	//RegConsoleCmd( "test", test );
	
	AddCommandListener( OnLookAtWeapon, "+lookatweapon"  );
	AddCommandListener( OnReleaseLookAtWeapon , "-lookatweapon" );
}

GetCartridgeIndex() {
	return system_cartridge_inserted;
}

public GetCartridgeTitle( String:out[], maxlen ) {
	if( maxlen == 0 ) return;
	if( system_cartridge_inserted != 0 ) {
		GetArrayString( romlist_title, system_cartridge_inserted-1, out, maxlen );
	} else {
		out[0] = 0;
	}
}

public GetCartridgeID( String:out[], maxlen ) {
	if( maxlen == 0 ) return;
	if( system_cartridge_inserted != 0 ) {
		GetArrayString( romlist_ids, system_cartridge_inserted-1, out, maxlen );
	} else {
		out[0] = 0;
	}
}

//------------------------------------------------------------------------------------------------------------
BootSystem() { 
	
	new index = FindGame( "bios" );
	
	if( index == -1 ) {
		PrintToServer ("vgnotice: booting system couldnt find bios...");
		TurnSystemOff();
		return; // no bios!?
	}
 
	controlling_plugin = GetArrayCell( romlist_plugin, index );
	// boot game  
	if( controlling_plugin == INVALID_HANDLE ) {
		SetFailState( "something bad happened" );
		return; // no rom (how can this have happen?!)
	}
	
	if( !game_broken ) {
		HardwareInit();
		
		active_game_id = "bios";
		active_game_index = index;
		
		
		
		romfunc_onentry = GetFunctionByName( controlling_plugin, "VG_OnEntry" );
		romfunc_onframe = GetFunctionByName( controlling_plugin, "VG_OnFrame" );

		Call_StartFunction( controlling_plugin, romfunc_onentry );
		Call_Finish();
	}
}


HardwareInit( bool:bgmodel=true ) {
	// reset framerate,set screen refresh,blank screen
	SetScreenState( SCREENSTATE_BLANK );
	SetFramerate( 20.0 );
	SetScreenRefresh();
	if( bgmodel ) SetBGModel( MODEL_DEFONT );
	SetUpdateTime( 9000 );
	g_disable_blanking = 0;
	
	SetScroll(0);
	// todo: move all game initialization related shit here
	sleep_time = 0;
	
	HWInit_Sprites();
	HWInit_Text();
	
	// clear tilemap ram
	for( new i =0 ; i < MAP_WIDTH*MAP_HEIGHT; i++ ) {
		tilemap[i] = 0;
	}
}

ExecuteCart() {
	HardwareInit(false);
	if( system_cartridge_inserted == 0 ) {
		TurnSystemOff();
		return;
	}
	new index = system_cartridge_inserted - 1;
	controlling_plugin = GetArrayCell( romlist_plugin, index );
	active_game_index = index;
	GetArrayString( romlist_ids, active_game_index,active_game_id, sizeof(active_game_id) );
	
	romfunc_onentry = GetFunctionByName( controlling_plugin, "VG_OnEntry" );
	romfunc_onframe = GetFunctionByName( controlling_plugin, "VG_OnFrame" );
	Call_StartFunction( controlling_plugin, romfunc_onentry );
	Call_Finish();
}
/* 
public Action:test(client,args) {
	//SetEntityFlags( client, GetEntityFlags(client)|FL_ATCONTROLS );
	PrintToChatAll( "testing!, %d", GetEntityMoveType(client) );
	//SetEntityMoveType(client, MOVETYPE_NONE);

	testing = !testing;
	if(!testing) {
		SetEntProp( client, Prop_Send, "m_iObserverMode", 6 );
	} else {
		SetEntProp( client, Prop_Send, "m_iObserverMode", 0 );
	}
	//SetEntProp( client, Prop_Send, "m_iFOV", 150 );
	
	
	//testing = !testing;
	
	return Plugin_Handled;
	
}*/
