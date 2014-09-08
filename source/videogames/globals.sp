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

#define LAYER1_Z 0.0
#define LAYER2_Z 0.05 // DEBUG
#define LAYER3_Z 0.10
#define LAYER4_Z 0.15

new testing;
 
//new g_decal;

new plugin_enabled = false;

#define MAP_WIDTH   1000
#define MAP_HEIGHT  10

// default 12x8 (192x128)
//#define SCREEN_WIDTH	192
//#define SCREEN_HEIGHT	128
//#define PIXEL_UNIT 4.0/16.0
//#define BG_WIDTH (12+1) // +1 offscreen slice for scrolling image
//#define BG_HEIGHT 8

#define SCREEN_WIDTH	256
#define SCREEN_HEIGHT	160
#define PIXEL_UNIT 3.0/16.0
#define BG_WIDTH (16+1) // +1 offscreen slice for scrolling image
#define BG_HEIGHT 10
//#define SCREEN_WIDTH	256
//#define SCREEN_HEIGHT	172
//#define PIXEL_UNIT 3.0/16.0
//#define BG_WIDTH (16+1) // +1 offscreen slice for scrolling image
//#define BG_HEIGHT 12

enum {
	SCREENSTATE_OFF,
	SCREENSTATE_BLANK,
	SCREENSTATE_ON
};

new const Float:screen_origin[3] = { 6.0, -27.9, 35.2 };
new Float:screen_origin_adjusted[3] = { 6.0, -24.0, 33.9 }; // +3.9, -0.3

// the positions the players teleport to when they are playing
// [0] = player1 pos
// [1] = player1 ang
// [2] = player2 pos
// [3] = player2 ang
new Float:player_vectors[4][3];

// the number of operations allowed to edit 
// this is reset per frame and is decreased when network related
// actions are applied to entities
new update_time;

enum {
	UPDATE_TIME_TEXTUREFRAME =1,
	UPDATE_TIME_TELEPORT	=2,
	UPDATE_TIME_MODEL		=6,
	UPDATE_TIME_COLOR		=2,
	UPDATE_TIME_REPARENT	=3,
	UPDATE_TIME_CRSPRITE	=4,
};

//-------------------------------------------------------------------------------------------------
new system_running;
new system_cartridge_inserted;
new Float:framerate;
new g_updatetime;
new String:active_game_id[64];
new active_game_index;
new g_disable_blanking;


new screen_state;
//new tv_is_on;


//-------------------------------------------------------------------------------------------------
#define ENTITY_FIELDS 8
#define MAXENTS 64

/// game entity array
// each field contains "ENTITY_FIELDS" cells
//  field0 = type
//  other fields = user defined
// 
//new Handle:entities = INVALID_HANDLE;

//new entity_data[MAXENTS][ENTITY_FIELDS];

clampcolor( a ) {
	if( a > 255 ) a = 255;
	return a;
	
}

//-------------------------------------------------------------------------------------------------

new Handle:sm_vg_hp;			// tv health
//new Handle:sm_vg_rom; 			// game to boot
//new Handle:sm_vg_roundreset;	// round end/start handling
new Handle:sm_vg_updatetime;	// see update_time variable
new Handle:sm_vg_fastbios;		// skip bios scene
new Handle:sm_vg_enabled;		// is plugin enabled
new Handle:sm_vg_hdr;			// hdr mode (divide colors)

new c_vg_updatetime;			// cached updatetime
new bool:c_vg_enabled;			// cached enabled
new bool:c_vg_hdr;				// not actually a convar now
//new String:c_vg_rom[64];		// cached rom id

//-------------------------------------------------------------------------------------------------
// game status
new bool:game_setup;
new bool:game_broken;


//-------------------------------------------------------------------------------------------------
// gameframe divisor
//new frame_divisor = 4;
//new frame_counter = 0;

//-------------------------------------------------------------------------------------------------

