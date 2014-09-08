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

//============================================================================================================
// natives	


public APLRes:AskPluginLoad2( Handle:myself, bool:late, String:error[], err_max ) {
	CreateNative( "VG_Register", Native_Register );
	CreateNative( "VG_SetFramerate", Native_SetFramerate );
	CreateNative( "VG_SetUpdateTime", Native_SetUpdateTime );
	CreateNative( "VG_CreateTimer", Native_CreateTimer );
	CreateNative( "VG_Sleep", Native_Sleep );
	CreateNative( "VG_SetBlanking", Native_SetBlanking );
	CreateNative( "VG_SetBlankingEx", Native_SetBlankingEx );
	CreateNative( "VG_SetBackdrop", Native_SetBackdrop );
	
	CreateNative( "VG_GetGameClient", Native_GetGameClient );
	CreateNative( "VG_Joypad_Read", Native_JoypadRead );
	CreateNative( "VG_Joypad_Held", Native_JoypadHeld );
	CreateNative( "VG_Joypad_Clicks", Native_JoypadClicks );
	CreateNative( "VG_Joypad_Flush", Native_JoypadFlush );
	
	CreateNative( "VG_BG_ProcessTilemap", Native_BG_ProcessTilemap );
	CreateNative( "VG_BG_LoadFile", Native_BG_LoadFile );
	CreateNative( "VG_BG_SetModel", Native_SetBGModel );
	CreateNative( "VG_BG_SetScroll", Native_SetScroll );
	CreateNative( "VG_BG_GetScroll", Native_GetScroll );
	CreateNative( "VG_BG_GetTile", Native_GetTile );
	CreateNative( "VG_BG_SetTile", Native_SetTile );
	CreateNative( "VG_BG_SetScreenRefresh", Native_SetScreenRefresh );
	
	CreateNative( "VG_Sprites_Reset", Native_ResetSprites );
	CreateNative( "VG_Sprites_Create", Native_CreateSprite );
	CreateNative( "VG_Sprites_Delete", Native_DeleteSprite );
	CreateNative( "VG_Sprites_DeleteAll", Native_DeleteAllSprites );
	CreateNative( "VG_Sprites_GetPosition", Native_GetSpritePosition );
	CreateNative( "VG_Sprites_SetPosition", Native_SetSpritePosition );
	CreateNative( "VG_Sprites_SetTexture", Native_SetSpriteTexture );
	CreateNative( "VG_Sprites_SetColor", Native_SetSpriteColor );
	
	CreateNative( "VG_Audio_Play", Native_Audio_Play );
	CreateNative( "VG_Audio_Panic", Native_Audio_Panic );
	CreateNative( "VG_Audio_StopChannel", Native_Audio_StopChannel );
	CreateNative( "VG_Audio_GetChannelFromSoundID", Native_Audio_GetChannelFromSoundID );
	CreateNative( "VG_Audio_GetChannelSoundID", Native_Audio_GetChannelSoundID );
	CreateNative( "VG_Audio_SetChannelVolume", Native_Audio_SetChannelVolume );
	CreateNative( "VG_Audio_SetChannelPitch", Native_Audio_SetChannelPitch );
	CreateNative( "VG_Audio_GetTimeout", Native_Audio_GetTimeout );
	
	CreateNative( "VG_Text_SetModel", Native_Text_SetModel );
	CreateNative( "VG_Text_SetModelBatch", Native_Text_SetModelBatch );
	CreateNative( "VG_Text_SetPosition", Native_Text_SetPosition );
	CreateNative( "VG_Text_SetPositionGrid", Native_Text_SetPositionGrid );
	//CreateNative( "VG_Text_SetLayer", Native_Text_SetLayer );
	//CreateNative( "VG_Text_SetLayerBatch", Native_Text_SetLayerBatch );
	CreateNative( "VG_Text_SetOffset", Native_Text_SetOffset );
	CreateNative( "VG_Text_SetOffsetBatch", Native_Text_SetOffsetBatch );
	CreateNative( "VG_Text_SetOn", Native_Text_SetOn );
	CreateNative( "VG_Text_SetOnBatch", Native_Text_SetOnBatch );
	CreateNative( "VG_Text_SetSize", Native_Text_SetSize );
	CreateNative( "VG_Text_SetSizeBatch", Native_Text_SetSizeBatch );
	CreateNative( "VG_Text_SetColor", Native_Text_SetColor );
	CreateNative( "VG_Text_SetColorBatch", Native_Text_SetColorBatch );
	CreateNative( "VG_Text_SetFrame", Native_Text_SetFrame );
	CreateNative( "VG_Text_SetFrameBatch", Native_Text_SetFrameBatch );
	CreateNative( "VG_Text_SetOffsetParam", Native_Text_SetOffsetParam );
	CreateNative( "VG_Text_DrawString", Native_Text_DrawString );
	
	
	return APLRes_Success;
}

