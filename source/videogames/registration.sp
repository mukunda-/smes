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
		
//-------------------------------------------------------------------------------------------------				
InitRegistration() {
	romlist_title = CreateArray( 16 );
	romlist_entry = CreateArray();
	romlist_plugin = CreateArray();
	romlist_ids = CreateArray( 16 );
	romlist_id_trie = CreateTrie();
}
#pragma unused ResetRegistration
//-------------------------------------------------------------------------------------------------
ResetRegistration() {
	ClearArray( romlist_title );
	ClearArray( romlist_entry );
	ClearArray( romlist_plugin );
	ClearArray( romlist_ids );
	
	ClearTrie( romlist_id_trie );
}

//-------------------------------------------------------------------------------------------------
FindGame( const String:id[] ) {
	new index;
	if( GetTrieValue( romlist_id_trie, id, index ) ) { 
		return index;
	} 
	return -1;
}

//-------------------------------------------------------------------------------------------------
RegisterGame( Handle:plugin, const String:id[], const String:title[] ) {
	new index = FindGame(id);
	if( index != -1 ) {
		// update game info
		SetArrayString( romlist_title, index, title );
	//	SetArrayCell( romlist_entry, index, entry );
		SetArrayCell( romlist_plugin, index, plugin );
		
	} else { 
		PushArrayString( romlist_title, title );
	//	PushArrayCell( romlist_entry, entry );
		PushArrayCell( romlist_plugin, plugin );
		PushArrayString( romlist_ids, id );
		new newindex = GetArraySize(romlist_plugin)-1;
		SetTrieValue( romlist_id_trie, id, newindex );
		
	}
}

//-------------------------------------------------------------------------------------------------

public Handle:GetGamePlugin( const String:id[] ) {
	new index = FindGame( id );
	if( index == -1 ) return INVALID_HANDLE;
	return GetArrayCell( romlist_plugin, index );
}