#define MODEL_TVCOVER "models/videogames/tvbg2.mdl"
#define MODEL_DEFONT "models/videogames/bios/font.mdl" 
#define MODEL_SMES "models/videogames/smes_console.mdl"
#define MODEL_SMES_PLUG "models/videogames/smes_plug.mdl"
#define MODEL_SMES_CONTROLLER "models/videogames/smes_controller.mdl"
#define MODEL_SMES_CONTROLLER_BUTTONS "models/videogames/smes_controller_buttons.mdl"
#define MODEL_SMES_CONTROLLER_BUTTONS2 "models/videogames/smes_controller_buttons2.mdl"
#define MODEL_SMES_CONTROLLER_PAD "models/videogames/smes_controller_pad.mdl" 
#define MODEL_TILEMESH "models/videogames/tilemesh.mdl"

#define MATERIAL_GLOW "materials/sprites/glow.vmt"

new const String:downloads_list[][] = {
	//materials
	"materials/videogames/smes_console.vmt",
	"materials/videogames/smes_console.vtf",
	"materials/videogames/smes_controller.vmt",
	"materials/videogames/smes_controller.vtf",
	"materials/videogames/smes_logo.vmt",
	"materials/videogames/smes_logo.vtf",
	"materials/videogames/smes_port.vmt",
	"materials/videogames/smes_port.vtf",
	"materials/videogames/solid.vmt",
	"materials/videogames/solid.vtf",
	"materials/videogames/bios/font.vmt",
	"materials/videogames/bios/font.vtf",

	//models
	"models/videogames/bios/font.dx90.vtx",
	"models/videogames/bios/font.mdl",
	"models/videogames/bios/font.vvd",
	"models/videogames/smes_console.dx90.vtx",
	"models/videogames/smes_console.mdl",
	"models/videogames/smes_console.vvd",
	"models/videogames/smes_console.phy",
	"models/videogames/smes_controller.dx90.vtx",
	"models/videogames/smes_controller.mdl",
	"models/videogames/smes_controller.vvd",
	"models/videogames/smes_controller.phy",
	"models/videogames/smes_controller_buttons.dx90.vtx",
	"models/videogames/smes_controller_buttons.mdl",
	"models/videogames/smes_controller_buttons.vvd",
	"models/videogames/smes_controller_buttons2.dx90.vtx",
	"models/videogames/smes_controller_buttons2.mdl",
	"models/videogames/smes_controller_buttons2.vvd",
	"models/videogames/smes_controller_pad.dx90.vtx",
	"models/videogames/smes_controller_pad.mdl",
	"models/videogames/smes_controller_pad.vvd",
	"models/videogames/smes_logo.dx90.vtx",
	"models/videogames/smes_logo.mdl",
	"models/videogames/smes_logo.vvd",
	"models/videogames/smes_plug.dx90.vtx",
	"models/videogames/smes_plug.mdl",
	"models/videogames/smes_plug.vvd",
	"models/videogames/smes_plug.phy",
	"models/videogames/tilemesh.dx90.vtx",
	"models/videogames/tilemesh.mdl",
	"models/videogames/tilemesh.vvd",
	"models/videogames/tvbg2.dx90.vtx",
	"models/videogames/tvbg2.mdl",
	"models/videogames/tvbg2.vvd",

	//sounds
	"sound/videogames/eject.mp3",
	"sound/videogames/off.mp3",	
	"sound/videogames/on.mp3"		
};

// NEED DEFAULT 16X16 MODEL FOR POST SETUP
new const String:materials_list[][] = {
//	MODEL_16X16,
//	MATERIAL_16X32,
//	MATERIAL_TVCOVER,
	MATERIAL_GLOW,
	
	MODEL_TVCOVER,
	MODEL_DEFONT,
	
	MODEL_SMES,
	MODEL_SMES_PLUG,
	MODEL_SMES_CONTROLLER,
	MODEL_SMES_CONTROLLER_BUTTONS,
	MODEL_SMES_CONTROLLER_BUTTONS2,
	MODEL_SMES_CONTROLLER_PAD,
	 
	MODEL_TILEMESH
	
};

//-------------------------------------------------------------------------------------------------

//new game_input[2];
//new game_input_last[2];

new game_clients[2];
//new game_client_count;
new Float:client_hook_time[2];

enum {
	INPUT_LEFT		=1,
	INPUT_RIGHT		=2,
	INPUT_UP		=4,
	INPUT_DOWN		=8,
	INPUT_JUMP		=16, // SPACE
	INPUT_SHIFT		=32, // SHIFT
	INPUT_CTRL		=64,
	INPUT_E			=128,  // E
	INPUT_F			=256,			// click only
	INPUT_R			=512
};

