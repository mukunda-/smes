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

//new player_buttons_or[2];
new game_buttons[2];
new game_buttons_last[2];
new bool:block_e[2];

//new Float:button_time_pressed[INPUT_NUM_BUTTONS];
new button_strokes[2][INPUT_NUM_BUTTONS];
new Float:impulse_time[2];

new bool:looking_at_weapon[MAXPLAYERS+1];

#define BUTTON_MASK1 (INPUT_JUMP|INPUT_R|INPUT_CTRL|INPUT_SHIFT)
#define BUTTON_MASK2 (INPUT_F|INPUT_E)
#define BUTTON_MASK3 (INPUT_LEFT|INPUT_UP|INPUT_RIGHT|INPUT_DOWN)
/*
public Action:Noblock_Reset() {

}
*/
SetClientNoblock( client ) { 
	SetEntProp( client, Prop_Send, "m_CollisionGroup", 2 );
}

UnsetClientNoblock( client ) {
	SetEntProp( client, Prop_Send, "m_CollisionGroup", 5 );
}

//------------------------------------------------------------------------------------------------------------
ResetInput() {
	
	for( new i = 0; i < 2; i++ )
		if( game_clients[i] ) UnhookClient( game_clients[i] );
} 



//------------------------------------------------------------------------------------------------------------
FlushKeyClicks() {
	for( new p = 0; p < 2; p++ ) {
		for( new i = 0; i < INPUT_NUM_BUTTONS; i++ ) {
			button_strokes[p][i] = 0;
		}
	}
}

//------------------------------------------------------------------------------------------------------------
KeyClicks( player, key_index, bool:reset=true ) {
	new clicks = button_strokes[player][key_index];
	if( reset ) {
		button_strokes[player][key_index] = 0;
	}
	return clicks;
}

//------------------------------------------------------------------------------------------------------------
KeyState( player ) {
	return game_buttons[player];
}

/*
//------------------------------------------------------------------------------------------------------------
bool:KeyDown( player, key ) {
	return (game_input_last[player] & key) == 0 &&
			(game_input[player] & key) != 0;
}
*/
//------------------------------------------------------------------------------------------------------------
bool:KeyHeld( player, key ) {
	return (game_buttons[player] & key) != 0;
}
/*
//------------------------------------------------------------------------------------------------------------
bool:KeyUp( player, key ) {
	return (game_input_last[player] & key) != 0 &&
			(game_input[player] & key) == 0;
}
*/
//------------------------------------------------------------------------------------------------------------
UpdateInput() {
	
	// check if clients are valid
	
	for( new i = 0; i < 2; i++ ){
		
		if( game_clients[i] ) {
			
			if( !IsClientInGame(game_clients[i]) ) {
				game_clients[i] = 0;
				continue;
			}
			
			decl Float:ang[3];
			GetClientEyeAngles( game_clients[i],ang );
			
			if( ang[1] < 0.0 ) ang[1] += 360.0;
			
			new Float:a = ang[1] + 360.0;
			new Float:b = player_vectors[1][1] + 360.0;
			a = a - RoundToFloor(a / 360.0) * 360.0;
			b = b - RoundToFloor(b / 360.0) * 360.0;
			a = FloatAbs(a - b);
			if( a > 180.0 ) a = 360.0 - a;
			
			if( a > 70.0 && (gametime_at_frame > client_hook_time[i] + 1.0) ) {
				// unhook!
				UnhookClient( game_clients[i] ) ;
				continue;
			}
		}
		/*
		new bool:updatebuttons[3];
		if( (game_input_last[i]&BUTTON_MASK1) != (game_input[i]&BUTTON_MASK1) ) updatebuttons[0] = true;
		if( (game_input_last[i]&BUTTON_MASK2) != (game_input[i]&BUTTON_MASK2) ) updatebuttons[1] = true;
		if( (game_input_last[i]&BUTTON_MASK3) != (game_input[i]&BUTTON_MASK3) ) updatebuttons[2] = true;
		
		game_input_last[i] = game_input[i];
		
		new buttons = player_buttons_or[i]; 
		player_buttons_or[i] = player_buttons[i];
		
		
		game_input[i] = 0;
		if( buttons & IN_MOVELEFT )		game_input[i] |= INPUT_LEFT;
		if( buttons & IN_MOVERIGHT )	game_input[i] |= INPUT_RIGHT;
		if( buttons & IN_FORWARD )		game_input[i] |= INPUT_UP;
		if( buttons & IN_BACK )			game_input[i] |= INPUT_DOWN;
		if( buttons & IN_JUMP )			game_input[i] |= INPUT_JUMP;
		if( buttons & IN_SPEED )		game_input[i] |= INPUT_SHIFT;
		if( buttons & IN_DUCK )			game_input[i] |= INPUT_CTRL;
		if( buttons & IN_USE )			game_input[i] |= INPUT_E;
		if( buttons & (1<<29) )			game_input[i] |= INPUT_F;
		if( buttons & IN_RELOAD )		game_input[i] |= INPUT_R;
		
		new inp = game_input[i];
		
		if( updatebuttons[0] ) {
			new sequence = 0;
			if( inp & INPUT_R ) sequence += 1;
			if( inp & INPUT_JUMP ) sequence += 2;
			if( inp & INPUT_CTRL ) sequence += 4;
			if( inp & INPUT_SHIFT ) sequence += 8;
			SetEntProp( ent_controller_buttons[i], Prop_Send, "m_nSequence", sequence );
		}
		
		if( updatebuttons[1] ) {
			new sequence = 0;
			if( inp & INPUT_E ) sequence += 1;
			if( inp & INPUT_F ) sequence += 2;
			SetEntProp( ent_controller_buttons2[i], Prop_Send, "m_nSequence", sequence );
		} 
		
		if( updatebuttons[2] ) {
			new sequence = 0;
			if( inp & INPUT_UP ) sequence += 1;
			if( inp & INPUT_RIGHT ) sequence += 2;
			if( inp & INPUT_DOWN ) sequence += 4;
			if( inp & INPUT_LEFT ) sequence += 8;
			SetEntProp( ent_controller_dpad[i], Prop_Send, "m_nSequence", sequence );
		}*/
	}
	
}

