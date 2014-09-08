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

InitBGSystem() {
	
}

ProcessTilemap( start, end, VGEventProcessTilemap:callback ) {
	for( new x = start; x <= end; x++ ) {
		for( new y = 0; y < MAP_HEIGHT; y++ ) {
		
			Call_StartFunction( controlling_plugin, callback );
			Call_PushCell(x);
			Call_PushCell(y);
			Call_PushCell(tilemap[x+y*MAP_WIDTH]);
			new result;
			Call_Finish(result);
			
			tilemap[x+y*MAP_WIDTH] = result;
		}
	}
}
//------------------------------------------------------------------------------------------------------------
LoadTilemap( const String:filename[], offset=0, destx=0, desty=0 ) {
	decl String:path[256]; 
	if( active_game_id[0] == 0 ) return 0;
	BuildPath( Path_SM, path, sizeof(path), "data/videogames/%s/%s", active_game_id, filename );
	 
	///decl String:dataline[2048];
	
	new Handle:file = OpenFile( path, "rb" );
	
	new width,height;
	ReadFileCell(file, width,4);
	ReadFileCell(file, height,4);
	 
	
	if( width > 2048 ) {
		SetFailState( "tried to load invalid tilemap" );
		return 0;
	}
	
	for( new line = 0; line < height; line++ ) {
		if( (desty+line) >= MAP_HEIGHT ) break;
		new amount = width;
		if( amount > MAP_WIDTH-destx ) amount = MAP_WIDTH-destx;
		new start = destx+(desty+line)*MAP_WIDTH;
		ReadFileString( file, tilemap[start], amount, amount );
		if( offset ) for( new i = 0; i < amount; i++ ) tilemap[start+i] += offset;
		if( amount < width ) FileSeek( file, width-amount, SEEK_SET );
		
	}
	
	//ReadFileString( file, tilemap, sizeof(tilemap), MAP_WIDTH*MAP_HEIGHT );
	
	
	CloseHandle(file);
	return width;
}

//------------------------------------------------------------------------------------------------------------
SetBGModel( const String:model[] ) {
	
	strcopy( bg_model, sizeof(bg_model), model );
	for( new i = 0; i < BG_WIDTH*BG_HEIGHT; i++ ) {
		if( !bg_dirty[i] ) FIFO_Push( bg_dirty_fifo, sizeof(bg_dirty_fifo), bg_dirty_fifo_read, bg_dirty_fifo_write, i );
		
		bg_dirty[i] |= BGD_MODEL;
	}
}

//------------------------------------------------------------------------------------------------------------
SetBackdrop( r, g, b ) {
	if( game_broken ) return;
	if( c_vg_hdr ) {
		SetEntityRenderColor( backdrop_ent, r, g, b );
	} else {
		SetEntityRenderColor( backdrop_ent, clampcolor(r*2), clampcolor(g*2), clampcolor(b*2) );
	}
}
/*
//------------------------------------------------------------------------------------------------------------
DeleteBG() {
	if( bg_ready ) {
		bg_ready = false;
	}
	bg_created = false;
	bg_delete_state = 1;
}

//------------------------------------------------------------------------------------------------------------
SetupBG( const String:model[] ) {
	strcopy( bg_model, sizeof(bg_model), model );
	
	if( bg_ready ) {
		bg_ready = false;
		bg_delete_state = 1;
	}
	
	
	if( bg_setup_state == 0 ) {
		bg_setup_state = 1;
	}
}*/


//------------------------------------------------------------------------------------------------------------
GetScroll() {
	return desired_scroll_position;
}

//------------------------------------------------------------------------------------------------------------
SetScroll( scroll ) {
	desired_scroll_position = scroll;
	
	new max_scroll = MAP_WIDTH*16 - SCREEN_WIDTH - 16;
	if( desired_scroll_position < 0 ) desired_scroll_position = 0;
	if( desired_scroll_position > max_scroll ) desired_scroll_position = max_scroll;
}

//------------------------------------------------------------------------------------------------------------
SetScreenRefresh() {
	screen_refresh = 1;//
}

//------------------------------------------------------------------------------------------------------------
SetTile( x, y, tile ) {
	tilemap[x+y*MAP_WIDTH] = tile;
	new bg_tilemap_offset = (scroll_position>>4);
	if( x >= bg_tilemap_offset && x < (bg_tilemap_offset+BG_WIDTH) ) {
		
		new index = ((x)% BG_WIDTH) + y * BG_WIDTH;
		if( !bg_dirty[index] ) {
			FIFO_Push( bg_dirty_fifo, sizeof(bg_dirty_fifo), bg_dirty_fifo_read, bg_dirty_fifo_write, index );
		}
		bg_dirty[ index ] |= BGD_TILE;
	}
}

