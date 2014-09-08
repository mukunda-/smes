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


#define TEXTDIRTYADD if( !(text_flags[index] & TEXTFLAG_UPDATE) ) { FIFO_Push( text_dirty_fifo, sizeof(text_dirty_fifo), text_dirty_fifo_read, text_dirty_fifo_write, index ); text_flags[index] |= TEXTFLAG_UPDATE; }

//-------------------------------------------------------------------------------------------------
HWInit_Text() {
	for( new i = 0; i < TEXT_ENTS; i++ ) {
		text_on[i] = false;
		text_flags[i] &= ~TEXTFLAG_ON;
		SetEdictFlags( text_ents[i], (GetEdictFlags(text_ents[i])|FL_EDICT_DONTSEND) );
	}
 
	for( new i = 0; i < 4; i++ ) {
		Text_SetOffsetParam( i, 0, 0, 0 );
	}
}

//-------------------------------------------------------------------------------------------------
Text_SetModel( index, const String:model[] ) {

	if( StrEqual( model, text_model[index] ) ) {
		return;
	}
	strcopy( text_model[index], sizeof(text_model[]), model );
	TEXTDIRTYADD
	text_flags[index] |= TEXTFLAG_MODEL;
}

//-------------------------------------------------------------------------------------------------
Text_SetModelBatch( index, count, const String:model[] ) {
	for( new i = 0; i < count; i++ ) {
		Text_SetModel( index+i, model );
	}
}

//-------------------------------------------------------------------------------------------------
Text_SetPosition( index, x, y ) {
	if( text_pos[index][0] == x && text_pos[index][1] == y ) return;
	text_pos[index][0] = x;
	text_pos[index][1] = y;
	TEXTDIRTYADD
	text_flags[index] |= TEXTFLAG_POSITION;
}

//-------------------------------------------------------------------------------------------------
Text_SetPositionGrid( index, count, x, y, columns, spacing_h, spacing_v ) {
	
	new xcounter;
	new ycounter;
	
	for( new i = 0; i < count; i++ ) {
		Text_SetPosition( index+i, x + xcounter * spacing_h, y + ycounter * spacing_v );
		xcounter++;
		if( xcounter == columns ) {
			xcounter = 0;
			ycounter++;
		}
	}
}
/*
//-------------------------------------------------------------------------------------------------
Text_SetLayer( index, layer ) {
	if( layer < 1 || layer > 3 ) return;
	if( text_layer[index] == layer ) return;
	text_layer[index] = layer;
	TEXTDIRTYADD
	text_flags[index] |= TEXTFLAG_POSITION;
}

//-------------------------------------------------------------------------------------------------
Text_SetLayerBatch( index, count, layer ) {
	for( new i = 0; i < count; i++ ) {
		Text_SetLayer( index+i, layer );
	}
}
*/
//-------------------------------------------------------------------------------------------------
Text_SetOffset( index, offset ) {
	if( offset < 0 || offset > 3 ) return;
	if( text_offset[index] == offset ) return;
	text_offset[index] = offset;
	TEXTDIRTYADD
	text_flags[index] |= TEXTFLAG_OFFSET|TEXTFLAG_POSITION;
}

//-------------------------------------------------------------------------------------------------
Text_SetOffsetBatch( index, count, offset ) {
	for( new i = 0; i < count; i++ ) {
		Text_SetOffset( index+i, offset );
	}
}

//-------------------------------------------------------------------------------------------------
Text_SetOn( index, bool:on ) {
	if( text_on[index] == on ) return;

	text_on[index] = on; 
	
	if( on ) {
		TEXTDIRTYADD
		text_flags[index] |= TEXTFLAG_ON;
		text_ontime[index] = 2;
	} else {
		text_flags[index] &= ~TEXTFLAG_ON;
		SetEdictFlags( text_ents[index], GetEdictFlags(text_ents[index])|FL_EDICT_DONTSEND );
	}
}

