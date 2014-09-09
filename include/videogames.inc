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
 
// API FILE

#if defined _videogames_included
	#endinput
#endif

#define _videogames_included

// *** Crystal Clear 256x160 Pixel Display *** //
#define VG_SCREEN_WIDTH 256
#define VG_SCREEN_HEIGHT 160

// Dimensions of the visible BG tilemap
#define VG_BG_WIDTH (16+1) // +1 because the image may be smoothly scrolled.
#define VG_BG_HEIGHT 10

// The size of a pixel in world units.
#define VG_PIXEL_UNIT (3.0/16.0)

// GRAPHIC LAYERS
// LAYER0/Backdrop    Solid color layer
// LAYER1/Background  Scrolling tilemap layer
// LAYER2/Sprites     Sprites layer
// LAYER3/Clip        Clipping layer
  
///////////////////////////////////////////////////////////////////
//
// SYSTEM
//
///////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Register your game
//
// Call this when your plugin loads to link it into the system.
//
// id: id for the game, e.g. "supermareo"
// title: title of the game e.g. "Super Mareo Bruhs" 
//
// You also need to provide a cartridge model located at
// models/videogames/<id>/cartridge.mdl
//
native VG_Register( const String:id[], const String:title[] );

//-----------------------------------------------------------------------------
// Set the framerate of the system
//
// Recommended to not exceed 60.0.
//
native VG_SetFramerate( Float:framerate );

//-----------------------------------------------------------------------------
// Set the updatetime for the system
//
// The update time is a number that controls how much entity data can be
// updated per game frame. The higher it is the more instant a large graphic
// update will be.
//
// This is clamped against the system's MAX update time setting.
//
// Update time can be abused to delay graphical updates for a 
// dissolving effect.
//
native VG_SetUpdateTime( updatetime );

//-----------------------------------------------------------------------------
// Toggle screen blanking
//
// Blanking disables all graphics for initialization routines. During blanking 
// only the Backdrop is rendered.
//
// blanking: If true, blanking mode will be entered immediately.
//           If false, then blanking mode will be disabled after a few frames.
// wait: This is only used if "blanking" is false, and it controls how many 
//       frames to wait before disabling blanking mode.
// 
// e.g. You do a big graphical update or initialization, and you use 
// SetBlankingEx to only turn on the screen after you think the update 
// should be finished.
//
native VG_SetBlanking( bool:blanking );
native VG_SetBlankingEx( bool:blanking, wait );

//-----------------------------------------------------------------------------
// Set Backdrop color
//
// The backdrop is the color that appears behind the Background in 
// transparent spots.
//
// r,g,b: Color component, 0-128
//
native VG_SetBackdrop( r, g, b );
 
//-----------------------------------------------------------------------------
// Put your game to sleep for N frames (according to the game's framerate, 
// not the source engine)
//
// While asleep the system continues to process graphics and your game will 
// not receive updates.
//
// frames: Number of frames to sleep.
//
native VG_Sleep( frames );

///////////////////////////////////////////////////////////////////
//
// INPUT
//
///////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Get player client indexes
//
// player: 1 for Player1, 2 for Player2
// returns: Client index or 0 if no player is holding the controller.
//
native VG_GetGameClient( player );

//-----------------------------------------------------------------------------
// Read player input.
//
// Safe to call when a player is not holding the controller.
//
// player: 1 for Player1, 2 for Player2
// returns: bitfield containing which buttons are currently pressed.
//          see VG_INPUT_* enum.
//
native VG_Joypad_Read( player );

//-----------------------------------------------------------------------------
// Check if player has clicked a button.
//
// A "click" is every time a button switches from unpressed to pressed.
//
// player: 1 for Player1, 2 for Player2
// button_index: VG_INPUT_***_INDEX
// reset: if false, does not reset the click counter
// returns: How many times the player has clicked a button since the last
//          call to this function.
//
native VG_Joypad_Clicks( player, button_index, bool:reset=true );

//-----------------------------------------------------------------------------
// Reset joypad click counters
//
// Reset the click counter for both joypads to 0, so VG_Joypad_Clicks will
// return 0 until the button is pressed again.
//
native VG_Joypad_Flush();

//-----------------------------------------------------------------------------
// Check if a button is currently pressed
//
// Equivalent to VG_Joypad_Read( player ) & <button_bitmask>
native bool:VG_Joypad_Held( player, button );