//------------------------------------------------------------------------------------------------------------
GetTile( x, y ) {
	if( x < 0 || y < 0 || x >= MAP_WIDTH || y >= MAP_HEIGHT ) return -1;
	return tilemap[x+y*MAP_WIDTH];
}

//------------------------------------------------------------------------------------------------------------
SetBgDirty( x, y, flags ) {
	if( !flags ) return;
	
	new index = x + y * BG_WIDTH;
	if( !bg_dirty[index] ) FIFO_Push( bg_dirty_fifo, sizeof(bg_dirty_fifo), bg_dirty_fifo_read, bg_dirty_fifo_write, index );
	bg_dirty[index] |= flags;
}

#pragma unused SetBgDirtyIndex
//------------------------------------------------------------------------------------------------------------
SetBgDirtyIndex( i, flags ) {
	if( !bg_dirty[i] ) FIFO_Push( bg_dirty_fifo, sizeof(bg_dirty_fifo), bg_dirty_fifo_read, bg_dirty_fifo_write, i);
	bg_dirty[i] |= flags;
}

//------------------------------------------------------------------------------------------------------------
UpdateBgScroll() {
	if( desired_scroll_position == scroll_position ) return; // in sync
	
	//if( desired_scroll_position == last_scroll_position ) return;
	last_scroll_position = scroll_position;
	scroll_position = desired_scroll_position;
	scroll_changed = true;

	/* DEBUG BYPASS
	if( screen_refresh ) {
		scroll_position = desired_scroll_position;
	} else {
		new diff = desired_scroll_position - scroll_position;
		if( diff > MAX_SCROLL_PER_FRAME ) diff = MAX_SCROLL_PER_FRAME;
		if( diff < -MAX_SCROLL_PER_FRAME ) diff = -MAX_SCROLL_PER_FRAME;
		scroll_position += diff;
	}*/
	
	new bg_draw_offset = (last_scroll_position >> 4) % BG_WIDTH;
	new tileint = scroll_position >> 4;
	new bg_tilemap_offset = last_scroll_position >> 4;
	new difference = tileint - bg_tilemap_offset;
	
	if( screen_refresh ) return;
	
	if( difference != 0 ) {
	
		if( difference <= -BG_WIDTH || difference >= BG_WIDTH ) { 
			SetScreenRefresh();
			return;
		}
		
		new Float:vecbase[3];// = {0.0,3.9,-0.3};
		vecbase[1] += float((scroll_position >>4)) * PIXEL_UNIT * 16.0;
		
		if( difference > 0 ) {
			for( new x = 0; x < difference; x++ ) {
				new slice = (bg_draw_offset + x) % BG_WIDTH;
				//new tileslice = bg_tilemap_offset + BG_WIDTH - difference + x;
				for( new y = 0; y < BG_HEIGHT; y++ ) {
					SetBgDirty( slice, y, BGD_TILE );
					//new ent = bg_ents[slice + y * BG_WIDTH];
					//SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", tilemap[tileslice + y * MAP_WIDTH] -1 );
					//decl Float:vec[3];
					//vec[0] = vecbase[0] + LAYER2_Z;
					//vec[1] = vecbase[1] + float(BG_WIDTH-difference+ x) * 4.0;
					//vec[2] = vecbase[2] - float(y) * 4.0;
					//TeleportEntity( ent, vec, NULL_VECTOR, NULL_VECTOR );
				}
			}
			
		} else if( difference < 0 ) {
			for( new x = 0; x < -difference; x++ ) {
				new slice = (bg_draw_offset + difference + x + BG_WIDTH) % BG_WIDTH;
				//new tileslice = bg_tilemap_offset + x;
				for( new y = 0; y < BG_HEIGHT; y++ ) {
					SetBgDirty( slice, y, BGD_TILE );
				//	new ent = bg_ents[slice + y * BG_WIDTH];
				//	SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", tilemap[tileslice + y * MAP_WIDTH] -1 );
				//	decl Float:vec[3];
				//	vec[0] = vecbase[0] + 0.05;
				//	vec[1] = vecbase[1] + float(x) * 4.0;
				//	vec[2] = vecbase[2] - float(y) * 4.0;
				//	TeleportEntity( ent, vec, NULL_VECTOR, NULL_VECTOR );
				}
			}
		}
		bg_draw_offset = (bg_draw_offset+ difference+BG_WIDTH) % BG_WIDTH;
	}
	
	
	
}

