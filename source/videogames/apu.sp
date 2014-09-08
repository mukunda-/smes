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

#define APU_SOUND_LEVEL SNDLEVEL_NORMAL

//-------------------------------------------------------------------------------------------------
APU_CreateChannels() {

	apu_next_id = 0;
	
	new Float:vec[3];
	for( new i = 0; i < apu_num_channels; i++ ) {
		new ent = CreateEntityByName("env_sprite");
		
		SetVariantString( "!activator" );
		AcceptEntityInput( ent, "SetParent", tv_ent );
		
		TeleportEntity( ent, vec, NULL_VECTOR, NULL_VECTOR );
		DispatchSpawn(ent);
		apu_ents[i] = ent;
		
		apu_channel_priority[i] = 0;
		apu_channel_time[i] = 0.0;
		apu_channel_id[i] = 0;
		
	}
}
/*
//-------------------------------------------------------------------------------------------------
APU_ResetData() { 
	apu_next_id = 0;
	for( new i =0 ; i < apu_num_channels; i++ ) {
		apu_channel_priority[i] = 0;
		apu_channel_time[i] = 0.0;
		apu_channel_id[i] = 0;
	}
}*/

//-------------------------------------------------------------------------------------------------
APU_AllocChannel( priority ) {
	new Float:best_time = 0.0;
	new best_channel = 0;
	
	for( new i =0 ; i < apu_num_channels; i++ ) {
		if( apu_channel_id[i] == 0 ) return i+1; // channel is inactive

		new Float:time_played = gametime_at_frame - apu_channel_time[i];

		if( time_played > apu_channel_timeout[i] ) {
			apu_channel_priority[i] = 0;
		}
		
		if( priority >= apu_channel_priority[i] ) {
			
			if( time_played >= best_time ) {
				best_time = time_played;
				best_channel = i+1;
			}
		}
	}
	
	return best_channel;
}

//-------------------------------------------------------------------------------------------------
APU_PlaySound( const String:sample[], priority=1, pitch=SNDPITCH_NORMAL, Float:volume=SNDVOL_NORMAL, Float:timeout =1.0 ) {
	
	if( !GameActive() ) return -1;
	new chan = APU_AllocChannel( priority );
	if( chan == 0 ) return 0;
	
	EmitSoundToAll( sample, apu_ents[chan-1], _, APU_SOUND_LEVEL, _, volume, pitch );
	apu_channel_time[chan-1] = gametime_at_frame; 
	apu_channel_priority[chan-1] = priority;
	apu_channel_id[chan-1] = ++apu_next_id;
	apu_channel_timeout[chan-1] = timeout;
	strcopy( apu_channel_sample[chan-1], sizeof(apu_channel_sample[]), sample );
	
	return apu_next_id;
}

//-------------------------------------------------------------------------------------------------
APU_GetChannelFromSoundID( soundid ) {
	for( new i = 0; i < apu_num_channels; i++ ) {
		if( apu_channel_id[i] == soundid ) {
			return i+1;
		}
	}
	return 0;
}

//-------------------------------------------------------------------------------------------------
APU_GetChannelSoundID( channel ) {
	return apu_channel_id[channel-1];
}

//-------------------------------------------------------------------------------------------------
APU_StopChannel( chan ) {
	if( !game_setup ) return;
	if( apu_channel_id[chan-1] == 0 ) return;
	StopSound( apu_ents[chan-1], SNDCHAN_AUTO, apu_channel_sample[chan-1] );
	apu_channel_id[chan-1] = 0;
}

//-------------------------------------------------------------------------------------------------
Float:APU_GetTimeout( chan ) {
	new Float:time_played = gametime_at_frame - apu_channel_time[chan-1];
	return apu_channel_timeout[chan-1] - time_played;
}

//-------------------------------------------------------------------------------------------------
APU_SetChannelVolume( chan, Float:volume ) {
	if( !GameActive() ) return;
	if( apu_channel_id[chan-1] == 0 ) return;
	EmitSoundToAll( apu_channel_sample[chan-1], apu_ents[chan-1], _, APU_SOUND_LEVEL, SND_CHANGEVOL, volume );
}

//-------------------------------------------------------------------------------------------------
APU_SetChannelPitch( chan, pitch ) {
	if( !GameActive() ) return;
	if( apu_channel_id[chan-1] == 0 ) return;
	EmitSoundToAll( apu_channel_sample[chan-1], apu_ents[chan-1], _, APU_SOUND_LEVEL, SND_CHANGEPITCH, _, pitch );
}

//-------------------------------------------------------------------------------------------------
APU_Panic() {
	if( !game_setup ) return;
	for( new i = 0; i < apu_num_channels; i++ ) {
		APU_StopChannel( i+1 );
	}
}