enum {
	INPUT_LEFT_INDEX	,
	INPUT_RIGHT_INDEX	,
	INPUT_UP_INDEX		,
	INPUT_DOWN_INDEX	,
	INPUT_JUMP_INDEX	,
	INPUT_SHIFT_INDEX	,
	INPUT_CTRL_INDEX	,
	INPUT_E_INDEX		,
	INPUT_F_INDEX		,
	INPUT_R_INDEX		,
	INPUT_NUM_BUTTONS
};

#define HIDEHUD_CROSSHAIR (1<<8)

//-------------------------------------------------------------------------------------------------
new bool:tv_create;
new Float:tv_creation_point[3];
new Float:tv_creation_angles[3]; 

new tv_ent;
new tv_cord_end_ent;
#define TV_MODEL "models/props/cs_office/TV_plasma.mdl"

new ent_console;
new ent_console_light;
new ent_controller[2];
new ent_controller_buttons[2];
new ent_controller_buttons2[2];
new ent_controller_dpad[2];
new ent_cartridge[64];
new ent_cartridge_count;
new bool:controller_being_used[2];
new bool:controller_plugged_in[2];

new ent_plug[2];
new ent_plug_cord1[2];
new ent_plug_cord2[2];

new Float:console_creation_point[3];
new Float:console_creation_angles[3];
new Float:controller_creation_point[2][3];
new Float:controller_creation_angles[2][3];

#define MAX_CARTRIDGES 64
new Float:cartridge_spawn[MAX_CARTRIDGES][3];
new Float:cartridge_spawn_ang[MAX_CARTRIDGES][3];
new bool:cartridge_usable[MAX_CARTRIDGES];
new cartridge_spawn_point[MAX_CARTRIDGES];
new cartridge_count;

new Float:cartridge_mount_point[3] = {-2.3, 0.0, 1.7}; 
new Float:cartridge_mount_point_angles[3] = {0.0, 0.0, 0.0}; 
new Float:controller_plug_mount_point[2][3] = { {13.7, -3.4, 3.16}, {13.7, 3.4, 4.9}}; 
//new Float:controller_player_mount_point[3] = {0.0,0.0,0.0}; 


//new Handle:cart_models_trie;

//-------------------------------------------------------------------------------------------------

#define MAX_SPRITES 16

// sprite stacks
new Handle:sprite_list_inactive = INVALID_HANDLE;

new sprite_x[MAX_SPRITES];
new sprite_y[MAX_SPRITES];
new sprite_frame[MAX_SPRITES];
new sprite_ent[MAX_SPRITES];
new sprite_flags[MAX_SPRITES];
new sprite_rgb[MAX_SPRITES];
new sprite_alpha[MAX_SPRITES];
//new String:sprite_state[MAX_SPRITES];
new String:sprite_active[MAX_SPRITES];

enum {
	SPRITEFLAG_ONSCREEN=1,
	SPRITEFLAG_UPDATEPOS=2,
	SPRITEFLAG_UPDATEFRAME=4,
	SPRITEFLAG_SETCOLOR=8
};


//-------------------------------------------------------------------------------------------------

//#define MAX_SCROLL_PER_FRAME 16 // max amount the screen can scroll in one vgameframe

//#define SCROLL_REFRESH_THRESHOLD 8

new backdrop_ent = -1;

new String:tilemap[MAP_WIDTH*MAP_HEIGHT+1];

new String:bg_model[128];

//new bool:bg_ready; <system changes>
//new bg_setup_state;<system changes>
//new bg_delete_state;<system changes>

new bg_ents[BG_WIDTH*BG_HEIGHT];
new bg_tile[BG_WIDTH*BG_HEIGHT];// current tile held by each bg entity
// bg dirty flags
//   &1 = entity needs a teleport
//   &2 = entity needs a tile update
new bg_dirty[BG_WIDTH*BG_HEIGHT];

new bg_dirty_fifo[BG_WIDTH*BG_HEIGHT+4];
new bg_dirty_fifo_read;
new bg_dirty_fifo_write;

enum {	
	//BGD_POS = 1,
	BGD_TILE = 2,
	BGD_MODEL = 4
};

// scroller entity
new scroller; 