//-------------------------------------------------------------------------------------------------
Text_SetOnBatch( index, count, bool:on ) {
	for( new i = 0; i < count; i++ ) {
		Text_SetOn( index+i, on );
	}
}

//-------------------------------------------------------------------------------------------------

Text_SetSize( index, size ) {
	if( text_size[index] == size ) return;
	text_size[index] = size;
	TEXTDIRTYADD
	text_flags[index] |= TEXTFLAG_SIZE;
}

//-------------------------------------------------------------------------------------------------
Text_SetSizeBatch( index, count, size ) {
	for( new i = 0; i < count; i++ ) {
		Text_SetSize( index+i, size );
	}
}

//-------------------------------------------------------------------------------------------------
Text_SetColor( index, color ) {
	if( !c_vg_hdr ) {

		// nastiness v2.0
		new r,g,b,a;
		r = color&0xFF;
		g = (color>>8)&0xFF;
		b = (color>>16)&0xFF;
		a = (color>>24)&0xFF;
		r <<= 1;
		g <<= 1;
		b <<= 1;
		if( r > 255 ) r = 255;
		if( g > 255 ) g = 255;
		if( b > 255 )b = 255;

		color = r | (g<<8) | (b<<16) | (a<<24);
	}
	if( text_color[index] == color ) return;
	text_color[index]  = color;
	TEXTDIRTYADD
	text_flags[index]|= TEXTFLAG_COLOR;
}

//-------------------------------------------------------------------------------------------------
Text_SetColorBatch( index, count, color ) {
	for( new i = 0; i < count; i++ ) {
		Text_SetColor( index+i, color );
	}
}

//-------------------------------------------------------------------------------------------------
Text_SetFrame( index, frame ) {
	if( text_frame[index] == frame ) return;
	text_frame[index] = frame;
	TEXTDIRTYADD
	text_flags[index]|= TEXTFLAG_FRAME;
}

//-------------------------------------------------------------------------------------------------
Text_SetFrameBatch( index, count, frame ) {
	for( new i = 0; i < count; i++ ) {
		Text_SetFrame( index+i, frame );
	}
}

//-------------------------------------------------------------------------------------------------
Text_DrawString( index, count, const String:text[], frameoffset, bool:pad=true, padframe=0 ) {
	new i;
	for( i = 0; text[i] && i < count; i++ ) {
		Text_SetFrame( index+i, frameoffset + text[i] );
	}
	if( !pad ) return;
	for( ; i < count; i++ ) {
		Text_SetFrame( index+i, padframe );
	}
}

//-------------------------------------------------------------------------------------------------
Text_SetOffsetParam( set, x, y, layer ) {
	if( layer < 0 || layer > 3 ) return; 
	if( tscroll_pos[set][0] == x && tscroll_pos[set][1] == y && tscroll_pos[set][2] == layer ) return;
	tscroll_pos[set][0] = x;
	tscroll_pos[set][1] = y;
	tscroll_pos[set][2] = layer;
	tscroll_dirty[set] = 1;
}

//-------------------------------------------------------------------------------------------------
Text_TeleportScrollers( bool:force=false ) {
	if( game_broken ) return;
	for( new i = 0; i < 4; i++ ) {
		if( tscroll_dirty[i] || force ) {
			tscroll_dirty[i] = 0;
			decl Float:vec[3];
	
			vec[0] = screen_origin_adjusted[0];
			if( screen_state < SCREENSTATE_ON || tscroll_pos[i][2] == 0 ) {
				vec[0] -= 1.5;
			} else {
				vec[0] += float(tscroll_pos[i][2]) * 0.05;
			}
			vec[1] = screen_origin_adjusted[1] + float(tscroll_pos[i][0]) * PIXEL_UNIT;
			vec[2] = screen_origin_adjusted[2] - float(tscroll_pos[i][1]) * PIXEL_UNIT;
	
			TeleportEntity( tscroll_ents[i], vec, NULL_VECTOR, NULL_VECTOR );
			
			if( !force ) update_time -= UPDATE_TIME_TELEPORT;
		}
	}
}