//-------------------------------------------------------------------------------------------------
public Native_Register( Handle:plugin, numParams ) {
	decl String:title[128];
	decl String:id[32];
	
	GetNativeString( 1, id, sizeof(id) );
	GetNativeString( 2, title, sizeof(title) );
	
	RegisterGame( plugin, id, title );
}

//-------------------------------------------------------------------------------------------------
public Native_SetFramerate( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	SetFramerate( Float:GetNativeCell(1) );
}

public Native_SetUpdateTime( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;

	SetUpdateTime( GetNativeCell(1) );
}

//-------------------------------------------------------------------------------------------------
public Native_CreateTimer( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	///new Float:time = Float:GetNativeCell(1);
	//new VGEventTimer:callback = VGEventTimer:GetNativeCell(2);
	//new data = GetNativeCell(3);
	
	//CreateGameTimer( time, callback, data );

	PrintToServer("vgnotice: game timers are not yet implemented" );
}

//-------------------------------------------------------------------------------------------------
public Native_Sleep( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	SetSleep( GetNativeCell(1) );
}

//-------------------------------------------------------------------------------------------------
public Native_GetGameClient( Handle:plugin, numParams ) {
	new player = GetNativeCell(1)-1;
	if( player < 0 || player > 1 ) return 0;
	return game_clients[player];
}

//-------------------------------------------------------------------------------------------------
public Native_JoypadRead( Handle:plugin, numParams ) {
	
	new player = GetNativeCell(1)-1;
	if( player < 0 || player > 1 ) return 0;
	return KeyState( player );

}

//-------------------------------------------------------------------------------------------------
public Native_JoypadHeld( Handle:plugin, numParams ) {
	new player = GetNativeCell(1)-1;
	if( player < 0 || player > 1 ) return 0;
	return KeyHeld( player, GetNativeCell(2) );
}

public Native_JoypadFlush( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	FlushKeyClicks();
}

public Native_JoypadClicks( Handle:plugin, numParams ) {
	
	if( plugin != controlling_plugin ) return 0;
	new player = GetNativeCell(1)-1;
	if( player < 0 || player > 1 ) return 0;
	return KeyClicks( player, GetNativeCell(2), GetNativeCell(3) );
}

//-------------------------------------------------------------------------------------------------
SetBlankingEx( bool:param, wait ) {
	if( !param ) {
		if( screen_state == SCREENSTATE_BLANK ) {
			g_disable_blanking = wait;
		}
	} else {
		SetScreenState( SCREENSTATE_BLANK );
		g_disable_blanking = 0;
	}
}

//-------------------------------------------------------------------------------------------------
public Native_SetBlanking( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	SetBlankingEx( GetNativeCell(1), 4 ); 
}

//-------------------------------------------------------------------------------------------------
public Native_SetBlankingEx( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	SetBlankingEx( GetNativeCell(1), GetNativeCell(2) ); 
}