// position of scroll/camera and desired position
// desired is used to stretch long scrolls over multiple frames to avoid lag
new scroll_position;
new last_scroll_position;
new desired_scroll_position;
new bool:scroll_changed;

// tilemap X that is the leftmost side of the screen
//new bg_tilemap_offset; 
// bg ent index that is the leftmost side of the screen
//new bg_draw_offset; 

// screen refresh flags the screen for a full refresh
// the full refresh bypasses the need to teleport bg entities
// for safe operation for instant scroll-to-zero or very large scrolls
// the screen refresh sets scroller_base and sprite positions
// must all be updated

// new functionality: sets TILE flag on all tiles
new screen_refresh;


//new ; // todo?

// *** move this to the global updater
//new bg_update_throttle;

// stack that contains dirty bg entity indexes
//new Handle:dirty_bg_ents = INVALID_HANDLE;

// the offset added to the scroller entity
// this is changed when a screen refresh occurs
// measured in pixels
// multiply by 4/16 for world units
//new scroller_offset; REMOVED IN PLACE OF NEW HOTNESS

//new scroller_abs_position;

 
//-------------------------------------------------------------------------------------------------

#define TEXT_ENTS 150
#define TSCROLL_ENTS 4

new tscroll_ents[TSCROLL_ENTS];
new tscroll_pos[TSCROLL_ENTS][3]; // x,y,layer
new tscroll_dirty[TSCROLL_ENTS];
  
new text_ents[TEXT_ENTS];
new text_pos[TEXT_ENTS][2];		// position
new text_offset[TEXT_ENTS];		// scroller link
new text_frame[TEXT_ENTS];		// frame index
new text_ontime[TEXT_ENTS];		// delay before turning on
new String:text_model[TEXT_ENTS][128];		// model file 
new text_flags[TEXT_ENTS];		// TEXTFLAG_*
new text_size[TEXT_ENTS];		// size scale of model
new text_color[TEXT_ENTS];		// text color codes
new bool:text_on[TEXT_ENTS];
//new text_layer[TEXT_ENTS];		// text layer (replaced by offsets)


new text_dirty_fifo[TEXT_ENTS+4];
new text_dirty_fifo_read;
new text_dirty_fifo_write;

enum {
	TEXTFLAG_ON		=1,
	TEXTFLAG_UPDATE		=2,
	TEXTFLAG_POSITION	=4,
	TEXTFLAG_FRAME		=8,
	TEXTFLAG_MODEL		=16,
	TEXTFLAG_SIZE		=32,
	TEXTFLAG_COLOR		=64,
	TEXTFLAG_OFFSET		=128 
};

//<todo text model cache>

//-------------------------------------------------------------------------------------------------
// registration info
new Handle:romlist_title;	// (array) title of game ie "Super Mareo Bruhs"
new Handle:romlist_entry;	// (array) entry point of game (VGEventReset)
new Handle:romlist_plugin;	// (array) plugin for game
new Handle:romlist_ids;		// (array) ids of game ie "supermareo"

new Handle:romlist_id_trie;	// unique ID string for game ie "supermareo"
							// points to other data in array
	
//-------------------------------------------------------------------------------------------------

new Handle:controlling_plugin;
new Function:romfunc_onentry;
new Function:romfunc_onframe;

//-------------------------------------------------------------------------------------------------

//AUDIO

#define APU_MAX_CHANNELS 16

new apu_num_channels;
new apu_ents[APU_MAX_CHANNELS];

new apu_next_id;

new   Float:apu_channel_time[APU_MAX_CHANNELS];
new         apu_channel_priority[APU_MAX_CHANNELS];
new  String:apu_channel_sample[APU_MAX_CHANNELS][128];
new         apu_channel_id[APU_MAX_CHANNELS];
new   Float:apu_channel_timeout[APU_MAX_CHANNELS];

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

// some sounds

#define SOUND_POWERSWITCH_ON "*videogames/on.mp3"
#define SOUND_POWERSWITCH_OFF "*videogames/off.mp3"

#define SOUND_EJECT "*videogames/eject.mp3"

new String:soundlist[][] = {
	SOUND_POWERSWITCH_ON,
	SOUND_POWERSWITCH_OFF,
	SOUND_EJECT
};