//------------------------------------------------------------------------------------------------------------
UpdateBgDirty() {
	 // update dirty bg entities
	 
	//new Float:xbase = float((scroll_position >> 4)) * PIXEL_UNIT * 16.0;
	new index;
	while( (index=FIFO_Pop( bg_dirty_fifo, sizeof(bg_dirty_fifo), bg_dirty_fifo_read, bg_dirty_fifo_write, -1 )) != -1 ) {
		
		
		new flags = bg_dirty[index];
		bg_dirty[index] = 0;
		new y = index / BG_WIDTH;
		new x = index - y*BG_WIDTH;
		
		//new screen_x = (x - bg_draw_offset + BG_WIDTH) % BG_WIDTH;

		new bg_tilemap_offset = (scroll_position>>4);
		new bg_draw_offset = (scroll_position >> 4) % BG_WIDTH;
		new screen_x = bg_tilemap_offset + ((x - bg_draw_offset + BG_WIDTH)%BG_WIDTH);
		//((x - (bg_tilemap_offset % BG_WIDTH)) + BG_WIDTH) % BG_WIDTH;
		
		if( flags & BGD_TILE ) { 
			new tile = tilemap[y*MAP_WIDTH + screen_x];
			if( bg_tile[index] != tile ) {
				bg_tile[index] = tile;
				SetEntProp( bg_ents[index], Prop_Send, "m_iTextureFrameIndex", tile );
				update_time -= UPDATE_TIME_TEXTUREFRAME;
			}
		}
		/*
		if( flags & BGD_POS ) { 
			decl Float:vec[3];
			vec[0] = LAYER2_Z;
			vec[1] = xbase + float(screen_x + scroller_offset) * (PIXEL_UNIT*16.0);
			vec[2] = -float(y) * (PIXEL_UNIT*16.0);
//			TeleportEntity( bg_ents[index], vec, NULL_VECTOR, NULL_VECTOR );
			update_time -= UPDATE_TIME_TELEPORT;
		}*/
		
		if( flags & BGD_MODEL ) { 
			SetEntityModel( bg_ents[index], bg_model );
			
			update_time -= UPDATE_TIME_MODEL;
		}
		
		
		if( update_time <= 0 ) return;
	}
}

//------------------------------------------------------------------------------------------------------------
ScreenRefreshBg() {
	if( !GameActive() ) return;
	
	//
	// this function does not teleport the bg entities and is used for long scrolls
	//   
	
//	new tileint = scroll_position >> 4;
//	scroller_offset += bg_tilemap_offset - tileint;
//	bg_tilemap_offset = tileint;
	
	//new tilefrac = scroll_position & 15;
	//new Float:vecbase[3];
	
	//bg_draw_offset = 0;
//	bg_tilemap_offset = tileint;
	
	//vecbase[1] = float(scroll_position / 16 * 4);
	//vecbase[1] += 3.9;
	//vecbase[2] -= 0.3;
	
	/*
	for( new y = 0; y < BG_HEIGHT; y++ ) {
		for( new x = 0; x < BG_WIDTH; x++ ) {
			
			new ent = bg_ents[x+y*BG_WIDTH];
			SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", tilemap[tileint + x + y * MAP_WIDTH] -1 );
			decl Float:vec[3];
			vec[0] = vecbase[0] + 0.05;
			vec[1] = vecbase[1] + x * 4.0;
			vec[2] = vecbase[2] - y * 4.0;
			TeleportEntity( ent, vec, NULL_VECTOR, NULL_VECTOR );
		}
	}*/
	
	for( new i = 0; i < BG_WIDTH*BG_HEIGHT; i++ ) {
		if( !bg_dirty[i] ) FIFO_Push( bg_dirty_fifo, sizeof(bg_dirty_fifo), bg_dirty_fifo_read, bg_dirty_fifo_write, i);
		bg_dirty[i] |= BGD_TILE;
	}
	
	//TeleportScroller();
}

//------------------------------------------------------------------------------------------------------------
TeleportScroller( bool:force = false ) {
	if( game_broken ) return;
	
	if( force ) { // screen state changed
		decl Float:vec[3];
	
		vec[0] = screen_origin_adjusted[0];
	
		if( screen_state < SCREENSTATE_ON ) {
			vec[0] -= 1.5; 
		}
	
//		new pos = scroll_position - scroller_offset * 16;
//	
//		if( pos == scroller_abs_position && !force ) return;
//		scroller_abs_position = pos;
	
		vec[1] =  screen_origin_adjusted[1];// - float(pos) * PIXEL_UNIT;///scroll_position) * PIXEL_UNIT - float(scroller_offset) * (PIXEL_UNIT*16.0);
		vec[2] = screen_origin_adjusted[2];
	
	
		TeleportEntity( scroller, vec, NULL_VECTOR, NULL_VECTOR );
	}
	
	if( scroll_changed ) {
		SetEntProp( scroller, Prop_Send, "m_nSequence",scroll_position % 272 );
	}
}