TranslateSourceButtons( buttons, Float:impulsetime, &r_block_e ) {
	new result = 0;
	if( buttons & IN_MOVELEFT )		result |= INPUT_LEFT;
	if( buttons & IN_MOVERIGHT )	result |= INPUT_RIGHT;
	if( buttons & IN_FORWARD )		result |= INPUT_UP;
	if( buttons & IN_BACK )			result |= INPUT_DOWN;
	if( buttons & IN_JUMP )			result |= INPUT_JUMP;
	if( buttons & IN_SPEED )		result |= INPUT_SHIFT;
	if( buttons & IN_DUCK )			result |= INPUT_CTRL;
	if( buttons & IN_USE ) {
		if( !r_block_e )
			result |= INPUT_E;
	} else {
		r_block_e = false;
	}
	if( (GetGameTime() - impulsetime) < 0.1 ) result |= INPUT_F;
	if( buttons & IN_RELOAD )		result |= INPUT_R;
	return result;
}

//------------------------------------------------------------------------------------------------------------
public Action:OnLookAtWeapon( client, const String:command[], argc ) {
	if( client == game_clients[0] || client == game_clients[1] ) {
		looking_at_weapon[client] = true; 
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

//------------------------------------------------------------------------------------------------------------
public Action:OnReleaseLookAtWeapon( client, const String:command[], argc ) {
	looking_at_weapon[client] = false; 
	return Plugin_Continue;
}

//------------------------------------------------------------------------------------------------------------
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon) {
	if( testing && !IsFakeClient(client) ) {
		PrintToServer( "%d", buttons );
		return Plugin_Handled;
	}
	if( client == game_clients[0] || client == game_clients[1] ) {
		if( !GameActive() ) return Plugin_Continue;
		new index = client == game_clients[0] ? 0 : 1;
		
		if( impulse == 100 ) impulse_time[index] = GetGameTime();
		
		new buttons2 = TranslateSourceButtons( buttons, impulse_time[index], block_e[index] );
		
		if( impulse == 100 || impulse_time[index] ) { // block flashlight 
			impulse = 0;
		}
		
		if( looking_at_weapon[client] ) {
			buttons2 |= INPUT_F;
		} 
		
		if( buttons2 != game_buttons_last[index] ) {
			game_buttons[index] = buttons2;
			
			new changes = (game_buttons_last[index] ^ buttons2);
			new clicks = changes & buttons2;
			//new released = (player_buttons_last[index] ^ buttons2) & player_buttons_last[index];
			
			for( new i = 0, tclicks = clicks; i < INPUT_NUM_BUTTONS; i++ ) {
				if( tclicks & 1 ) button_strokes[index][i]++;
				tclicks>>=1;
			}
			
			new inp = game_buttons[index];
			if( changes & BUTTON_MASK1 ) {
			
				new sequence = 0;
				if( inp & INPUT_R ) sequence += 1;
				if( inp & INPUT_JUMP ) sequence += 2;
				if( inp & INPUT_CTRL ) sequence += 4;
				if( inp & INPUT_SHIFT ) sequence += 8;
				SetEntProp( ent_controller_buttons[index], Prop_Send, "m_nSequence", sequence );
			}
			
			if( changes & BUTTON_MASK2 ) {
				new sequence = 0;
				if( inp & INPUT_E ) sequence += 1;
				if( inp & INPUT_F ) sequence += 2;
				SetEntProp( ent_controller_buttons2[index], Prop_Send, "m_nSequence", sequence );
			}
			
			if( changes & BUTTON_MASK3 ) {
				new sequence = 0;
				if( inp & INPUT_UP ) sequence += 1;
				if( inp & INPUT_RIGHT ) sequence += 2;
				if( inp & INPUT_DOWN ) sequence += 4;
				if( inp & INPUT_LEFT ) sequence += 8;
				SetEntProp( ent_controller_dpad[index], Prop_Send, "m_nSequence", sequence );
			}
			
			game_buttons_last[index] = buttons2;
		}
		
		buttons &= ~(IN_USE|IN_DUCK|IN_RELOAD);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

//------------------------------------------------------------------------------------------------------------
HookClient( client, ent ) {
	if( IsClientHooked(client) ) return;
	if( game_broken ) return; // dont hook without tv!

	new entindex;
	if( ent != 0 ) {
		if( ent == ent_controller[0] ) entindex = 0;
		else entindex = 1;
		if( !controller_plugged_in[0] ) entindex = 0;
	} else {
		if( !game_clients[0] ) {
			entindex = 0;
		} else if( !game_clients[1] ) {
			entindex = 1;
		} else {
			return;
		}
	}

	new newclient = entindex;

	if( game_clients[entindex] ) return; // controller in use
//	if( game_clients[0] == 0 ) {
//		newclient = 0;
//	} else if( game_clients[1] == 0 ) {
//		newclient = 1;
//	}
	
//	if( newclient == -1 ) return; // game is full
	controller_being_used[newclient] = true;
	
	SetEntityMoveType( client, MOVETYPE_NONE );
	game_clients[newclient] = client;
	
	
	client_hook_time[newclient] = GetGameTime();

	new Float:playervec[3];
	new Float:playerang[3];
	for( new i = 0; i < 3; i++ ) playervec[i] = player_vectors[newclient*2][i];
	for( new i = 0; i < 3; i++ ) playerang[i] = player_vectors[newclient*2+1][i];

	
	
	if( !IsPlayerAlive(client) ) {
		
		playervec[2] += 64.0;
		
		new Float:vel[3];
		TeleportEntity( client, playervec, playerang, vel );
		SetEntProp( client, Prop_Send, "m_iObserverMode", 0 );

		
		SetEntProp( client, Prop_Send, "m_iHideHUD", GetEntProp( client, Prop_Send, "m_iHideHUD" ) | (HIDEHUD_CROSSHAIR | (1<<3)|(1<<4)) );
	} else {
		
		new Float:vel[3];
		TeleportEntity( client, playervec, playerang, vel );
		SetEntProp( client, Prop_Send, "m_iHideHUD", GetEntProp( client, Prop_Send, "m_iHideHUD" ) | HIDEHUD_CROSSHAIR );
	}

	
	
	new Float:vec[3];
	new Float:ang[3] = {240.0,270.0,0.0};
	if( IsPlayerAlive(client) && GAME ==GAME_CSGO ) {
		
		SetVariantString( "!activator" );
		AcceptEntityInput( ent_controller[newclient], "SetParent", client );
		if( GAME == GAME_CSGO ){ 
	
			SetVariantString( "weapon_bone" );
			AcceptEntityInput( ent_controller[newclient], "SetParentAttachment" );
		} else {
			//SetVariantString( "muzzle_flash" ); // (dumb)
			//ang[0] = -45.0; ang[1] = 45.0; ang[2] = 0.0;
			ang[0] = 0.0; ang[1] = 0.0; ang[2] = 0.0;
			vec[2] += 40.0;
			vec[1] += 10.0;
		}
		//AcceptEntityInput( ent_controller[newclient], "DisableMotion" );
	} else {
		vec[0] -= 15.0;
		vec[2] -= 8.0;

		vec[0] += playervec[0];
		vec[1] += playervec[1];
		vec[2] += playervec[2];// + 64.0;
		
		ang[0] = -30.0;
		ang[1] = 180.0;
		ang[2] = 0.0;

		if( GAME == GAME_CSS ) {
			vec[2] += 64.0;
		}
		
		//SetVariantString( "!activator" );
		//AcceptEntityInput( ent_controller[newclient], "SetParent", client );
		AcceptEntityInput( ent_controller[newclient], "DisableMotion" );
		SetEntityMoveType( ent_controller[newclient], MOVETYPE_NONE );
		SetEntProp( ent_controller[newclient], Prop_Send, "m_CollisionGroup", 2 );
	}
	
	TeleportEntity( ent_controller[newclient], vec, ang, NULL_VECTOR );
	
	
	
	if( !controller_plugged_in[newclient] ) {
		ShowPlug(newclient);
		controller_plugged_in[newclient] = true;
	}
	ShowControllerCord(newclient);
	block_e[newclient] =true;
	looking_at_weapon[newclient] = false;

	SetClientNoblock( client );

}

//------------------------------------------------------------------------------------------------------------
UnhookClient( client, bool:resetclient=true ) {
	new bool:hooked;
	new hooked_index;
	if( game_clients[0] == client ) {
		hooked_index = 0;
		hooked=true;
		game_clients[0] = 0;
	} else if( game_clients[1] == client ) {
		hooked_index = 1;
		hooked=true;
		game_clients[1] = 0;
	} else {
		return;
	}
	
	game_buttons[hooked_index] = 0;
	game_buttons_last[hooked_index] = 0;
	controller_being_used[hooked_index] = false;
	
	if( !IsClientInGame(client) || !resetclient ) return;
	
	if( hooked ) {
	
		
		
		
		UnsetClientNoblock( client );

		if( !IsPlayerAlive(client) ) {
			SetEntProp( client, Prop_Send, "m_iHideHUD", (GetEntProp( client, Prop_Send, "m_iHideHUD" ) | (1<<3)|(1<<4)) & ~(HIDEHUD_CROSSHAIR) );
			SetEntProp( client, Prop_Send, "m_iObserverMode", 6 );
			SetEntityMoveType( client, MOVETYPE_OBSERVER );
		} else {
			SetEntProp( client, Prop_Send, "m_iHideHUD", GetEntProp( client, Prop_Send, "m_iHideHUD" ) & (~HIDEHUD_CROSSHAIR)  );
			SetEntityMoveType( client, MOVETYPE_WALK );
		}
	}
	
	if( game_setup ) {
		//HidePlug(hooked_index);
		AcceptEntityInput( ent_controller[hooked_index], "ClearParent" );
		AcceptEntityInput( ent_controller[hooked_index], "EnableMotion" );
		//TeleportEntity( ent_controller[hooked_index], controller_creation_point[hooked_index], controller_creation_angles[hooked_index], NULL_VECTOR );
		new Float:vel[3] = {0.0,0.0,50.0};
		SetEntityMoveType( ent_controller[hooked_index], MOVETYPE_VPHYSICS );
		TeleportEntity( ent_controller[hooked_index], NULL_VECTOR, NULL_VECTOR, vel );
		
		ControllerCordThing(hooked_index);
	}
}

bool:AreClientsPlaying() {
	return game_clients[0] >0 || game_clients[1] >0;
}

bool:IsClientHooked(client) {
	if( game_clients[0] == client ) {
		return true;
	} else if( game_clients[1] == client ) {
		return true;
	}
	return false;
}

public Action:Ghosting_OnAllowCmd( client ) {

	// block ghost action if client is hooked
	if( game_clients[0] == client || game_clients[1] == client ) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:Ghosting_OnUse( client, entity ) {

	OnPlayerUse( client, entity );
	
}