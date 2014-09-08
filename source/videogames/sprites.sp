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
ResetSprites() {
	//if( sprite_list_active != INVALID_HANDLE ) CloseHandle( sprite_list_active );
	if( sprite_list_inactive != INVALID_HANDLE ) CloseHandle( sprite_list_inactive );
	//sprite_list_active = CreateStack();
	sprite_list_inactive = CreateStack();
	
	for( new i = 0; i < MAX_SPRITES; i++ ) {

		PushStackCell( sprite_list_inactive, i );
		sprite_active[i] = 0;
		
	}
}

//------------------------------------------------------------------------------------------------------------
HWInit_Sprites() {
	ResetSprites();
	for( new i = 0; i < MAX_SPRITES; i++ ) {
		//SetEdictFlags( sprite_ent[i], GetEdictFlags(sprite_ent[i]) | FL_EDICT_DONTSEND );
		AcceptEntityInput( sprite_ent[i], "TurnOff" );
	}
}

//------------------------------------------------------------------------------------------------------------
CreateSprite( const String:model[] ) {
	if( !GameActive() ) return -1;
	
	new id;
	
	if( (!PopStackCell( sprite_list_inactive, id )) ) {
		return -1;
	}
	
	new ent = sprite_ent[id];
	
	sprite_active[id] = 1;
	sprite_flags[id] = 0;

	if( c_vg_hdr ) {
		SetSpriteColor(id, 128,128,128,255);
	} else {
		SetSpriteColor(id, 255,255,255,255);
	}
	SetSpriteTexture( id, 0 );
	
	
	SetEntityModel( ent, model );  
	SetEntPropFloat( ent, Prop_Send, "m_flModelScale", PIXEL_UNIT );
	 
	
 
	//SetEdictFlags( ent, GetEdictFlags(ent) | FL_EDICT_DONTSEND );
	AcceptEntityInput( ent, "TurnOff" );
	
	sprite_x[id] = -100;
	
	return id;
}

//------------------------------------------------------------------------------------------------------------
DeleteSprite( id ) {
	if( !GameActive() ) return;
	if( !sprite_active[id] ) {
		//SetFailState( "DeleteSprite attempted on an inactive sprite" );
		return;
	}
	 
	//SetEdictFlags( sprite_ent[id], GetEdictFlags(sprite_ent[id]) | FL_EDICT_DONTSEND );
	AcceptEntityInput( sprite_ent[id], "TurnOff" );
	sprite_active[id] = 0;
	PushStackCell( sprite_list_inactive, id );
}

Sprites_DeleteAll() {
	if( !GameActive() ) return;
	for( new i = 0; i < MAX_SPRITES; i++ ) {
		if( sprite_active[i] ) {
			DeleteSprite(i);
		}
	}
}

//------------------------------------------------------------------------------------------------------------
GetSpritePosition( id, &x, &y ) {
	x=0;
	y=0;
	if( !GameActive() ) return;
//	if( !sprite_active[id] ) {
	//	SetFailState( "GetSpritePosition attempted on an inactive sprite" );
//		return;
//	}
	
	x = sprite_x[id];
	y = sprite_y[id];
	
}

//------------------------------------------------------------------------------------------------------------
SetSpritePosition( id, x, y ) {
	if( !GameActive() ) return;
//	if( !sprite_active[id] ) {
	//	SetFailState( "SetSpritePosition attempted on an inactive sprite" );
//		return;
//	}
	
	sprite_x[id] = x;
	sprite_y[id] = y;
	sprite_flags[id] |= SPRITEFLAG_UPDATEPOS;
}

//------------------------------------------------------------------------------------------------------------
SetSpriteTexture( id, frame ) {
	if( !GameActive() ) return;
//	if( !sprite_active[id] ) {
		//SetFailState( "SetSpriteFrame attempted on an inactive sprite" );
//		return;
//	}
	
	if( sprite_frame[id] == frame ) return;
	sprite_frame[id] = frame;
	sprite_flags[id] |= SPRITEFLAG_UPDATEFRAME;
} 