//-------------------------------------------------------------------------------------------------
Text_Update() {
	if( game_broken ) return;
	if( update_time <= 0 ) return;
	
	Text_TeleportScrollers();
	
	new count = FIFO_Size( sizeof( text_dirty_fifo ), text_dirty_fifo_read, text_dirty_fifo_write );
	new index;
	while( count ) {
		count--;
		index = FIFO_Pop( text_dirty_fifo, sizeof(text_dirty_fifo), text_dirty_fifo_read, text_dirty_fifo_write, -1 );
		
		new flags = text_flags[index];
		text_flags[index] = 0;
		new ent = text_ents[index];
		
		if( flags & TEXTFLAG_MODEL ) {
			
			SetEntityModel( ent, text_model[index] );
			 
			update_time -= UPDATE_TIME_MODEL;
		}
		
		if( flags & TEXTFLAG_SIZE ) {
			SetEntPropFloat( ent, Prop_Send, "m_flModelScale", float(text_size[index]) * PIXEL_UNIT );
		}

		if( flags & TEXTFLAG_OFFSET ) {
			AcceptEntityInput( ent, "ClearParent" );
			SetVariantString( "!activator" );
			AcceptEntityInput( ent, "SetParent", tscroll_ents[text_offset[index]] );
		}
		
		
		if( flags & TEXTFLAG_FRAME ) {
			//if( !(flags & TEXTFLAG_WAIT) ) {
			//	if( text_on[index] ) {
			SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", text_frame[index] );
			//	} else {
			//		SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", 0 );
			//	}
			update_time -= UPDATE_TIME_TEXTUREFRAME;
				
			//} else {
			//	SetEntProp( ent, Prop_Send, "m_iTextureFrameIndex", 0 );
			//	update_time -= UPDATE_TIME_TEXTUREFRAME;
			//}
		}
		
		if( flags & TEXTFLAG_COLOR ) {

			new a = ((text_color[index] >> 24) & 0xFF) * 2;
			a = a > 255 ? 255 : a;
			SetEntityRenderColor( ent, text_color[index] & 0xFF, (text_color[index]>>8)&255, (text_color[index]>>16)&255, a );
			update_time -= UPDATE_TIME_COLOR;
		}

		if( flags & TEXTFLAG_POSITION ) {
			
			
			decl Float:vec[3];
			vec[0] = 0.0;// float(text_layer[index]) * 0.05;
			vec[1] = float(text_pos[index][0]) * PIXEL_UNIT;
			vec[2] = -float(text_pos[index][1]) * PIXEL_UNIT;
			
			TeleportEntity( ent, vec, NULL_VECTOR, NULL_VECTOR );
			
			//SetEdictFlags( text_ents[index], (GetEdictFlags(text_ents[index])|FL_EDICT_DONTSEND) );
			update_time -= UPDATE_TIME_TELEPORT;
		}
		 
		
		if( flags & TEXTFLAG_ON ) {
			text_ontime[index]--;
			if( text_ontime[index] == 0 ) {
				SetEdictFlags( ent, GetEdictFlags(text_ents[index])&(~FL_EDICT_DONTSEND) );
			} else {
				SetEdictFlags( text_ents[index], GetEdictFlags(text_ents[index])|FL_EDICT_DONTSEND );
				text_flags[index] |= TEXTFLAG_ON|TEXTFLAG_UPDATE;
				FIFO_Push( text_dirty_fifo, sizeof(text_dirty_fifo), text_dirty_fifo_read, text_dirty_fifo_write, index );
			}
		} else if( !text_on[index] ) {
			SetEdictFlags( text_ents[index], GetEdictFlags(text_ents[index])|FL_EDICT_DONTSEND );
		}
		
		if( update_time <= 0 ) return;
	}
	

	
}