//-------------------------------------------------------------------------------------------------
public Native_SetBackdrop( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	SetBackdrop( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}

//-------------------------------------------------------------------------------------------------
public Native_BG_LoadFile( Handle:plugin, numParams ) { 
	if( plugin != controlling_plugin ) return 0;
	// file,x,y
	decl String:model[256];
	GetNativeString( 1, model, sizeof(model) );
	
	return LoadTilemap( model, GetNativeCell(2), GetNativeCell(3), GetNativeCell(4) );
}

//-------------------------------------------------------------------------------------------------
public Native_SetBGModel( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	
	decl String:model[256];
	
	GetNativeString( 1, model, sizeof(model) );
	
	SetBGModel( model );
}

//-------------------------------------------------------------------------------------------------
public Native_BG_ProcessTilemap( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	// start,end,func
	ProcessTilemap( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}

//-------------------------------------------------------------------------------------------------
public Native_SetScroll( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	SetScroll( GetNativeCell(1) );
}

//-------------------------------------------------------------------------------------------------
public Native_GetScroll( Handle:plugin, numParams ) {
	return GetScroll();
}

//-------------------------------------------------------------------------------------------------
public Native_GetTile( Handle:plugin, numParams ) {
	return GetTile( GetNativeCell(1), GetNativeCell(2) );
}

//-------------------------------------------------------------------------------------------------
public Native_SetTile( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	SetTile( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}

//-------------------------------------------------------------------------------------------------
public Native_SetScreenRefresh( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	SetScreenRefresh();
}

//-------------------------------------------------------------------------------------------------
public Native_ResetSprites( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	ResetSprites();
}

//-------------------------------------------------------------------------------------------------
public Native_CreateSprite( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return -1;
	
	decl String:model[128];
	GetNativeString( 1, model, sizeof(model) );
	return CreateSprite( model );
}

//-------------------------------------------------------------------------------------------------
public Native_DeleteSprite( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	DeleteSprite( GetNativeCell(1) );
}

public Native_DeleteAllSprites( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;

	Sprites_DeleteAll();
}

//-------------------------------------------------------------------------------------------------
public Native_GetSpritePosition( Handle:plugin, numParams ) {
	
	new x, y;
	GetSpritePosition( GetNativeCell(1), x, y );
	
	SetNativeCellRef( 2, x );
	SetNativeCellRef( 3, y );
}

//-------------------------------------------------------------------------------------------------
public Native_SetSpritePosition( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	SetSpritePosition( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}

//-------------------------------------------------------------------------------------------------
public Native_SetSpriteTexture( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	SetSpriteTexture( GetNativeCell(1), GetNativeCell(2) );
}

//-------------------------------------------------------------------------------------------------
public Native_SetSpriteColor( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	SetSpriteColor( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5) );
}

//-------------------------------------------------------------------------------------------------
public Native_Audio_Play( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return 0;
	
	decl String:sample[256];
	GetNativeString( 1, sample, sizeof(sample) );
	
	return APU_PlaySound( sample, GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5) );
}

//-------------------------------------------------------------------------------------------------
public Native_Audio_Panic( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;

	APU_Panic();
}

//-------------------------------------------------------------------------------------------------
public Native_Audio_GetChannelFromSoundID( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return 0;
	return APU_GetChannelFromSoundID(GetNativeCell(1));
}

//-------------------------------------------------------------------------------------------------
public Native_Audio_GetChannelSoundID( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return 0;
	return APU_GetChannelSoundID( GetNativeCell(1) );
}

//-------------------------------------------------------------------------------------------------
public Native_Audio_StopChannel( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	APU_StopChannel( GetNativeCell(1) );
}

//-------------------------------------------------------------------------------------------------
public Native_Audio_SetChannelVolume( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	APU_SetChannelVolume( GetNativeCell(1), GetNativeCell(2) );
}

//-------------------------------------------------------------------------------------------------
public Native_Audio_SetChannelPitch( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	APU_SetChannelPitch( GetNativeCell(1), GetNativeCell(2) );
}

public Native_Audio_GetTimeout( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return _:0.0;
	return _:APU_GetTimeout( GetNativeCell(1) );
}

//-------------------------------------------------------------------------------------------------
public Native_Text_SetModel( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	decl String:model[256];
	GetNativeString( 2, model, sizeof(model) );
	
	Text_SetModel( GetNativeCell(1), model );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetModelBatch( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	decl String:model[256];
	GetNativeString( 3, model, sizeof(model) );
	Text_SetModelBatch( GetNativeCell(1), GetNativeCell(2), model );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetPosition( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index, x, y
	Text_SetPosition( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetPositionGrid( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	//index, count, x, y, columns, spacing_h, spacing_v
	Text_SetPositionGrid( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5), GetNativeCell(6), GetNativeCell(7) );
}
//-------------------------------------------------------------------------------------------------
/*
public Native_Text_SetLayer( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,layer
	Text_SetLayer( GetNativeCell(1), GetNativeCell(2) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetLayerBatch( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,count,layer
	Text_SetLayerBatch( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}*/
//-------------------------------------------------------------------------------------------------
public Native_Text_SetOffset( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,offset
	Text_SetOffset( GetNativeCell(1), GetNativeCell(2) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetOffsetBatch( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,count,offset
	Text_SetOffsetBatch( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetOn( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,on
	Text_SetOn( GetNativeCell(1), GetNativeCell(2) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetOnBatch( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,count,on
	Text_SetOnBatch( GetNativeCell(1),GetNativeCell(2), GetNativeCell(3) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetSize( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,size(float)
	Text_SetSize( GetNativeCell(1), GetNativeCell(2) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetSizeBatch( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	// index,count,size
	Text_SetSizeBatch( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetColor( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,color
	Text_SetColor( GetNativeCell(1), GetNativeCell(2) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetColorBatch( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index,count,color
	Text_SetColorBatch( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetFrame( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// index, frame
	Text_SetFrame( GetNativeCell(1), GetNativeCell(2) );
	
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetFrameBatch( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	Text_SetFrameBatch( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_SetOffsetParam( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	// set,x,y,layer
	Text_SetOffsetParam( GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4) );
}
//-------------------------------------------------------------------------------------------------
public Native_Text_DrawString( Handle:plugin, numParams ) {
	if( plugin != controlling_plugin ) return;
	
	decl String:model[256];
	GetNativeString( 3, model, sizeof(model) );
	
	Text_DrawString( GetNativeCell(1), GetNativeCell(2), model, GetNativeCell(4), GetNativeCell(5), GetNativeCell(6) );
}