SetSpriteColor( id, r, g, b, a ) {
//	if( !sprite_active[id] ) {
//		return;
//	}
	if( !c_vg_hdr ) {
		r *= 2;
		g *= 2;
		b *= 2;
		if( r > 255 ) r = 255;
		if( g > 255 ) g = 255;
		if( b > 255 ) b = 255;
	}
	
	sprite_rgb[id] = (r) | ((g)<<8) | ((b)<<16);
	
	sprite_alpha[id] = a;
	sprite_flags[id] |= SPRITEFLAG_SETCOLOR; 
}

//------------------------------------------------------------------------------------------------------------
TryTeleportSprite( id ) {
	if( sprite_flags[id] & SPRITEFLAG_UPDATEPOS ) {
		decl Float:pos[3];
		pos[0] = LAYER3_Z;
		pos[1] = ( float(sprite_x[id] - scroll_position)) * PIXEL_UNIT;
		pos[2] = (-float(sprite_y[id])) * PIXEL_UNIT;
		
		TeleportEntity( sprite_ent[id], pos, NULL_VECTOR, NULL_VECTOR );
		sprite_flags[id] -= SPRITEFLAG_UPDATEPOS;
		update_time -= UPDATE_TIME_TELEPORT;
	}
}

//------------------------------------------------------------------------------------------------------------
UpdateSprites() {
	for( new i = 0; i < MAX_SPRITES; i++ ) {
		if( !sprite_active[i] ) continue;
		
		if( scroll_changed ) sprite_flags[i] |= SPRITEFLAG_UPDATEPOS;
		
		// set frame
		if( update_time > 0 ) {
			if( sprite_flags[i] & SPRITEFLAG_UPDATEFRAME ) {
				 
				SetEntProp( sprite_ent[i], Prop_Send, "m_iTextureFrameIndex", sprite_frame[i] );
				//SetEntPropFloat( sprite_ent[i], Prop_Send, "m_flFrame", float(65) );
				
				sprite_flags[i] -= SPRITEFLAG_UPDATEFRAME;
				update_time -= UPDATE_TIME_TEXTUREFRAME;
			}
			
			if( sprite_flags[i] & SPRITEFLAG_SETCOLOR ) {
				SetEntityRenderColor( sprite_ent[i], sprite_rgb[i] & 255, (sprite_rgb[i]>>8)&255, (sprite_rgb[i]>>16)&255, sprite_alpha[i] );
				sprite_flags[i] -= SPRITEFLAG_SETCOLOR;
				update_time -= UPDATE_TIME_COLOR;
			}
		}
		//SetEntPropFloat( sprite_ent[i], Prop_Send, "m_flFrame", float('A') );
		
		// clipping
		new x = sprite_x[i] - scroll_position;
		if( sprite_flags[i] & SPRITEFLAG_ONSCREEN ) {
			if( x <= -16 || x >= SCREEN_WIDTH ) {
				sprite_flags[i] -= SPRITEFLAG_ONSCREEN;
				//AcceptEntityInput( sprite_ent[i], "HideSprite" );
				//SetEdictFlags( sprite_ent[i], GetEdictFlags(sprite_ent[i]) | FL_EDICT_DONTSEND );
				AcceptEntityInput( sprite_ent[i], "TurnOff" );
			}
		} else {
			if( (x > -16 && x < SCREEN_WIDTH) ) {
				sprite_flags[i] |= SPRITEFLAG_ONSCREEN;
				TryTeleportSprite( i );
				//AcceptEntityInput( sprite_ent[i], "ShowSprite" );
				//SetEdictFlags( sprite_ent[i], GetEdictFlags(sprite_ent[i]) & (~FL_EDICT_DONTSEND) );
				AcceptEntityInput( sprite_ent[i], "TurnOn" );
			}
		}
		
		// positioning
		if( sprite_flags[i] & SPRITEFLAG_ONSCREEN ) {
			TryTeleportSprite( i );
		}
	}
}

//------------------------------------------------------------------------------------------------------------
ScreenRefreshSprites() {
	for( new i = 0; i < MAX_SPRITES; i++ ) {
		sprite_flags[i] |= SPRITEFLAG_UPDATEPOS;
	}
}