//-----------------------------------------------------------------------------
// Input bitmask/buttons for VG_Joypad_Read
//
enum {
	VG_INPUT_LEFT		=1,
	VG_INPUT_RIGHT		=2,
	VG_INPUT_UP			=4,
	VG_INPUT_DOWN		=8,
	VG_INPUT_JUMP		=16,
	VG_INPUT_SHIFT		=32,
	VG_INPUT_CTRL		=64,
	VG_INPUT_E			=128,
	VG_INPUT_F			=256,			// click only
	VG_INPUT_R			=512
};

//-----------------------------------------------------------------------------
// Input button indexes for indexed input functions.
//
enum {	
	VG_INPUT_LEFT_INDEX,
	VG_INPUT_RIGHT_INDEX,
	VG_INPUT_UP_INDEX,
	VG_INPUT_DOWN_INDEX,
	VG_INPUT_JUMP_INDEX,
	VG_INPUT_SHIFT_INDEX,
	VG_INPUT_CTRL_INDEX,
	VG_INPUT_E_INDEX,
	VG_INPUT_F_INDEX,
	VG_INPUT_R_INDEX
};


///////////////////////////////////////////////////////////////////
//
// BACKGROUND
//
///////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// The Background is a tile map that can be efficiently scrolled horizontally.
// The Background is locked to LAYER1
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Set tilemap model file (.mdl)
//
// Tilemap models are a flat 16x16 (world units) square that is textured with
// the desired tileset.
//
// Models should be located in models/videogames/<yourgame>/
// Model texture should be located in materials/videogames/<yourgame>/
//
// The model must be precached already
//
// model: e.g. "models/videogames/<yourgame>/model.mdl"
//
native VG_BG_SetModel( const String:model[] );

//-----------------------------------------------------------------------------
// Set the BG scroll position
//
// scroll: Sets the position of the BG that touches the left edge of the
// screen. e.g. 8 will set the viewport to past one half of the first tile.
// 
native VG_BG_SetScroll( scroll );

//-----------------------------------------------------------------------------
// Get the BG scroll position
//
// returns: Where the BG is scrolled, in pixels.
//
native VG_BG_GetScroll();

//-----------------------------------------------------------------------------
// Set a tile in the tilemap.
//
// x,y: coordinates
// tile: index of tile
// refresh: if true, the tile entity will be updated
//   set this to false if you plan on updating the entire screen with 
//   VG_BG_SetScreenRefresh
//
native VG_BG_SetTile( x, y, tile, bool:refresh=true );

//-----------------------------------------------------------------------------
// Read a tilemap entry
//
// x,y: Coordinate of tile
// returns: tile index, or -1 if the coordinate is out of bounds
//
native VG_BG_GetTile( x, y );

//-----------------------------------------------------------------------------
// Set a flag that refreshes the entire background layer
//
// This is used if you change a lot of background data and the normal 
// refreshing routine would be inefficient.
//
native VG_BG_SetScreenRefresh();

//-----------------------------------------------------------------------------
// Load a tilemap file
//
// filename: Path to file, relative to sourcemod/data/videogames/<yourgame>/
// destx,y: Where to load the file in the tilemap
// offset: amount to add to each tile, mainly to compensate for an off-by-one issue in tile storage
//
// returns: width of tilemap file
//
// TODO: describe tilemap format, I'm pretty sure its just a raw array
// of tiles though.
//
native VG_BG_LoadFile( const String:filename[], offset=0,destx=0, desty=0 );

//-----------------------------------------------------------------------------
// Process a tilemap.
//
// Fires callback for every tile in the tilemap to modify the data. This is meant
// for tilemap initialization, such as converting goomba tiles into dormant entities.
//
// start,end: Which range of slices (map columns) (inclusive) should be processed.
// callback: Function to call for each tile.
//
native VG_BG_ProcessTilemap( start, end, VGEventProcessTilemap:callback );

//-----------------------------------------------------------------------------
// Tilemap process callback
//
// x,y: Coordinates of tile
// tile: Index of tile
// return: The new tile for the index
//
functag VGEventProcessTilemap public( x, y, tile );


///////////////////////////////////////////////////////////////////
//
// TEXT
//
///////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------
// "Text" controls staticly placed objects on the screen
//
// It can be used to overlay TEXT on graphics, or create
// various elements to compose your scene.
//
// Text can be placed on any layer of the screen, so it can appear 
// behind or in front of sprites
//
// The Batch suffix functions are operations that modifies a set of 
// text entities rather than just a single entity.
//
// Batch operations can shit all over your graphics if you use too
// much of them.
//-----------------------------------------------------------------------------

// number of text indexes you can use (0-149)
#define VG_TEXT_COUNT 150

