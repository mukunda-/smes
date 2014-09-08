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

new bios_state;

new bios_sprite_logo;

new bios_logo_scroll;

#define BIOS_VERSION "1.0.4"

public VG_OnEntry() {

	
	if( GetConVarInt( sm_vg_fastbios ) != 0 && GetCartridgeIndex() != 0 ) {
		bios_state = 4;
		return;
	}
	 
	VG_SetBackdrop(  0,0,0 );
	VG_SetFramerate( 20.0 );
	VG_SetUpdateTime( 900 );
	VG_Text_SetModelBatch( 0, TEXT_ENTS, MODEL_DEFONT );
	VG_Text_SetSizeBatch( 0, TEXT_ENTS, 1 );
	
	VG_Text_SetPositionGrid( 0, 64, 0, 64, 16, 16, 16 );
	//VG_Text_SetLayerBatch( 0, 64, 3 );
	VG_Text_SetFrameBatch( 0, 64, 219 );
	VG_Text_SetColorBatch( 0, 64, 0x80800000 );
	VG_Text_SetOnBatch( 0, 64, true );
	VG_Text_SetOffsetBatch( 0, 64, 0 );
	VG_Text_SetOffsetParam( 0, 0, 0, 3 );

	
	// give the console time to initialize
	VG_Sleep(30);
	
	bios_state = 0;
	
}

public BIOS_Precache() {
	PrecacheModel( "models/videogames/smes_logo.mdl" );
}


public VG_OnFrame() {
	if( bios_state == 0 ) {
		SetScreenState( SCREENSTATE_ON );
		VG_SetBackdrop(  0,0,128 );
		
		
		
		bios_sprite_logo = VG_Sprites_Create( "models/videogames/smes_logo.mdl" ); 
		VG_Sprites_SetPosition( bios_sprite_logo, 64,64 );
		bios_logo_scroll = 0;
		bios_state = 1;
		
		
	} else if( bios_state == 1) {
		bios_logo_scroll++;
		VG_Sprites_SetPosition( bios_sprite_logo, 64, 64-bios_logo_scroll );
		//VG_Sprites_SetColor( bios_sprite_logo, 128, 128, 128, bios_logo_scroll * 255 / 32 );
		if( bios_logo_scroll == 50 ) {
			bios_state = 2;
			
			// hide masking layer
			VG_Text_SetOffsetParam( 0, 0, 0,0 );
			VG_Sleep(20);
		}
	} else if( bios_state == 2 ) {
	
		bios_state = 3 ;
		VG_Sleep(60);
		
		BIOS_PrintString( 0, 4, "     v1.0.4" );
		BIOS_PrintString( 0, 6, " CODED BY PRAY \x03" );
		
		BIOS_PrintString( 0, 8, "\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07" );
		
		
		
		
		
	} else if( bios_state == 3 ) {
		if( GetCartridgeIndex() == 0 ) {
			BIOS_PrintString( 0, 9, " NO CARTRIDGE!!" );
			bios_state = 5;
		} else {
			// boot game!
			SetBackdrop( 0, 0, 0 );
			bios_state = 4;
		}
	} else if( bios_state == 4 ) {
		ExecuteCart();
		bios_state = 5;
	}
	
}

public BIOS_PrintString( x, y, const String:string[] ) {
	for( new i =0; string[i]; i++ ) {
		VG_BG_SetTile( x+i,y, string[i] );
	}
}