//-----------------------------------------------------------------------------
// Set text model
//
// The model is a simple model that is a square that is textured with the 
// desired material.
//
// The model dimensions must match the pixel dimensions of the texture.
//
// index,count: Text entities to modify
// model: Model to set, e.g. "models/videogames/<yourgame>/model.mdl"
//
native VG_Text_SetModel( index, const String:model[] );
native VG_Text_SetModelBatch( index, count, const String:model[] );

//-----------------------------------------------------------------------------
// Set text position
//
// Do not set it outside of the screen OR IT WILL SHOW UP OUTSIDE OF THE TV...
//
// index: Text entity to move
// x,y:   Pixel coordinates to move to
//
// The batch version of this function is VG_Text_SetPositionGrid.
//
native VG_Text_SetPosition( index, x, y );

//-----------------------------------------------------------------------------
// Setup a tile grid
//
// index: starting text index
// count: number of text indexes used for the grid
// x,y: starting coordinates (pixels)
// columns: number of horizontal cells
// spacing_h: spacing between horizontal cells (pixels)
// spacing_v: spacing between vertical cells (pixels)
//
// This function iterates 'count' times and moves text entities to match a
// grid pattern.
// 
// For example, for these parameters: 
//   index = 5
//   count = 10
//   x,y = 5,5
//   columns = 4
//   spacing_h,v = 16 16
// and with 16x16 pixel text entities, will arrange text indexes 5-14
// like this:
//   (top left corner located at [5, 5])
//
//   ┌──┬──┬──┬──┐
//   │ 5│ 6│ 7│ 8│ (each entity spaced 16 pixels part.)
//   ├──┼──┼──┼──┤
//   │ 9│10│11│12│
//   ├──┼──┼──┴──┘
//   │13│14│
//   └──┴──┘
//
native VG_Text_SetPositionGrid( index, count, x, y, 
                                columns, spacing_h, spacing_v );

//-----------------------------------------------------------------------------
// Set the offset to use for this text
//
// Offsets are used to move/scroll a bunch of text entities at the same time
//
// Change the offset positioning with SetOffsetParam
//
// offset: 0-3
//
native VG_Text_SetOffset( index, offset );
native VG_Text_SetOffsetBatch( index, count, offset );

//-----------------------------------------------------------------------------
// Turn a tile ON or OFF.
//
// OFF tiles should now always be invisible...but not guaranteed? (???)
//
// index,count: Text entities to modify
// on: Should text entity be visible?
//
native VG_Text_SetOn( index, bool:on );
native VG_Text_SetOnBatch( index, count, bool:on );

//-----------------------------------------------------------------------------
// Set model scale.
//
// index,count: Text entities to modify
// size: New scale to use, 1 = normal size, 2 = double size
//
native VG_Text_SetSize( index, size );
native VG_Text_SetSizeBatch( index, count, size );

//-----------------------------------------------------------------------------
// Set the color multiplier.
//
// index,count: Text entity to modify
// color: 0xAABBGGRR (hex)
// RR,GG,BB,AA = 0-128
//
native VG_Text_SetColor( index, color );
native VG_Text_SetColorBatch( index, count, color );

//-----------------------------------------------------------------------------
// Set the text frame index.
//
// This changes which texture frame is used for texturing the text entity.
// 
// index,count: Text entities to modify
// frame: Texture frame to use.
//
native VG_Text_SetFrame( index, frame );
native VG_Text_SetFrameBatch( index, count, frame );

//-----------------------------------------------------------------------------
// Move a text offset.
//
// All text entities are linked to a single "offset". By changing the offset
// all text entities linked to the offset are moved with it.
// 
// set: 0-3 (there are 4 text offsets that can be used.)
// x,y: Where to move the offset, text entities will move to [x,y] PLUS their
//      own position.
// layer: 0 = Invisible/Disabled; all text entities linked to a disabled
//            offset will not be rendered.
//        1 = Background layer; care must be taken to not collide with a
//            background tile, otherwise "z-fighting" may occur.
//        2 = Sprite layer; same level as sprite objects. May or may not
//            z-fight with sprites depending on the sprite's and the text
//            entities material settings.
//        3 = Clipping layer. This is the topmost layer. Text entities in this
//            layer must not be positioned outside of the active screen
//            boundaries, because they will z-fight with the screen clipping
//            model.
//
native VG_Text_SetOffsetParam( set, x, y, layer );

//-----------------------------------------------------------------------------
// Set an array of text entities to show a text string.
//
// index:       First text index.
// count:       Max number of indexes to use.
// text:        ASCII text to display.
// frameoffset: Number to add to each character to map it to the material 
//              frames.
// pad:         If true, and the text length is less than "count", any unused
//              text indexes will have their frame set to "padframe".
// padframe:    Frame for unused text indexes, this is not affected 
//              by "frameoffset".
//
native VG_Text_DrawString( index, count, const String:text[], frameoffset=0, bool:pad=true, padframe=0 );


///////////////////////////////////////////////////////////////////
//
// SPRITES
//
///////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Sprites are elements that are scrolled with the background
//
// Sprites are locked to LAYER2
//
// If a sprite uses a "translucent" material, then it will not z-fight with
// other sprites. The order of rendering sprites is undefined.
//
// Sprites are quite limited, (16 I think?)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Remove all sprites from the game.
//
native VG_Sprites_Reset();

//-----------------------------------------------------------------------------
// Add a sprite to the game
//
// model: path to material for sprite
// 
// The model must be Precached.
// Don't forget to add it to the downloads table as well!
// 
// returns: ID of new sprite.
//
native VG_Sprites_Create( const String:model[] );

//-----------------------------------------------------------------------------
// Delete a sprite.
// 
// id: Sprite ID to delete. (returned by Sprite_Create)
//
native VG_Sprites_Delete(id);
native VG_Sprites_DeleteAll();

//-----------------------------------------------------------------------------
// Get the position of a sprite
//
// id: Sprite ID
// x: (returned) X coordinate
// y: (returned) Y coordinate
//
native VG_Sprites_GetPosition( id, &x, &y );

//-----------------------------------------------------------------------------
// Set the position of a sprite
//
// id: Sprite ID
// x,y: Sprite coordinates
// 
// the x coordinate is an absolute map coodinate, and it is translated by
// wherever the Background is scrolled.
//
native VG_Sprites_SetPosition( id, x, y );

//-----------------------------------------------------------------------------
// Set the frame for a sprite.
// 
// id: Sprite ID.
// frame: Frame in the texture to use.
// 
native VG_Sprites_SetTexture( id, frame );

//-----------------------------------------------------------------------------
// Set the color for a sprite
//
// r: 0-128
// g: 0-128
// b: 0-128
// a: 0...255 (?)
//
native VG_Sprites_SetColor( id, r, g, b, a );


///////////////////////////////////////////////////////////////////
//
// AUDIO
//
///////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Play a game sound.
//
// sample: Path to sound, relative to /sound/. Custom video game
//         sounds should reside in /sound/videogames/<yourgame>/
// priority: Priority of sound, it may be overwritten or blocked 
//           by other sounds with higher priority
// pitch: Sound pitch, 100 = normal, 200 = +1 octave, 50 = -1 octave
// volume: Sound volume scaler: range=[0.0,1.0]
// Timeout: The time until lower priority sounds can take over, ideally this is 
//          the length of the sound but it doesn't have to be.
//
// returns: new Sound ID
//
native VGSoundID:VG_Audio_Play( const String:sample[], priority=1, pitch=SNDPITCH_NORMAL, Float:volume=SNDVOL_NORMAL, Float:timeout =1.0);

//-----------------------------------------------------------------------------
// Stop all sounds and invalidate all IDs.
//
native VG_Audio_Panic();

//-----------------------------------------------------------------------------
// Get the Sound Channel from a Sound ID
//
// id: Sound ID, created from VG_Audio_Play
// returns: Sound channel index, or 0 if the sound ID has been invalidated.
//                                   (if the sound expires or is cancelled.)
//
native VG_Audio_GetChannelFromSoundID( VGSoundID:id );

//-----------------------------------------------------------------------------
// Get the Sound ID from a Sound Channel index.
//
// channel: Index of channel to get ID from.
// returns: Current Sound ID that the channel contains.
//
native VGSoundID:VG_Audio_GetChannelSoundID( channel );

//-----------------------------------------------------------
// Channel manipulation commands
// Get a channel index from VG_Audio_GetChannelFromSoundID
//
//-----------------------------------------------------------------------------
// Stop a channel
//
// channel: Channel index
//
native VG_Audio_StopChannel( channel );

//-----------------------------------------------------------------------------
// Set channel volume
//
// channel: Channel index
// volume: 0.0 (silent) to 1.0
//
//  setting 0.0 might stop the sound from being able to be turned back on.
//
native VG_Audio_SetChannelVolume( channel, Float:volume );

//-----------------------------------------------------------------------------
// Set channel pitch (frequency) multiplier
//
// channel: Channel index
// pitch: -25 to 200, 100 = normal pitch
//
// The lower bound of pitch may also be only 50...
//
native VG_Audio_SetChannelPitch( channel, pitch );

//-----------------------------------------------------------------------------
// Get the remaining timeout time for a channel 
//
// (timeout - (GameTime - time of playback start))
//
// channel: Channel index.
// returns: Remaining timeout.
native Float:VG_Audio_GetTimeout( channel );
