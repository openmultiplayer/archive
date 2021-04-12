/**	PLAYER ATTACHED OBJECT EDITOR
  * - Author: Robo_N1X
  * - Version: 0.4
  * - Date: November 2015
  * - Forum Topic: http://forum.sa-mp.com/showthread.php?t=416138
  */
/** This Source Code Form is subject to the terms of the Mozilla Public
  * License, v. 2.0. If a copy of the MPL was not distributed with this
  * file, You can obtain one at http://mozilla.org/MPL/2.0/
  *
  * Software distributed under the License is distributed on an "AS IS" basis,
  * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  * for the specific language governing rights and limitations under the
  * License.
  *
  * Credits & thanks to: SA-MP Team, Scott/h02, Zeex, Y_Less,
  * and whoever helped or made some part of code used in this script.
  */
#define FILTERSCRIPT	// Mark this as a filterscript
// Includes
#include <a_samp>		// v0.3e+ Credits to SA-MP team
#include <sscanf2>		// v2.8.1 Credits to Y_Less
#include <zcmd>			// v0.3.1 Credits to Zeex
// Script configurations (defines and macros)
#define AOE_FILE_NAME					"%s_pao.txt"			// Player attached object file (%s = name) located in '\scriptfiles' folder by default
#define AOE_VERSION						"0.4 - November 2015"	// Version string
#define AOE_SMALLER_SAVE				true					// Wheter the editor should skip writing default/zero value in the function argument
#define MAX_ATTACHED_OBJECT_BONES		(18)					// Not necessary to change unless there is change in SA:MP.
#define MAX_ATTACHED_OBJECT_BONE_NAME	(16)					// Max attached object bone name length
#define MAX_ATTACHED_OBJECT_OFFSET		300.0					// Max (+) attached object offset limit
#define MIN_ATTACHED_OBJECT_OFFSET		-300.0					// Min (-) attached object offset limit
#define MAX_ATTACHED_OBJECT_ROTATION	360.0					// Max (+) attached object rotation limit
#define MIN_ATTACHED_OBJECT_ROTATION	-360.0					// Min (-) attached object rotation limit
#define MAX_ATTACHED_OBJECT_SIZE		100.0					// Max (+) attached object scale limit
#define MIN_ATTACHED_OBJECT_SIZE		-100.0					// Min (-) attached object scale limit
#define HexPrintFormat(%0) %0 >>> 16, %0 & 0xFFFF				// printf fix for hex (format: 0x%04x%04x) - credits to Y_Less
#define strupdate(%0,%1) %0[0] = EOS, strins(%0,%1,0)			// To replace whole string
// Color defines
#define AOE_COLOR0		(0xFFFFFFFF) // White
#define AOE_COLOR1		(0xCC0033FF) // Red
#define AOE_COLOR2		(0x00CC00FF) // Green
#define AOE_COLOR3		(0x0066FFFF) // Blue
#define AOE_COLOR4		(0xFFFF33FF) // Yellow
#define AOE_COLOR5		(0x33FFFFFF) // Cyan
// Common non-format message defines
#define AOE_M_ACCEPTABLE_OFFSET		"** Offset (X/Y/Z) greater than or equal to "#MAX_ATTACHED_OBJECT_OFFSET" and less than or equal to "#MIN_ATTACHED_OBJECT_OFFSET";"
#define AOE_M_ACCEPTABLE_ROTATION	"** Rotation (RX/RY/RZ) greater than or equal to "#MAX_ATTACHED_OBJECT_OFFSET" and less than or equal to "#MIN_ATTACHED_OBJECT_OFFSET";"
#define AOE_M_ACCEPTABLE_SCALE		"** Scale (SX/SY/SZ) greater than or equal to "#MAX_ATTACHED_OBJECT_OFFSET" and less than or equal to "#MIN_ATTACHED_OBJECT_OFFSET";"
#define AOE_M_CANT_EDIT				"* Sorry, you can't use this command right now."
#define AOE_M_COMMENT_INFO			"** Valid comment length is equal or less than 99 characters and only contains alphabet letter or number."
#define AOE_M_COMMENT_INVALID		"* Warning: Comment contains invalid character, ignoring anyway."
#define AOE_M_CREATE_CANCEL			"* You've canceled creating attached object."
#define AOE_M_CREATE_FAIL			"* Failed to create attached object due to error."
#define AOE_M_DELETE_ADMIN_ONLY		"* Sorry, only Server Administrator can delete player attached object(s) file."
#define AOE_M_DELETE_CANCEL			"* You've canceled deleting attached object file."
#define AOE_M_DELETING				"* Deleting attached object(s) file, please wait..."
#define AOE_M_DIALOG_CLOSE			"* You've closed attached object editor dialog."
#define AOE_M_DUPLICATE_FAIL		"* Failed to duplicate attached object due to error."
#define AOE_M_DUPLICATE_INFO		"** Allows you to duplicate your existing attached object to another slot."
#define AOE_M_DUPLICATE_USAGE		"* Usage: /duplicateattachedobject <FromAttachedObjectIndex> <ToAttachedObjectIndex>"
#define AOE_M_EDIT_CANCEL			"* You've canceled editing attached object."
#define AOE_M_EDIT_HINT_ONFOOT		"** Hint: Use {FFFFFF}~k~~PED_SPRINT~{FFFF33} key to look around."
#define AOE_M_EDIT_HINT_VEHICLE		"** Hint: Use {FFFFFF}~k~~VEHICLE_ACCELERATE~{FFFF33} key to look around."
#define AOE_M_EDIT_INFO				"** Allows you to adjust your attached object from specified slot with your cursor."
#define AOE_M_EDIT_NOTHING			"* Sorry, you don't have any attached object to edit!"
#define AOE_M_EDIT_NOTICE			"* Please finish (Save) or cancel (ESC) the edit first!"
#define AOE_M_EDIT_SKIP				"* You've skipped to edit your attached object."
#define AOE_M_EDIT_SKIP_INFO		"** Note: use /editattachedobject command to edit your attached object."
#define AOE_M_EDIT_USAGE			"* Usage: /editattachedobject <AttachedObjectIndex>"
#define AOE_M_ERROR					"* There was an error when performing this action."
#define AOE_M_FILE_CANCEL			"* You've canceled managing attached object(s) file."
#define AOE_M_INVALID_COLOR			"* Sorry, you've entered invalid new color value."
#define AOE_M_INVALID_XYZ			"* Sorry, you've entered invalid new value."
#define AOE_M_LOADING				"* Loading attached object file, please wait..."
#define AOE_M_LOADING_SET			"* Loading attached object(s) set file, please wait..."
#define AOE_M_MAX_SLOT_INFO			"* You can only hold "#MAX_PLAYER_ATTACHED_OBJECTS" attached object(s) at one time, please remove some."
#define AOE_M_NO_ATTACHED_OBJECT	"* Sorry, you don't have any attached object."
#define AOE_M_NO_ENOUGH_SLOT		"* Sorry, you can't have more attached object(s) (Limit exceeded)."
#define AOE_M_OBJECT_DATA_PRINT		"* As you're an admin, you can print this attached object properties & usage to the console."
#define AOE_M_OBJECT_DATA_S_PRINT	"SERVER: Attached object properties has been printed to server console!"
#define AOE_M_OVERWRITE				"* As you're an admin, you can replace an existed attached object file"
#define AOE_M_PROPERTIES_CLOSE		"* You've closed your attached object properties dialog."
#define AOE_M_PROPERTIES_INFO		"** Allows you to view your or another player's attached object properties."
#define AOE_M_PROPERTIES_USAGE		"* Usage: /attachedobjectproperties <AttachedObjectIndex> <Optional:Player>"
#define AOE_M_REFRESH_INFO			"** Allows you to load another player's attached object from specified slot."
#define AOE_M_REFRESH_OWN			"* Sorry, you can't refresh your own attached object."
#define AOE_M_REFRESH_USAGE			"* Usage: /refreshattachedobject <PlayerName/ID> <AttachedObjectIndex>"
#define AOE_M_REFRESH_WARNING		"* Warning: You are attempting to load another player's attached object on your existing attached object index."
#define AOE_M_REMOVE_ALL_CANCEL		"* You've canceled removing all your attached object(s)."
#define AOE_M_REMOVE_INFO			"** Allows you to remove your attached object from specified slot."
#define AOE_M_REMOVE_USAGE			"* Usage: /removeattachedobject <AttachedObjectIndex>"
#define AOE_M_RESET_ADMIN_ONLY		"* Sorry, only Server Administrator can reset player's attached object editor variable."
#define AOE_M_RESET_INFO			"** Allows you to reset a player's attached object editor variable(s) to its first state. Only use when needed (in rare case)"
#define AOE_M_RESET_USAGE			"* Usage: /resetattachedobjecteditor <PlayerName/ID> <Optional:AttachedObjectIndex>"
#define AOE_M_SAVE_ERROR			"* Error: Invalid attached object data, save canceled."
#define AOE_M_SAVE_FAILED			"* Error: Invalid attached object(s) data, save canceled."
#define AOE_M_SAVE_OVERWRITE		"** The attached object data on file has been overwritten (Re-Created)."
#define AOE_M_SAVE_SET_ERROR		"** Error: file saving was canceled because there were no valid attached object!"
#define AOE_M_SAVE_SET_OVERWRITE	"** The attached object(s) data on file has been overwritten (Re-Created)."
#define AOE_M_SAVING				"* Saving attached object file, please wait..."
#define AOE_M_SAVING_SET			"* Saving attached object(s) set file, please wait..."
#define AOE_M_SET_BONE_INFO			"** Allows you to change your attached object bone to another bone, valid bone numbers are 1 to "#MAX_ATTACHED_OBJECT_BONE"."
#define AOE_M_SET_BONE_USAGE		"* Usage: /setattachedobjectbone <AttachedObjectIndex> <BoneName/ID>"
#define AOE_M_SET_COLOR1_INFO		"** Allows you to set your attached object color (Material:1) with specified parameters."
#define AOE_M_SET_COLOR1_USAGE		"* Usage: /setattachedobjectmc1 <AttachedObjectIndex> <MaterialColor>"
#define AOE_M_SET_COLOR2_INFO		"** Allows you to set your attached object color (Material:2) with specified parameters."
#define AOE_M_SET_COLOR2_USAGE		"* Usage: /setattachedobjectmc2 <AttachedObjectIndex> <MaterialColor>"
#define AOE_M_SET_COLOR_INFO		"** Allows you to set your attached object material color(s) with specified parameters."
#define AOE_M_SET_COLOR_USAGE		"* Usage: /setattachedobjectmc <AttachedObjectIndex> <MaterialColor1> <MaterialColor2>"
#define AOE_M_SET_MODEL_FAIL		"* Failed to change attached object model due to error."
#define AOE_M_SET_MODEL_INFO		"** Allows you to change your attached object model with another model (must be valid GTA:SA/SA-MP object model)."
#define AOE_M_SET_MODEL_USAGE		"* Usage: /setattachedobjectmodel <AttachedObjectIndex> <ObjectModel>"
#define AOE_M_SET_OFFSET_INFO		"** Allows you to set your attached object position/offset with specified parameters."
#define AOE_M_SET_OFFSET_USAGE		"* Usage: /setattachedobjectoffset <AttachedObjectIndex> <X/Y/Z> <Float:OffsetValue>"
#define AOE_M_SET_ROTATION_INFO		"** Allows you to set your attached object rotation with specified parameters."
#define AOE_M_SET_ROTATION_USAGE	"* Usage: /setattachedobjectrot <AttachedObjectIndex> <X/Y/Z> <Float:RotationValue>"
#define AOE_M_SET_SCALE_INFO		"** Allows you to set your attached object scale/size with specified parameters."
#define AOE_M_SET_SCALE_USAGE		"* Usage: /setattachedobjectscale <AttachedObjectIndex> <X/Y/Z> <Float:ScaleValue>"
#define AOE_M_SET_SLOT_FAIL			"* Failed to change attached object slot due to error."
#define AOE_M_SET_SLOT_INFO			"** Allows you to change your attached object slot to another slot, valid slot numbers are 0 to 9."
#define AOE_M_SET_SLOT_USAGE		"* Usage: /setattachedobjectindex <OldAttachedObjectIndex> <NewAttachedObjectIndex>"
#define AOE_M_TARGET_NOT_ONLINE		"* Sorry, the target player is not connected."
#define AOE_M_UNDELETE_HINT			"** Hint: Leave the command parameter empty to restore last deleted object."
#define AOE_M_UNDELETE_NOTHING		"* Sorry, you don't have any attached object to restore."
#define AOE_M_UNDELETE_NO_PARAM		"* No parameter given, attempting to restore the last removed attached object..."
#define AOE_M_UNKNOWN_DATA			"* Warning: This attached object has unknown data, please save it first to refresh the data!"
#define AOE_M_VALID_NAME_INFO1		"** Valid length is greater than or equal to 1 and less than or equal to 24 characters."
#define AOE_M_VALID_NAME_INFO2		"** Valid characters are: A to Z or a to z, 0 to 9 and @$()_=[] symbols for the next character."
#define AOE_M_VALID_OFFSET			"** Allowed float (Offset) value is larger than "#MIN_ATTACHED_OBJECT_OFFSET" and less than "#MAX_ATTACHED_OBJECT_OFFSET"."
#define AOE_M_VALID_ROTATION		"** Allowed float (Rotation) value is larger than "#MIN_ATTACHED_OBJECT_ROTATION" and less than "#MAX_ATTACHED_OBJECT_ROTATION"."
#define AOE_M_VALID_SCALE			"** Allowed float (Scale) value is larger than "#MIN_ATTACHED_OBJECT_SIZE" and less than "#MAX_ATTACHED_OBJECT_SIZE"."
// Common non-format gametext defines
#define AOE_G_COLOR_UPDATED			"~g~Attached object color updated!"
#define AOE_G_OFFSET_UPDATED		"~g~Attached object position updated!"
#define AOE_G_ROTATION_UPDATED		"~g~Attached object rotation updated!"
#define AOE_G_SCALE_UPDATED			"~g~Attached object size updated!"
#define AOE_G_DOH					"~y~DOH!"
#define AOE_G_CANT_RESTORE			"~r~~h~Can't restore attached object!"
#define AOE_G_FILE_DELETED			"~r~~h~Attached object file deleted!"
#define AOE_G_FILE_EXISTED			"~r~~h~File already exists!"
#define AOE_G_FILE_NOT_EXIST		"~r~~h~File does not exist!"
#define AOE_G_INVALID_BONE			"~r~~h~Invalid attached object bone!"
#define AOE_G_INVALID_DATA			"~r~~h~Invalid attached object data!"
#define AOE_G_INVALID_FILE_NAME		"~r~~h~Invalid file name!"
#define AOE_G_INVALID_MODEL			"~r~~h~Invalid object model!"
#define AOE_G_INVALID_OFFSET		"~r~~h~Invalid attached object offset value!"
#define AOE_G_INVALID_ROTATION		"~r~~h~Invalid attached object rotation value!"
#define AOE_G_INVALID_SCALE			"~r~~h~Invalid attached object size value!"
#define AOE_G_INVALID_SLOT			"~r~~h~Invalid attached object slot!"
#define AOE_G_NO_ATTACHED_OBJECT	"~r~~h~Found no attached object!"
#define AOE_G_NO_ENOUGH_SLOT		"~r~~h~Too many attached objects!"
#define AOE_G_NO_RESTORE			"~r~~h~No attached object can be restored!"
// Dialog ID defines
#define AOE_D					400			// Main Menu ID
#define AOE_D_CREATE_SLOT		(AOE_D+1)
#define AOE_D_CREATE_MODEL		(AOE_D+2)
#define AOE_D_CREATE_BONE		(AOE_D+3)
#define AOE_D_CREATE_REPLACE	(AOE_D+4)
#define AOE_D_CREATE_EDIT		(AOE_D+5)
#define AOE_D_FILE				(AOE_D+6)
#define AOE_D_LOAD				(AOE_D+7)
#define AOE_D_LOAD_SLOT			(AOE_D+8)
#define AOE_D_LOAD_REPLACE		(AOE_D+9)
#define AOE_D_LOAD2				(AOE_D+10)
#define AOE_D_SAVE_SLOT			(AOE_D+11)
#define AOE_D_SAVE				(AOE_D+12)
#define AOE_D_SAVE_REPLACE		(AOE_D+13)
#define AOE_D_SAVE2				(AOE_D+14)
#define AOE_D_SAVE2_REPLACE		(AOE_D+15)
#define AOE_D_DELETE			(AOE_D+16)
#define AOE_D_EDIT_SLOT			(AOE_D+17)
#define AOE_D_EDIT				(AOE_D+18)
#define AOE_D_EDIT_PROPERTIES	(AOE_D+19)
#define AOE_D_SET_SLOT			(AOE_D+20)
#define AOE_D_SET_SLOT_REPLACE	(AOE_D+21)
#define AOE_D_SET_MODEL			(AOE_D+22)
#define AOE_D_SET_BONE			(AOE_D+23)
#define AOE_D_EDIT_XYZ			(AOE_D+24)
#define AOE_D_EDIT_COLOR		(AOE_D+25)
#define AOE_D_PROPERTIES		(AOE_D+26)
#define AOE_D_DUPLICATE_SLOT	(AOE_D+27)
#define AOE_D_DUPLICATE_REPLACE	(AOE_D+28)
#define AOE_D_REMOVE_ALL		(AOE_D+29)
#define AOE_D_REFRESH			(AOE_D+30)
#define AOE_D_REFRESH_REPLACE	(AOE_D+31)
// Dialog class defines
#define AOE_C					(0)
#define AOE_C_FILE				(1)
#define AOE_C_EDIT				(2)
#define AOE_C_HELP				(3)
#define AOE_C_ABOUT				(4)
#define AOE_C_SLOT_EMPTY		(5)
#define AOE_C_SLOT_USED			(6)
#define AOE_C_SLOT_ALL			(7)
#define AOE_C_REFRESH			(8)
#define AOE_C_MODEL				(9)
#define AOE_C_BONE				(10)
#define AOE_C_CREATE_FINAL		(11)
#define AOE_C_REMOVE_ALL		(12)
#define AOE_C_PROPERTIES		(13)
#define AOE_C_EDIT_PROPERTIES	(14)
#define AOE_C_EDIT_XYZ			(15)
#define AOE_C_EDIT_COLOR		(16)
#define AOE_C_DUPLICATE_REPLACE	(17)
#define AOE_C_CREATE_REPLACE	(18)
#define AOE_C_SET_INDEX_REPLACE	(19)
#define AOE_C_REFRESH_REPLACE	(20)
#define AOE_C_LOAD_REPLACE		(21)
#define AOE_C_SAVE_REPLACE		(22)
#define AOE_C_SAVE				(23)
#define AOE_C_LOAD				(24)
#define AOE_C_DELETE			(25)
// Common non-format dialog title defines
#define AOE_T				"Attached Object Editor"
#define AOE_T_ABOUT			"About Attached Object Editor"
#define AOE_T_CREATE		"Create Attached Object"
#define AOE_T_CREATE_EDIT	"Create Attached Object (Edit)"
#define AOE_T_DELETE		"Delete Attached Object(s) File"
#define AOE_T_DUPLICATE		"Duplicate Attached Object"
#define AOE_T_EDIT			"Edit Attached Object"
#define AOE_T_FILE			"Manage Attached Object File"
#define AOE_T_HELP			"Attached Object Editor Help"
#define AOE_T_LOAD			"Load Attached Object"
#define AOE_T_LOAD_SET		"Load Attached Object(s) Set"
#define AOE_T_REFRESH		"Refresh Attached Object"
#define AOE_T_REMOVE_ALL	"Clear All Attached Object(s)"
#define AOE_T_SAVE			"Save Attached Object"
#define AOE_T_SAVE_SET		"Save Attached Object(s) Set"
#define AOE_T_SET_BONE		"Set Attached Object Bone"
#define AOE_T_SET_INDEX		"Set Attached Object Index"
#define AOE_T_SET_MODEL		"Set Attached Object Model"
#define AOE_T_REPLACE		" (Replace)"
// Common non-format dialog info text defines
#define AOE_I_ENTER_MODEL \
	"Please enter a valid GTA:SA/SA:MP object model id/number below:"
#define AOE_I_LOAD_NAME \
	"Please enter an valid and existing attached object file name below,\n\n"#AOE_I_VALID_NAME
#define AOE_I_SAVE_NAME \
	"Please enter a valid file name to save this attached object below,\n\n"#AOE_I_VALID_NAME
#define AOE_I_VALID_NAME \
	"Please note that valid characters are:\nA to Z or a to z, 0 to 9 and @, $, (, ), [, ], _, =\nand the length must be 1-24 characters long"
// Common non-format dialog button defines
#define AOE_B_BACK			"Back"
#define AOE_B_CANCEL		"Cancel"
#define AOE_B_CLOSE			"Close"
#define AOE_B_DELETE		"Delete"
#define AOE_B_DUPLICATE		"Duplicate"
#define AOE_B_EDIT			"Edit"
#define AOE_B_EDIT_CREATE	"Edit/Create"
#define AOE_B_ENTER			"Enter"
#define AOE_B_LOAD			"Load"
#define AOE_B_PRINT			"Print"
#define AOE_B_SAVE			"Save"
#define AOE_B_SELECT		"Select"
#define AOE_B_SELECT_INDEX	"Sel. Index"
#define AOE_B_SELECT_MODEL	"Sel. Model"
#define AOE_B_SET			"Set"
#define AOE_B_SKIP			"Skip"
#define AOE_B_YES			"Yes"
// =============================================================================
new AOE_STR[128];
enum E_ATTACHED_OBJECT
{
	AO_STATUS, AO_MODEL_ID, AO_BONE_ID,
	Float:AO_X, Float:AO_Y, Float:AO_Z,
	Float:AO_RX, Float:AO_RY, Float:AO_RZ,
	Float:AO_SX, Float:AO_SY, Float:AO_SZ,
	hex:AO_MC1, hex:AO_MC2
}
new PAO[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][E_ATTACHED_OBJECT];
enum E_EDITOR_PVAR
{
	PAO_INDEX1, PAO_INDEX2, PAO_MODEL_ID, PAO_BONE_ID, PAO_LAST_REMOVED,
	PAO_NAME[24], PAO_EDITING, PAO_TARGET
}
new EPV[MAX_PLAYERS][E_EDITOR_PVAR];
new const AttachedObjectBones[MAX_ATTACHED_OBJECT_BONES][MAX_ATTACHED_OBJECT_BONE_NAME] =
{
	{"Spine"},
	{"Head"},
	{"Left upper arm"}, {"Right upper arm"},
	{"Left hand"}, {"Right hand"},
	{"Left thigh"}, {"Right thigh"},
	{"Left foot"}, {"Right foot"},
	{"Right calf"}, {"Left calf"},
	{"Left forearm"}, {"Right forearm"},
	{"Left clavicle"}, {"Right clavicle"},
	{"Neck"},
	{"Jaw"}
};
new AOSelection, AOSlot, AOModel, AOBone, Float:AOAxis, hex:AOMC,
	AOTarget, pName[MAX_PLAYER_NAME], AOFileName[32+1], Float:AOFileLen, AOComment[64];
forward AOE_GetPVar(playerid, varname[]);
// =============================================================================
public OnFilterScriptInit()
{
	print("  Attached Object Editor by Robo_N1X\n  -------------loading--------------\n  >> Version: "#AOE_VERSION" for SA:MP 0.3e+");
	new totalAttachedObjects;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			for(new x = 0; x < MAX_PLAYER_ATTACHED_OBJECTS; x++)
			{
				if(IsPlayerAttachedObjectSlotUsed(i, x))
				{
					PAO[i][x][AO_STATUS] = 0;
					totalAttachedObjects++;
				}
				else AOE_UnsetValues(i, x);
			}
			EPV[i][PAO_LAST_REMOVED] = MAX_PLAYER_ATTACHED_OBJECTS;
		}
	}
	printf("  >> Player attached objects count: %d", totalAttachedObjects);
	return 1;
}

public OnFilterScriptExit()
{
	print("  Attached Object Editor by Robo_N1X\n  -------------unloading------------\n  >> Version: "#AOE_VERSION" for SA:MP 0.3e+");
	new totalAttachedObjects;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			for(new x = 0; x < MAX_PLAYER_ATTACHED_OBJECTS; x++)
			{
				totalAttachedObjects += IsPlayerAttachedObjectSlotUsed(i, x);
				if(PAO[i][x][AO_STATUS] == 1 && !IsPlayerAdmin(i))
					RemovePlayerAttachedObjectEx(i, x);
			}
			AOE_UnsetVars(i);
		}
	}
	printf("  >> Player attached objects count: %d", totalAttachedObjects);
	return 1;
}

public OnPlayerConnect(playerid)
{
	for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, i)) PAO[playerid][i][AO_STATUS] = 1;
		else
		{
			RemovePlayerAttachedObject(playerid, i);
			EPV[playerid][PAO_LAST_REMOVED] = MAX_PLAYER_ATTACHED_OBJECTS;
		}
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		AOE_UnsetValues(playerid, i);
	}
	AOE_UnsetVars(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	new slots;
	for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		if(PAO[playerid][i][AO_STATUS] == 1)
			slots += RestorePlayerAttachedObject(playerid, i);
	}
	if(slots > 0)
	{
		format(AOE_STR, sizeof AOE_STR, "* Automatically restored your attached object(s) ({FFFFFF}Total: %d{%06x}).", slots, AOE_COLOR2 >>> 8);
		SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
	}
	return 1;
}
// -----------------------------------------------------------------------------
CMD:attachedobjecteditor(playerid, params[])
{
	#pragma unused params
	if(AOE_CanEdit(playerid)) AOE_ShowPlayerDialog(playerid, AOE_C, AOE_D, AOE_T, AOE_B_SELECT, AOE_B_CLOSE);
	return 1;
}
CMD:aoe(playerid, params[]) return cmd_attachedobjecteditor(playerid, params);

CMD:removeattachedobjects(playerid, params[])
{
	#pragma unused params
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid)) AOE_ShowPlayerDialog(playerid, AOE_C_REMOVE_ALL, AOE_D_REMOVE_ALL, AOE_T_REMOVE_ALL, AOE_B_YES, AOE_B_CANCEL);
	}
	return 1;
}
CMD:raos(playerid, params[]) return cmd_removeattachedobjects(playerid, params);

CMD:createattachedobject(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasFreeSlot(playerid))
		{
			new bonename[MAX_ATTACHED_OBJECT_BONE_NAME];
			if(sscanf(params, "dD(-1)S()[16]", AOSlot, AOModel, bonename)) AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_CREATE_SLOT, AOE_T_CREATE, AOE_B_SELECT, AOE_B_CANCEL);
			else
			{
				if(AOE_EnteredValidSlot(playerid, AOSlot))
				{
					EPV[playerid][PAO_INDEX1] = AOSlot;
					if(IsPlayerAttachedObjectSlotUsed(playerid, AOSlot)) AOE_ShowPlayerDialog(playerid, AOE_C_CREATE_REPLACE, AOE_D_CREATE_REPLACE, AOE_T_CREATE#AOE_T_REPLACE, AOE_B_YES,AOE_B_BACK);
					else
					{
						if(AOModel == -1) AOE_ShowPlayerDialog(playerid, AOE_C_MODEL, AOE_D_CREATE_MODEL, AOE_T_CREATE, AOE_B_ENTER, AOE_B_SELECT_INDEX);
						else
						{
							if(AOE_EnteredValidModel(playerid, AOModel))
							{
								EPV[playerid][PAO_MODEL_ID] = AOModel;
								if(isnull(bonename)) AOE_ShowPlayerDialog(playerid, AOE_C_BONE, AOE_D_CREATE_BONE, AOE_T_CREATE, AOE_B_SELECT, AOE_B_SELECT_MODEL);
								else
								{
									if(AOE_EnteredValidBone(playerid, bonename))
									{
										AOBone = GetAttachedObjectBone(bonename);
										EPV[playerid][PAO_BONE_ID] = AOBone;
										if(UpdatePlayerAttachedObjectEx(playerid, AOSlot, AOModel, AOBone))
										{
											format(AOE_STR, sizeof AOE_STR, "* Created attached object model %d at bone %s (%d) in slot number {FFFFFF}%d{%06x}.", AOModel, GetAttachedObjectBoneName(AOBone), AOBone, AOSlot, AOE_COLOR3 >>> 8);
											SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
											format(AOE_STR, sizeof AOE_STR, "~b~Created attached object~n~~w~index number: %d~n~Model: %d ~ Bone: %d.", AOSlot, AOModel, AOBone);
											AOE_GameTextForPlayer(playerid, AOE_STR);
											AOE_ShowPlayerDialog(playerid, AOE_C_CREATE_FINAL, AOE_D_CREATE_EDIT, AOE_T_CREATE_EDIT, AOE_B_EDIT, AOE_B_SKIP);
										}
										else SendClientMessage(playerid, AOE_COLOR1, AOE_M_CREATE_FAIL);
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:cao(playerid, params[]) return cmd_createattachedobject(playerid, params);

CMD:editattachedobject(playerid, params[])
{
	new playerState = GetPlayerState(playerid);
	if(EPV[playerid][PAO_EDITING] >= 1) CancelEdit(playerid);
	else if(playerState == PLAYER_STATE_WASTED || playerState == PLAYER_STATE_SPECTATING)
		SendClientMessage(playerid, AOE_COLOR4, AOE_M_CANT_EDIT);
	else
	{
		if(AOE_HasAttachedObject(playerid))
		{
			if(sscanf(params, "d", AOSlot))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_EDIT_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_EDIT_INFO);
			}
			else
			{
				if(AOE_EnteredValidSlot(playerid, AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						EditAttachedObject(playerid, AOSlot);
						PAO[playerid][AOSlot][AO_STATUS] = 2;
						format(AOE_STR, sizeof AOE_STR, "* You're now editing your attached object at index number {FFFFFF}%d{%06x}.", AOSlot, AOE_COLOR5 >>> 8);
						SendClientMessage(playerid, AOE_COLOR5, AOE_STR);
						format(AOE_STR, sizeof AOE_STR, "~b~~h~Editing your attached object~n~~w~index number: %d", AOSlot);
						AOE_GameTextForPlayer(playerid, AOE_STR);
						if(IsValidPlayerAttachedObject(playerid, AOSlot) != 1)
						{
							SendClientMessage(playerid, AOE_COLOR1, AOE_M_UNKNOWN_DATA);
							EPV[playerid][PAO_EDITING] = 2;
						}
						else EPV[playerid][PAO_EDITING] = 1;
						if(IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid, AOE_COLOR4, AOE_M_EDIT_HINT_VEHICLE);
						else SendClientMessage(playerid, AOE_COLOR4, AOE_M_EDIT_HINT_ONFOOT);
					}
				}
				else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_USED, AOE_D_EDIT_SLOT, AOE_T_EDIT, AOE_B_EDIT_CREATE, AOE_B_CANCEL);
			}
		}
	}
	return 1;
}

CMD:eao(playerid, params[]) return cmd_editattachedobject(playerid, params);

CMD:removeattachedobject(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			if(sscanf(params, "d", AOSlot))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_REMOVE_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_REMOVE_INFO);
			}
			else
			{
				if(AOSlot == MAX_PLAYER_ATTACHED_OBJECTS) cmd_removeattachedobjects(playerid, "");
				else
				{
					if(AOE_EnteredValidSlot(playerid, AOSlot))
					{
						if(AOE_HasSlot(playerid, AOSlot))
						{
							EPV[playerid][PAO_INDEX1] = AOSlot;
							if(IsValidPlayerAttachedObject(playerid, AOSlot)) format(AOE_STR, sizeof AOE_STR, "* You've removed your attached object from index number {FFFFFF}%d{%06x} (/udao to undelete last).", AOSlot, AOE_COLOR2 >>> 8);
							else format(AOE_STR, sizeof AOE_STR, "* You've removed your attached object from index number {FFFFFF}%d{%06x}.", AOSlot, AOE_COLOR2 >>> 8);
							RemovePlayerAttachedObjectEx(playerid, AOSlot);
							SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "~b~~h~Removed your attached object~n~~w~index number: %d", AOSlot);
							AOE_GameTextForPlayer(playerid, AOE_STR);
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:rao(playerid, params[]) return cmd_removeattachedobject(playerid, params);

CMD:undeleteattachedobject(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasFreeSlot(playerid))
		{
			if(sscanf(params, "D(-1)", AOSlot))
			{
				format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object index number ({FFFFFF}%s{%06x}).", params, AOE_COLOR4 >>> 8);
				SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
				AOE_GameTextForPlayer(playerid, AOE_G_INVALID_SLOT);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_UNDELETE_HINT);
			}
			else
			{
				if(0 <= EPV[playerid][PAO_LAST_REMOVED] < MAX_PLAYER_ATTACHED_OBJECTS)
				{
					if(AOSlot == -1)
					{
						AOSlot = EPV[playerid][PAO_LAST_REMOVED];
						valstr(AOE_STR, AOSlot);
						SendClientMessage(playerid, AOE_COLOR4, AOE_M_UNDELETE_NO_PARAM);
						cmd_undeleteattachedobject(playerid, AOE_STR);
					}
					else if(IsValidAttachedObjectSlot(AOSlot))
					{
						if(IsPlayerAttachedObjectSlotUsed(playerid, AOSlot))
						{
								format(AOE_STR, sizeof AOE_STR, "* Sorry, you can't restore your removed attached object as it was replaced with another object in that slot already (%d).", AOSlot);
								SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
								AOE_GameTextForPlayer(playerid, AOE_G_CANT_RESTORE);
						}
						else
						{
							EPV[playerid][PAO_INDEX1] = AOSlot;
							if(RestorePlayerAttachedObject(playerid, AOSlot))
							{
								format(AOE_STR, sizeof AOE_STR, "* You've restored your attached object from index number {FFFFFF}%d{%06x} [Model: %d|Bone: %s (%d)]", AOSlot, AOE_COLOR3 >>> 8,
								PAO[playerid][AOSlot][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[playerid][AOSlot][AO_BONE_ID]), PAO[playerid][AOSlot][AO_BONE_ID]);
								SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
								format(AOE_STR, sizeof AOE_STR, "~b~Restored your attached object~n~~w~index number: %d~n~Model: %d ~ Bone: %d", AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID]);
								AOE_GameTextForPlayer(playerid, AOE_STR);
							}
							else
							{
								format(AOE_STR, sizeof AOE_STR, "* Sorry, you can't restore your removed attached object from index number %d as it's not valid.", AOSlot);
								SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
								AOE_GameTextForPlayer(playerid, AOE_G_CANT_RESTORE);
							}
						}
					}
					else
					{
						format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object index number ({FFFFFF}%d{%06x}).", AOSlot, AOE_COLOR4 >>> 8);
						SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
						AOE_GameTextForPlayer(playerid, AOE_G_INVALID_SLOT);
						SendClientMessage(playerid, AOE_COLOR0, AOE_M_UNDELETE_HINT);
					}
				}
				else
				{
					SendClientMessage(playerid, AOE_COLOR1, AOE_M_UNDELETE_NOTHING);
					AOE_GameTextForPlayer(playerid, AOE_G_NO_RESTORE);
				}
			}
		}
	}
	return 1;
}

CMD:udao(playerid, params[]) return cmd_undeleteattachedobject(playerid, params);

CMD:refreshattachedobject(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasFreeSlot(playerid))
		{
			if(sscanf(params, "uD(-1)", AOTarget, AOSlot))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_REFRESH_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_REFRESH_INFO);
			}
			else
			{
				if(AOTarget == playerid) SendClientMessage(playerid, AOE_COLOR4, AOE_M_REFRESH_OWN);
				else
				{
					if(AOTarget == INVALID_PLAYER_ID) SendClientMessage(playerid, AOE_COLOR4, AOE_M_TARGET_NOT_ONLINE);
					else
					{
						EPV[playerid][PAO_TARGET] = AOTarget;
						GetPlayerName(AOTarget, pName, sizeof pName);
						if(GetPlayerAttachedObjectsCount(AOTarget))
						{
							if(AOSlot == -1) AOE_ShowPlayerDialog(playerid, AOE_C_REFRESH, AOE_D_REFRESH, AOE_T_REFRESH, AOE_B_SELECT, AOE_B_CANCEL);
							else
							{
								if(AOE_TargetHasSlot(playerid, AOTarget, AOSlot))
								{
									EPV[playerid][PAO_INDEX1] = AOSlot;
									if(IsPlayerAttachedObjectSlotUsed(playerid, AOSlot)) AOE_ShowPlayerDialog(playerid, AOE_C_REFRESH_REPLACE, AOE_D_REFRESH_REPLACE, AOE_T_REFRESH#AOE_T_REPLACE, AOE_B_YES, AOE_B_BACK);
									else
									{
										if(RefreshPlayerAttachedObject(AOTarget, playerid, AOSlot))
										{
											format(AOE_STR, sizeof AOE_STR, "* You've refershed %s (ID:%d)'s attached object from index number %d [Model: %d|Bone: %s (%d)].",
											pName, AOTarget, AOSlot, PAO[AOTarget][AOSlot][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[AOTarget][AOSlot][AO_BONE_ID]), PAO[AOTarget][AOSlot][AO_BONE_ID]);
											SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
											format(AOE_STR, sizeof AOE_STR, "~b~~h~Refreshed ~w~%s~b~~h~'s~n~attached object from slot ~w~%d", pName, AOSlot);
											AOE_GameTextForPlayer(playerid, AOE_STR);
											GetPlayerName(playerid, pName, sizeof pName);
											format(AOE_STR, sizeof AOE_STR, "* %s (ID:%d) has refreshed your attached object from index number %d [Model: %d|Bone: %s (%d)].",
											pName, playerid, AOSlot, PAO[AOTarget][AOSlot][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[AOTarget][AOSlot][AO_BONE_ID]), PAO[AOTarget][AOSlot][AO_BONE_ID]);
											SendClientMessage(AOTarget, AOE_COLOR2, AOE_STR);
											format(AOE_STR, sizeof AOE_STR, "~w~%s~b~~h~ has refreshed~n~your attached object at slot ~w~%d", pName, AOSlot);
											AOE_GameTextForPlayer(AOTarget, AOE_STR);
										}
										else SendClientMessage(playerid, AOE_COLOR1, AOE_M_ERROR);
									}
								}
							}
						}
						else
						{
							format(AOE_STR, sizeof AOE_STR, "* Sorry, %s (ID:%d) has no attached object.", pName, AOTarget);
							SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
							AOE_GameTextForPlayer(playerid, AOE_G_NO_ATTACHED_OBJECT);
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:rpao(playerid, params[]) return cmd_refreshattachedobject(playerid, params);

CMD:saveattachedobject(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			if(sscanf(params,"dS()[25]S()[65]", AOSlot, AOFileName, AOComment)) AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_ALL, AOE_D_SAVE_SLOT, AOE_T_SAVE, AOE_B_SELECT, AOE_B_BACK);
			else
			{
				if(AOSlot == MAX_PLAYER_ATTACHED_OBJECTS)
				{
					format(params, sizeof AOE_STR, "%s %s", AOFileName, AOComment);
					cmd_saveallattachedobjects(playerid, params);
				}
				else
				{
					if(AOE_EnteredValidSlot(playerid, AOSlot))
					{
						if(AOE_HasSlot(playerid, AOSlot))
						{
							EPV[playerid][PAO_INDEX1] = AOSlot;
							if(isnull(AOFileName)) AOE_ShowPlayerDialog(playerid, AOE_C_SAVE, AOE_D_SAVE, AOE_T_SAVE, AOE_B_SAVE, AOE_B_SELECT_INDEX);
							else
							{
								if(AOE_EnteredValidFileName(playerid, AOFileName))
								{
									strupdate(EPV[playerid][PAO_NAME], AOFileName);
									format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, AOFileName);
									if(AOE_EnteredNonExistFileName(playerid, AOFileName))
									{
										SendClientMessage(playerid, AOE_COLOR5, AOE_M_SAVING);
										if(!IsValidComment(AOComment) && !isnull(AOComment))
										{
											SendClientMessage(playerid, AOE_COLOR4, AOE_M_COMMENT_INVALID);
											AOComment[0] = EOS;
											SendClientMessage(playerid, AOE_COLOR4, AOE_M_COMMENT_INFO);
										}
										if(AOE_SavePlayerAttachedObject(playerid, AOFileName, AOSlot, AOComment, AOFileLen))
										{
											format(AOE_STR, sizeof AOE_STR, "* Your attached object from index %d has been saved as \"{FFFFFF}%s{%06x}\".", AOSlot, EPV[playerid][PAO_NAME], AOE_COLOR2 >>> 8);
											SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
											format(AOE_STR, sizeof AOE_STR, "** Model: %d ~ Bone: %s (%d) ~ For skin: %d ~ File size: %.2f KB.",
											PAO[playerid][AOSlot][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[playerid][AOSlot][AO_BONE_ID]), PAO[playerid][AOSlot][AO_BONE_ID], GetPlayerSkin(playerid), AOFileLen);
											SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
											if(!isnull(AOComment))
											{
												format(AOE_STR, sizeof AOE_STR, "** Comment: %s.", AOComment);
												SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
											}
											format(AOE_STR, sizeof AOE_STR, "~b~~h~Attached object file saved~n~%s", EPV[playerid][PAO_NAME]);
											AOE_GameTextForPlayer(playerid, AOE_STR);
										}
										else
										{
											SendClientMessage(playerid, AOE_COLOR1, AOE_M_SAVE_FAILED);
											AOE_GameTextForPlayer(playerid, AOE_G_INVALID_DATA);
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:sao(playerid, params[]) return cmd_saveattachedobject(playerid, params);

CMD:saveallattachedobjects(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			if(sscanf(params, "s[25]S()[65]", AOFileName, AOComment)) AOE_ShowPlayerDialog(playerid, AOE_C_SAVE, AOE_D_SAVE2, AOE_T_SAVE_SET, AOE_B_SAVE, AOE_B_BACK);
			else
			{
				if(AOE_EnteredValidFileName(playerid, AOFileName))
				{
					strupdate(EPV[playerid][PAO_NAME], AOFileName);
					format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, AOFileName);
					if(AOE_EnteredNonExistFileName2(playerid, AOFileName))
					{
						SendClientMessage(playerid, AOE_COLOR5, AOE_M_SAVING_SET);
						if(!IsValidComment(AOComment) && !isnull(AOComment))
						{
							SendClientMessage(playerid, AOE_COLOR4, AOE_M_COMMENT_INVALID);
							AOComment[0] = EOS;
							SendClientMessage(playerid, AOE_COLOR4, AOE_M_COMMENT_INFO);
						}
						new slots = AOE_SavePlayerAttachedObject(playerid, AOFileName, MAX_PLAYER_ATTACHED_OBJECTS, AOComment, AOFileLen);
						if(slots)
						{
							format(AOE_STR, sizeof AOE_STR, "* Your attached object set has been saved as \"{FFFFFF}%s{%06x}\".", EPV[playerid][PAO_NAME], AOE_COLOR2 >>> 8);
							SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "** Slots saved: %d ~ For skin: %d ~ File size: %.2f KB.", slots, GetPlayerSkin(playerid), AOFileLen);
							SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
							if(!isnull(AOComment))
							{
								format(AOE_STR, sizeof AOE_STR, "** Comment: %s.", AOComment);
								SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
							}
							format(AOE_STR, sizeof AOE_STR, "~g~~h~Attached object(s) file saved~n~%s", EPV[playerid][PAO_NAME]);
							AOE_GameTextForPlayer(playerid, AOE_STR);
						}
						else SendClientMessage(playerid, AOE_COLOR1, AOE_M_SAVE_FAILED);
					}
				}
			}
		}
	}
	return 1;
}

CMD:saao(playerid, params[]) return cmd_saveallattachedobjects(playerid, params);

CMD:loadattachedobject(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasFreeSlot(playerid))
		{
			if(sscanf(params, "s[25]D(-1)", AOFileName, AOSlot)) AOE_ShowPlayerDialog(playerid, AOE_C_LOAD, AOE_D_LOAD, AOE_T_LOAD, AOE_B_ENTER, AOE_B_BACK);
			else
			{
				if(AOE_EnteredValidFileName(playerid, AOFileName))
				{
					strupdate(EPV[playerid][PAO_NAME], AOFileName);
					format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, EPV[playerid][PAO_NAME]);
					if(AOE_EnteredExistedFileName(playerid, AOFileName))
					{
						if(AOSlot == -1) AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_LOAD_SLOT, AOE_T_LOAD, AOE_B_LOAD, AOE_B_BACK);
						else
						{
							if(AOE_EnteredValidSlot(playerid, AOSlot))
							{
								EPV[playerid][PAO_INDEX1] = AOSlot;
								if(IsPlayerAttachedObjectSlotUsed(playerid, AOSlot)) AOE_ShowPlayerDialog(playerid, AOE_C_LOAD_REPLACE, AOE_D_LOAD_REPLACE, AOE_T_LOAD#AOE_T_REPLACE, AOE_B_YES, AOE_B_BACK);
								else
								{
									SendClientMessage(playerid, AOE_COLOR5, AOE_M_LOADING);
									if(AOE_LoadPlayerAttachedObject(playerid, AOFileName, AOSlot, AOComment))
									{
										format(AOE_STR, sizeof AOE_STR, "* You've loaded attached object from file \"{FFFFFF}%s{%06x}\" at index number %d.", EPV[playerid][PAO_NAME], AOE_COLOR2 >>> 8, AOSlot);
										SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
										if(!isnull(AOComment))
										{
											format(AOE_STR, sizeof AOE_STR, "** Comment: %s.", AOComment);
											SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
										}
										format(AOE_STR, sizeof AOE_STR, "~g~~h~Attached object file loaded~n~%s", EPV[playerid][PAO_NAME]);
										AOE_GameTextForPlayer(playerid, AOE_STR);
									}
									else
									{
										format(AOE_STR, sizeof AOE_STR, "* Sorry, there is no valid attached object data found from file \"%s\" at index number %d.", EPV[playerid][PAO_NAME], AOSlot);
										SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
										AOE_GameTextForPlayer(playerid, AOE_G_INVALID_DATA);
										AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_LOAD_SLOT, AOE_T_LOAD, AOE_B_LOAD, AOE_B_BACK);
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:lao(playerid, params[]) return cmd_loadattachedobject(playerid, params);

CMD:loadattachedobjects(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasFreeSlot(playerid))
		{
			if(sscanf(params, "s[25]", AOFileName)) AOE_ShowPlayerDialog(playerid, AOE_C_LOAD, AOE_D_LOAD2, AOE_T_LOAD_SET, AOE_B_LOAD, AOE_B_BACK);
			else
			{
				if(AOE_EnteredValidFileName(playerid, AOFileName))
				{
					strupdate(EPV[playerid][PAO_NAME], AOFileName);
					format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, AOFileName);
					if(AOE_EnteredExistedFileName(playerid, AOFileName))
					{
						SendClientMessage(playerid, AOE_COLOR3, AOE_M_LOADING_SET);
						new slots = AOE_LoadPlayerAttachedObject(playerid, AOFileName, MAX_PLAYER_ATTACHED_OBJECTS, AOComment);
						if(slots)
						{
							format(AOE_STR, sizeof AOE_STR, "* You've loaded %d attached object(s) from file \"{FFFFFF}%s{%06x}\".", slots, EPV[playerid][PAO_NAME], AOE_COLOR2 >>> 8);
							SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
							if(!isnull(AOComment))
							{
								format(AOE_STR, sizeof AOE_STR, "** Comment: %s.", AOComment);
								SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
							}
							format(AOE_STR, sizeof AOE_STR, "~g~~h~Attached object(s) file loaded~n~%s", EPV[playerid][PAO_NAME]);
							AOE_GameTextForPlayer(playerid, AOE_STR);
						}
						else
						{
							format(AOE_STR, sizeof AOE_STR, "* Sorry, there is no valid attached object data found from file \"%s\".", EPV[playerid][PAO_NAME]);
							SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
							AOE_GameTextForPlayer(playerid, AOE_G_INVALID_DATA);
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:laos(playerid, params[]) return cmd_loadattachedobjects(playerid, params);

CMD:deleteattachedobjectfile(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "s[25]", AOFileName)) AOE_ShowPlayerDialog(playerid, AOE_C_DELETE, AOE_D_DELETE, AOE_T_DELETE, AOE_B_DELETE, AOE_B_CANCEL);
		else
		{
			if(AOE_EnteredValidFileName(playerid, AOFileName))
			{
				format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, AOFileName);
				if(fexist(AOFileName))
				{
					SendClientMessage(playerid, AOE_COLOR1, AOE_M_DELETING);
					if(fremove(AOFileName))
					{
						format(AOE_STR, sizeof AOE_STR, "* You've deleted attached object(s) file \"{CCFFFF}%s{%06x}\".", AOFileName, AOE_COLOR1 >>> 8);
						AOE_GameTextForPlayer(playerid, AOE_G_FILE_DELETED);
					}
					else format(AOE_STR, sizeof AOE_STR, "* Failed to delete attached object(s) file \"{CCFFFF}%s{%06x}\"", AOFileName, AOE_COLOR1 >>> 8);
					SendClientMessage(playerid, AOE_COLOR1, AOE_STR);
				}
				else
				{
					format(AOE_STR, sizeof AOE_STR, "* Sorry, attached object(s) file \"{FFFFFF}%s{%06x}\" does not exist.", AOFileName, AOE_COLOR4 >>> 8);
					SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
					AOE_GameTextForPlayer(playerid, AOE_G_FILE_NOT_EXIST);
				}
			}
		}
	}
	else SendClientMessage(playerid, AOE_COLOR4, AOE_M_DELETE_ADMIN_ONLY);
	return 1;
}

CMD:daof(playerid, params[]) return cmd_deleteattachedobjectfile(playerid, params);

CMD:resetattachedobjecteditor(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "uD(-1)", AOTarget, AOSlot))
		{
			SendClientMessage(playerid, AOE_COLOR4, AOE_M_RESET_USAGE);
			SendClientMessage(playerid, AOE_COLOR0, AOE_M_RESET_INFO);
		}
		else
		{
			if(AOTarget == INVALID_PLAYER_ID) SendClientMessage(playerid, AOE_COLOR4, AOE_M_TARGET_NOT_ONLINE);
			else
			{
				if(0 <= AOSlot <= MAX_PLAYER_ATTACHED_OBJECTS)
				{
					RemovePlayerAttachedObjectEx(AOTarget, AOSlot);
					if(AOSlot == MAX_PLAYER_ATTACHED_OBJECTS)
					{
						for(new x = 0; x < MAX_PLAYER_ATTACHED_OBJECTS; x++)
							AOE_UnsetValues(AOTarget, x);
					}
					else AOE_UnsetValues(AOTarget, AOSlot);
				}
				ShowPlayerDialog(AOTarget, -1, DIALOG_STYLE_MSGBOX, "", "", "", "");
				AOE_UnsetVars(AOTarget);
				format(AOE_STR, sizeof AOE_STR, "* Player's (ID:%d) attached object editor variable(s) has been reset!", AOTarget);
				SendClientMessage(playerid, AOE_COLOR1, AOE_STR);
			}
		}
	}
	else SendClientMessage(playerid, AOE_COLOR4, AOE_M_RESET_ADMIN_ONLY);
	return 1;
}
CMD:raoepv(playerid, params[]) return cmd_resetattachedobjecteditor(playerid, params);

CMD:attachedobjectproperties(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(sscanf(params, "dU(-1)", AOSlot, AOTarget))
		{
			SendClientMessage(playerid, AOE_COLOR4, AOE_M_PROPERTIES_USAGE);
			SendClientMessage(playerid, AOE_COLOR0, AOE_M_PROPERTIES_INFO);
		}
		else
		{
			if(AOE_EnteredValidSlot(playerid, AOSlot))
			{
				if(AOTarget == -1) AOTarget = playerid;
				if(AOTarget == INVALID_PLAYER_ID) SendClientMessage(playerid, AOE_COLOR4, AOE_M_TARGET_NOT_ONLINE);
				else
				{
					EPV[playerid][PAO_TARGET] = AOTarget;
					GetPlayerName(AOTarget, pName, sizeof pName);
					if(0 < GetPlayerAttachedObjectsCount(AOTarget) <= MAX_PLAYER_ATTACHED_OBJECTS)
					{
						if(IsPlayerAttachedObjectSlotUsed(AOTarget, AOSlot))
						{
							EPV[playerid][PAO_INDEX1] = AOSlot;
							if(AOTarget == playerid) format(AOE_STR, sizeof AOE_STR, "Your Attached Object Properties (%d)", AOSlot);
							else format(AOE_STR, sizeof AOE_STR, "%s's Attached Object Properties (%d)", pName, AOSlot);
							AOE_ShowPlayerDialog(playerid, AOE_C_PROPERTIES, AOE_D_PROPERTIES, AOE_STR, AOE_B_PRINT, AOE_B_CLOSE);
						}
						else
						{
							if(AOTarget == playerid) format(AOE_STR, sizeof AOE_STR, "* Sorry, you have no attached object at index number %d.", AOSlot);
							else format(AOE_STR, sizeof AOE_STR, "* Sorry, %s has no attached object at index number %d.", pName, AOSlot);
							SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "~r~~h~Unknown attached object~n~~w~index number: %d.", AOSlot);
							AOE_GameTextForPlayer(playerid, AOE_STR);
						}
					}
					else
					{
						if(AOTarget == playerid)
						{
							SendClientMessage(playerid, AOE_COLOR4, AOE_M_NO_ATTACHED_OBJECT);
							AOE_GameTextForPlayer(playerid, AOE_G_NO_ATTACHED_OBJECT);
						}
						else
						{
							format(AOE_STR, sizeof AOE_STR, "* Sorry, %s has no attached object.", pName);
							SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "~r~~h~%s has no attached object", pName);
							AOE_GameTextForPlayer(playerid, AOE_STR);
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:aop(playerid, params[]) return cmd_attachedobjectproperties(playerid, params);
CMD:attachedobjectstatus(playerid, params[]) return cmd_attachedobjectproperties(playerid, params);
CMD:aos(playerid, params[]) return cmd_attachedobjectproperties(playerid, params);

CMD:duplicateattachedobject(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			new slot2;
			if(sscanf(params, "dD(-1)", AOSlot, slot2))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_DUPLICATE_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_DUPLICATE_INFO);
			}
			else
			{
				if(IsValidAttachedObjectSlot(AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						if(slot2 == -1) AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_DUPLICATE_SLOT, AOE_T_DUPLICATE, AOE_B_DUPLICATE, AOE_B_BACK);
						else
						{
							if(IsValidAttachedObjectSlot(slot2))
							{
								EPV[playerid][PAO_INDEX2] = slot2;
								if(slot2 == AOSlot)
								{
									format(AOE_STR, sizeof AOE_STR, "* Sorry, you cannot duplicate your attached object from slot %d to the same slot (%d) as it's already there?!", AOSlot, slot2);
									SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
									AOE_GameTextForPlayer(playerid, AOE_G_DOH);
								}
								else
								{
									if(IsPlayerAttachedObjectSlotUsed(playerid, slot2)) AOE_ShowPlayerDialog(playerid, AOE_C_DUPLICATE_REPLACE, AOE_D_DUPLICATE_REPLACE, AOE_T_DUPLICATE#AOE_T_REPLACE, AOE_B_DUPLICATE, AOE_B_SELECT_INDEX);
									else
									{
										if(DuplicatePlayerAttachedObject(playerid, AOSlot, slot2))
										{
											format(AOE_STR, sizeof AOE_STR, "* Duplicated your attached object from slot %d to %d.", AOSlot, slot2);
											SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
											format(AOE_STR, sizeof AOE_STR, "~g~Attached object duplicated~n~~w~index number:~n~%d to %d", AOSlot, slot2);
											AOE_GameTextForPlayer(playerid, AOE_STR);
										}
										else SendClientMessage(playerid, AOE_COLOR1, AOE_M_DUPLICATE_FAIL);
									}
								}
							}
							else
							{
								format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object index #2 number (%d).", slot2);
								SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
								AOE_GameTextForPlayer(playerid, AOE_G_INVALID_SLOT);
							}
						}
					}
				}
				else
				{
					format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object index #1 number (%d).", AOSlot);
					SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
					AOE_GameTextForPlayer(playerid, AOE_G_INVALID_SLOT);
				}
			}
		}
	}
	return 1;
}

CMD:dao(playerid, params[]) return cmd_duplicateattachedobject(playerid, params);

CMD:setattachedobjectindex(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			new AOSlot2;
			if(sscanf(params, "dD(-1)", AOSlot, AOSlot2))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_SLOT_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_SLOT_INFO);
			}
			else
			{
				if(IsValidAttachedObjectSlot(AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						if(AOSlot2 == -1) AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_SET_SLOT, AOE_T_SET_INDEX, AOE_B_SET, AOE_B_BACK);
						else
						{
							if(IsValidAttachedObjectSlot(AOSlot2))
							{
								if(AOSlot2 == AOSlot)
								{
									format(AOE_STR, sizeof AOE_STR, "* Sorry, you can't move your attached object from slot %d to the same slot (%d) as it's already there?!", AOSlot, AOSlot2);
									SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
									AOE_GameTextForPlayer(playerid, AOE_G_DOH);
								}
								else
								{
									EPV[playerid][PAO_INDEX2] = AOSlot2;
									if(IsPlayerAttachedObjectSlotUsed(playerid, AOSlot2)) AOE_ShowPlayerDialog(playerid, AOE_C_SET_INDEX_REPLACE, AOE_D_SET_SLOT_REPLACE, AOE_T_SET_INDEX#AOE_T_REPLACE, AOE_B_YES, AOE_B_SELECT_INDEX);
									else
									{
										if(ChangePlayerAttachedObjectIndex(playerid, AOSlot, AOSlot2))
										{
											format(AOE_STR, sizeof AOE_STR, "* Moved your attached object from slot %d to {FFFFFF}%d{%06x}.", AOSlot, AOSlot2, AOE_COLOR2 >>> 8);
											SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
											format(AOE_STR, sizeof AOE_STR, "~g~Attached object moved~n~~w~index number:~n~%d to %d", AOSlot, AOSlot2);
											AOE_GameTextForPlayer(playerid, AOE_STR);
										}
										else SendClientMessage(playerid, AOE_COLOR1, AOE_M_SET_SLOT_FAIL);
									}
								}
							}
							else
							{
								format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object new index number ({FFFFFF}%d{%06x}).", AOSlot2, AOE_COLOR4 >>> 8);
								SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
								AOE_GameTextForPlayer(playerid, AOE_G_INVALID_SLOT);
							}
						}
					}
				}
				else
				{
					format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object old index number ({FFFFFF}%d{%06x}).", AOSlot, AOE_COLOR4 >>> 8);
					SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
					AOE_GameTextForPlayer(playerid, AOE_G_INVALID_SLOT);
				}
			}
		}
	}
	return 1;
}

CMD:setattachedobjectslot(playerid, params[]) return cmd_setattachedobjectindex(playerid, params);

CMD:saoi(playerid, params[]) return cmd_setattachedobjectindex(playerid, params);

CMD:setattachedobjectmodel(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			if(sscanf(params, "dD(-1)", AOSlot, AOModel))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_MODEL_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_MODEL_INFO);
			}
			else
			{
				if(AOE_EnteredValidSlot(playerid, AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						if(AOModel == -1) AOE_ShowPlayerDialog(playerid, AOE_C_MODEL, AOE_D_SET_MODEL, AOE_T_SET_MODEL, AOE_B_SET, AOE_B_BACK);
						else
						{
							if(AOE_EnteredValidModel(playerid, AOModel))
							{
								EPV[playerid][PAO_MODEL_ID] = AOModel;
								if(AOModel == PAO[playerid][AOSlot][AO_MODEL_ID])
								{
									format(AOE_STR, sizeof AOE_STR, "* Sorry, you cannot change this attached object index %d model from %d to the same model (%d)!!", AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], AOModel);
									SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
									AOE_GameTextForPlayer(playerid, AOE_G_DOH);
								}
								else
								{
									if(UpdatePlayerAttachedObject(playerid, AOSlot, AOModel, PAO[playerid][AOSlot][AO_BONE_ID]))
									{
										format(AOE_STR, sizeof AOE_STR, "* Updated your attached object index %d model to {FFFFFF}%d{%06x}.", AOSlot, AOModel, AOE_COLOR2 >>> 8);
										SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
										format(AOE_STR, sizeof AOE_STR, "~g~Attached object model updated~n~~w~%d (ID:%d)", AOModel, AOSlot);
										AOE_GameTextForPlayer(playerid, AOE_STR);
									}
									else SendClientMessage(playerid, AOE_COLOR1, AOE_M_SET_MODEL_FAIL);
								}
							}
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:saom(playerid, params[]) return cmd_setattachedobjectmodel(playerid, params);

CMD:setattachedobjectbone(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			new bonename[MAX_ATTACHED_OBJECT_BONE_NAME];
			if(sscanf(params, "dS()[16]", AOSlot, bonename))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_BONE_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_BONE_INFO);
			}
			else
			{
				if(AOE_EnteredValidSlot(playerid, AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						if(isnull(bonename)) AOE_ShowPlayerDialog(playerid, AOE_C_BONE, AOE_D_SET_BONE, AOE_T_SET_BONE, AOE_B_SET, AOE_B_BACK);
						else
						{
							if(AOE_EnteredValidBone(playerid, bonename))
							{
								AOBone = GetAttachedObjectBone(bonename);
								EPV[playerid][PAO_BONE_ID] = AOBone;
								if(AOBone == PAO[playerid][AOSlot][AO_BONE_ID])
								{
									format(AOE_STR, sizeof AOE_STR, "* Sorry, you cannot change this attached object index %d bone from %s to the same bone (%d)!!", AOSlot, bonename, PAO[playerid][AOSlot][AO_BONE_ID]);
									SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
									AOE_GameTextForPlayer(playerid, AOE_G_DOH);
								}
								else
								{
									if(UpdatePlayerAttachedObject(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], AOBone))
									{
										if(IsNumeric(bonename)) bonename = GetAttachedObjectBoneName(AOBone);
										format(AOE_STR, sizeof AOE_STR, "* Updated your attached object index %d bone to {FFFFFF}%d{%06x} (%s).", AOSlot, AOBone, AOE_COLOR2 >>> 8, bonename);
										SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
										format(AOE_STR, sizeof AOE_STR, "~g~Attached object bone updated~n~~w~%d (ID:%d)", AOBone, AOSlot);
										AOE_GameTextForPlayer(playerid, AOE_STR);
									}
									else SendClientMessage(playerid, AOE_COLOR1, AOE_M_ERROR);
								}
							}
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:saob(playerid, params[]) return cmd_setattachedobjectbone(playerid, params);

CMD:setattachedobjectoffset(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			if(sscanf(params, "dcf", AOSlot, AOSelection, AOAxis))
			{
				ErrorMessage:
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_OFFSET_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_OFFSET_INFO);
			}
			else
			{
				if(AOE_EnteredValidSlot(playerid, AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						if(IsPlayerAdmin(playerid) || MIN_ATTACHED_OBJECT_OFFSET <= AOAxis <= MAX_ATTACHED_OBJECT_OFFSET)
						{
							switch(AOSelection)
							{
								case 'x', 'X': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], AOAxis, PAO[playerid][AOSlot][AO_Y], PAO[playerid][AOSlot][AO_Z],
												PAO[playerid][AOSlot][AO_RX], PAO[playerid][AOSlot][AO_RY], PAO[playerid][AOSlot][AO_RZ], PAO[playerid][AOSlot][AO_SX], PAO[playerid][AOSlot][AO_SY], PAO[playerid][AOSlot][AO_SZ],
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
								case 'y', 'Y': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], AOAxis, PAO[playerid][AOSlot][AO_Z],
												PAO[playerid][AOSlot][AO_RX], PAO[playerid][AOSlot][AO_RY], PAO[playerid][AOSlot][AO_RZ], PAO[playerid][AOSlot][AO_SX], PAO[playerid][AOSlot][AO_SY], PAO[playerid][AOSlot][AO_SZ],
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
								case 'z', 'Z': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], PAO[playerid][AOSlot][AO_Y], AOAxis,
												PAO[playerid][AOSlot][AO_RX], PAO[playerid][AOSlot][AO_RY], PAO[playerid][AOSlot][AO_RZ], PAO[playerid][AOSlot][AO_SX], PAO[playerid][AOSlot][AO_SY], PAO[playerid][AOSlot][AO_SZ],
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
								default: goto ErrorMessage;
							}
							format(AOE_STR, sizeof AOE_STR, "* Updated your attached object index %d position (Offset%c) to {FFFFFF}%.4f{%06x}.", AOSlot, toupper(AOSelection), AOAxis, AOE_COLOR2 >>> 8);
							SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
							AOE_GameTextForPlayer(playerid, AOE_G_OFFSET_UPDATED);
						}
						else
						{
							format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object offset(%c) value ({FFFFFF}%f{%06x}).", toupper(AOSelection), AOAxis, AOE_COLOR4 >>> 8);
							SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
							SendClientMessage(playerid, AOE_COLOR4, AOE_M_VALID_OFFSET);
							AOE_GameTextForPlayer(playerid, AOE_G_INVALID_OFFSET);
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:saoo(playerid, params[]) return cmd_setattachedobjectoffset(playerid, params);

CMD:setattachedobjectrot(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			if(sscanf(params, "dcf", AOSlot, AOSelection, AOAxis))
			{
				ErrorMessage:
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_ROTATION_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_ROTATION_INFO);
			}
			else
			{
				if(AOE_EnteredValidSlot(playerid, AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						if(IsPlayerAdmin(playerid) || MIN_ATTACHED_OBJECT_ROTATION <= AOAxis <= MAX_ATTACHED_OBJECT_ROTATION)
						{
							switch(AOSelection)
							{
								case 'x', 'X': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], PAO[playerid][AOSlot][AO_Y], PAO[playerid][AOSlot][AO_Z],
												AOAxis, PAO[playerid][AOSlot][AO_RY], PAO[playerid][AOSlot][AO_RZ], PAO[playerid][AOSlot][AO_SX], PAO[playerid][AOSlot][AO_SY], PAO[playerid][AOSlot][AO_SZ],
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
								case 'y', 'Y': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], PAO[playerid][AOSlot][AO_Y], PAO[playerid][AOSlot][AO_Z],
												PAO[playerid][AOSlot][AO_RX], AOAxis, PAO[playerid][AOSlot][AO_RZ], PAO[playerid][AOSlot][AO_SX], PAO[playerid][AOSlot][AO_SY], PAO[playerid][AOSlot][AO_SZ],
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
								case 'z', 'Z': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], PAO[playerid][AOSlot][AO_Y], PAO[playerid][AOSlot][AO_Z],
												PAO[playerid][AOSlot][AO_RX], PAO[playerid][AOSlot][AO_RY], AOAxis, PAO[playerid][AOSlot][AO_SX], PAO[playerid][AOSlot][AO_SY],PAO[playerid][AOSlot][AO_SZ],
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
								default: goto ErrorMessage;
							}
							format(AOE_STR, sizeof AOE_STR, "* Updated your attached object index %d rotation (Rot%c) to {FFFFFF}%.4f{%06x}.", AOSlot, toupper(AOSelection), AOAxis, AOE_COLOR2 >>> 8);
							SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
							AOE_GameTextForPlayer(playerid, AOE_G_ROTATION_UPDATED);
						}
						else
						{
							format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered an invalid attached object rotation(%c) value ({FFFFFF}%f{%06x}).", toupper(AOSelection), AOAxis, AOE_COLOR4 >>> 8);
							SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
							SendClientMessage(playerid, AOE_COLOR4, AOE_M_VALID_ROTATION);
							AOE_GameTextForPlayer(playerid, AOE_G_INVALID_ROTATION);
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:saor(playerid, params[]) return cmd_setattachedobjectrot(playerid, params);

CMD:setattachedobjectscale(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			if(sscanf(params, "dcf", AOSlot, AOSelection, AOAxis))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_SCALE_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_SCALE_INFO);
			}
			else
			{
				if(AOE_EnteredValidSlot(playerid, AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						if(IsPlayerAdmin(playerid) || MIN_ATTACHED_OBJECT_SIZE <= AOAxis <= MAX_ATTACHED_OBJECT_SIZE)
						{
							switch(AOSelection)
							{
								case 'x', 'X': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], PAO[playerid][AOSlot][AO_Y], PAO[playerid][AOSlot][AO_Z],
												PAO[playerid][AOSlot][AO_RX], PAO[playerid][AOSlot][AO_RY], PAO[playerid][AOSlot][AO_RZ], AOAxis, PAO[playerid][AOSlot][AO_SY], PAO[playerid][AOSlot][AO_SZ],
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
								case 'y', 'Y': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], PAO[playerid][AOSlot][AO_Y], PAO[playerid][AOSlot][AO_Z],
												PAO[playerid][AOSlot][AO_RX], PAO[playerid][AOSlot][AO_RY], PAO[playerid][AOSlot][AO_RZ], PAO[playerid][AOSlot][AO_SX], AOAxis, PAO[playerid][AOSlot][AO_SZ],
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
								case 'z', 'Z': UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], PAO[playerid][AOSlot][AO_Y], PAO[playerid][AOSlot][AO_Z],
												PAO[playerid][AOSlot][AO_RX], PAO[playerid][AOSlot][AO_RY], PAO[playerid][AOSlot][AO_RZ], PAO[playerid][AOSlot][AO_SX], PAO[playerid][AOSlot][AO_SY], AOAxis,
												PAO[playerid][AOSlot][AO_MC1], PAO[playerid][AOSlot][AO_MC2]);
							}
							format(AOE_STR, sizeof AOE_STR, "* Updated your attached object index %d size (Scale%c) to {FFFFFF}%.4f{%06x}.", AOSlot, toupper(AOSelection), AOAxis, AOE_COLOR2 >>> 8);
							SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
							AOE_GameTextForPlayer(playerid, AOE_G_SCALE_UPDATED);
						}
						else
						{
							format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object scale(%c) value ({FFFFFF}%f{%06x}).", toupper(AOSelection), AOAxis, AOE_COLOR4 >>> 8);
							SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
							SendClientMessage(playerid, AOE_COLOR4, AOE_M_VALID_SCALE);
							AOE_GameTextForPlayer(playerid, AOE_G_INVALID_SCALE);
						}
					}
				}
			}
		}
	}
	return 1;
}

CMD:saos(playerid, params[]) return cmd_setattachedobjectscale(playerid, params);

CMD:setattachedobjectmc(playerid, params[])
{
	if(AOE_CanEdit(playerid))
	{
		if(AOE_HasAttachedObject(playerid))
		{
			new hex:MC2;
			if(sscanf(params, "dxx", AOSlot, AOMC, MC2))
			{
				SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_COLOR_USAGE);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_COLOR_INFO);
			}
			else
			{
				if(AOE_EnteredValidSlot(playerid, AOSlot))
				{
					if(AOE_HasSlot(playerid, AOSlot))
					{
						EPV[playerid][PAO_INDEX1] = AOSlot;
						if(AOMC != PAO[playerid][AOSlot][AO_MC1])
						{
							format(AOE_STR, sizeof AOE_STR, "* Updated your attached object index %d color #1 to {%06x}0x%x{%06x} (%i).", AOSlot, AOMC & 0xFFFFFF, AOMC, AOE_COLOR2 >>> 8, AOMC);
							SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
						}
						if(MC2 != PAO[playerid][AOSlot][AO_MC2])
						{
							format(AOE_STR, sizeof AOE_STR, "* Updated your attached object index %d color #2 to {%06x}0x%x{%06x} (%i).", AOSlot, MC2 & 0xFFFFFF, MC2, AOE_COLOR2 >>> 8, MC2);
							SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
						}
						if(UpdatePlayerAttachedObjectEx(playerid, AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID], PAO[playerid][AOSlot][AO_BONE_ID], PAO[playerid][AOSlot][AO_X], PAO[playerid][AOSlot][AO_Y], PAO[playerid][AOSlot][AO_Z],
							PAO[playerid][AOSlot][AO_RX], PAO[playerid][AOSlot][AO_RY], PAO[playerid][AOSlot][AO_RZ], PAO[playerid][AOSlot][AO_SX], PAO[playerid][AOSlot][AO_SY], PAO[playerid][AOSlot][AO_SZ], AOMC, MC2))
						{
							AOE_GameTextForPlayer(playerid, AOE_G_COLOR_UPDATED);
						}
						else SendClientMessage(playerid, AOE_COLOR1, AOE_M_ERROR);
					}
				}
			}
		}
	}
	return 1;
}

CMD:saomc(playerid, params[]) return cmd_setattachedobjectmc(playerid, params);

CMD:setattachedobjectmc1(playerid, params[])
{
	if(sscanf(params, "dx", AOSlot, AOMC))
	{
		SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_COLOR1_USAGE);
		SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_COLOR1_INFO);
		return 1;
	}
	format(params, sizeof AOE_STR, "%d %x %x", AOSlot, AOMC, PAO[playerid][AOSlot][AO_MC2]);
	return cmd_setattachedobjectmc(playerid, params);
}

CMD:saomc1(playerid, params[]) return cmd_setattachedobjectmc1(playerid, params);

CMD:setattachedobjectmc2(playerid, params[])
{
	if(sscanf(params, "dx", AOSlot, AOMC))
	{
		SendClientMessage(playerid, AOE_COLOR4, AOE_M_SET_COLOR2_USAGE);
		SendClientMessage(playerid, AOE_COLOR0, AOE_M_SET_COLOR2_INFO);
		return 1;
	}
	format(params, sizeof AOE_STR, "%d %x %x", AOSlot, PAO[playerid][AOSlot][AO_MC1], AOMC);
	return cmd_setattachedobjectmc(playerid, params);
}

CMD:saomc2(playerid, params[]) return cmd_setattachedobjectmc2(playerid, params);
//------------------------------------------------------------------------------
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new slots;
	switch(dialogid)
	{
		case AOE_D:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: cmd_createattachedobject(playerid, "");
					case 1: AOE_ShowPlayerDialog(playerid, AOE_C_FILE, AOE_D_FILE, AOE_T_FILE, AOE_B_SELECT, AOE_B_CANCEL);
					case 2:
					{
						if(GetPlayerAttachedObjectsCount(playerid) == 0)
						{
							SendClientMessage(playerid, AOE_COLOR4, AOE_M_EDIT_NOTHING);
							AOE_GameTextForPlayer(playerid, AOE_G_NO_ATTACHED_OBJECT);
						}
						else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_USED, AOE_D_EDIT_SLOT, AOE_T_EDIT, AOE_B_EDIT_CREATE, AOE_B_CANCEL);
					}
					case 3: cmd_removeattachedobjects(playerid, "");
					case 4: cmd_undeleteattachedobject(playerid, "");
					case 5:
					{
						if(IsPlayerAdmin(playerid))
						{
							SendClientMessage(playerid, AOE_COLOR5, "-- Statistics & Debug ----------------------------------------------------");
							SendClientMessage(playerid, AOE_COLOR3, "- Offset value limit: "#MIN_ATTACHED_OBJECT_OFFSET" to "#MAX_ATTACHED_OBJECT_OFFSET);
							SendClientMessage(playerid, AOE_COLOR3, "- Rotation value limit: "#MIN_ATTACHED_OBJECT_ROTATION" to "#MAX_ATTACHED_OBJECT_ROTATION);
							SendClientMessage(playerid, AOE_COLOR3, "- Scale value limit: "#MIN_ATTACHED_OBJECT_SIZE" to "#MAX_ATTACHED_OBJECT_SIZE);
							strupdate(AOE_STR, AOE_FILE_NAME);
							strdel(AOE_STR, 0, 2);
							format(AOE_STR, sizeof AOE_STR, "- File format: %s", AOE_STR);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							SendClientMessage(playerid, AOE_COLOR3, "- Smaller save size: "#AOE_SMALLER_SAVE);
							format(AOE_STR, sizeof AOE_STR, "- Last attached object file name: %s", AOFileName);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last saved attached object file length: %f", AOFileLen);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last attached object file comment: %s", AOComment);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last editor player name: %s", pName);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last editor target id: %d", AOTarget);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last selection edit: %d", AOSelection);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last attached object slot: %d", AOSlot);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last attached object model: %d", AOModel);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last attached object bone: %d", AOBone);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last attached object xyz axis value: %f", AOAxis);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
							format(AOE_STR, sizeof AOE_STR, "- Last attached object material color: %x (%i)", AOMC, AOMC);
							SendClientMessage(playerid, AOE_COLOR3, AOE_STR);
						}
						else
						{
							SendClientMessage(playerid, AOE_COLOR5, "-- Statistics --------------------------------------------------------------");
						}
						new maxplayers = GetMaxPlayers(), attachedobjectscount, attachedobjectscount2;
						if(maxplayers > MAX_PLAYERS) maxplayers = MAX_PLAYERS;
						for(new i = 0; i < maxplayers; i++)
						{
							if(IsPlayerConnected(i))
							{
								for(new x = 0; x < MAX_PLAYER_ATTACHED_OBJECTS; x++)
								{
									attachedobjectscount += IsPlayerAttachedObjectSlotUsed(i, x);
									if(PAO[i][x][AO_STATUS] == 1) attachedobjectscount2++;
								}
							}
						}
						format(AOE_STR, sizeof AOE_STR, "- Total attached object(s) in the server: %d (%d by editor)", attachedobjectscount, attachedobjectscount2);
						SendClientMessage(playerid, AOE_COLOR5, AOE_STR);
						format(AOE_STR, sizeof AOE_STR, "- Total attached object(s) attached on you: %d", GetPlayerAttachedObjectsCount(playerid));
						SendClientMessage(playerid, AOE_COLOR5, AOE_STR);
						SendClientMessage(playerid, AOE_COLOR5, "--------------------------------------------------------------------------------");
					}
					case 6: AOE_ShowPlayerDialog(playerid, AOE_C_HELP, AOE_D, AOE_T_HELP, AOE_B_CLOSE);
					case 7: AOE_ShowPlayerDialog(playerid, AOE_C_ABOUT, AOE_D, AOE_T_ABOUT, AOE_B_CLOSE);
				}
			}
			else SendClientMessage(playerid, AOE_COLOR0, AOE_M_DIALOG_CLOSE);
		}
		case AOE_D_CREATE_SLOT:
		{
			if(response)
			{
				valstr(AOE_STR, listitem);
				cmd_createattachedobject(playerid, AOE_STR);
			}
			else SendClientMessage(playerid, AOE_COLOR0, AOE_M_CREATE_CANCEL);
		}
		case AOE_D_CREATE_MODEL:
		{
			if(response)
			{
				AOModel = strval(inputtext), EPV[playerid][PAO_MODEL_ID] = AOModel;
				if(AOE_EnteredValidModel(playerid, AOModel)) AOE_ShowPlayerDialog(playerid, AOE_C_BONE, AOE_D_CREATE_BONE, AOE_T_CREATE, AOE_B_SELECT, AOE_B_SELECT_MODEL);
				else AOE_ShowPlayerDialog(playerid, AOE_C_MODEL, AOE_D_CREATE_MODEL, AOE_T_CREATE, AOE_B_ENTER, AOE_B_SELECT_INDEX);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_CREATE_SLOT, AOE_T_CREATE, AOE_B_SELECT, AOE_B_CANCEL);
		}
		case AOE_D_CREATE_BONE:
		{
			if(response)
			{
				EPV[playerid][PAO_BONE_ID] = listitem+1;
				if(UpdatePlayerAttachedObjectEx(playerid, EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_MODEL_ID], EPV[playerid][PAO_BONE_ID]))
				{
					format(AOE_STR, sizeof AOE_STR, "* Created attached object model %d at index number %d [Bone: %s (%d)]!", EPV[playerid][PAO_MODEL_ID], EPV[playerid][PAO_INDEX1], GetAttachedObjectBoneName(EPV[playerid][PAO_BONE_ID]), EPV[playerid][PAO_BONE_ID]);
					SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
					format(AOE_STR, sizeof AOE_STR, "~b~Created attached object~n~~w~index/number: %d~n~Model: %d - Bone: %d", EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_MODEL_ID], EPV[playerid][PAO_BONE_ID]);
					AOE_GameTextForPlayer(playerid, AOE_STR);
					AOE_ShowPlayerDialog(playerid, AOE_C_CREATE_FINAL, AOE_D_CREATE_EDIT, AOE_T_CREATE_EDIT, AOE_B_EDIT, AOE_B_SKIP);
				}
				else SendClientMessage(playerid, AOE_COLOR1, AOE_M_CREATE_FAIL);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_MODEL, AOE_D_CREATE_MODEL, AOE_T_CREATE, AOE_B_ENTER, AOE_B_SELECT_INDEX);
		}
		case AOE_D_CREATE_REPLACE:
		{
			if(response) AOE_ShowPlayerDialog(playerid, AOE_C_MODEL, AOE_D_CREATE_MODEL, AOE_T_CREATE#AOE_T_REPLACE, AOE_B_ENTER, AOE_B_SELECT_INDEX);
			else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_CREATE_SLOT, AOE_T_CREATE, AOE_B_SELECT, AOE_B_CANCEL);
		}
		case AOE_D_CREATE_EDIT:
		{
			if(response)
			{
				valstr(AOE_STR, EPV[playerid][PAO_INDEX1]);
				cmd_editattachedobject(playerid, AOE_STR);
			}
			else
			{
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_EDIT_SKIP);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_EDIT_SKIP_INFO);
			}
		}
		case AOE_D_FILE:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: cmd_loadattachedobject(playerid, "");
					case 1: cmd_loadattachedobjects(playerid, "");
					case 2: cmd_saveattachedobject(playerid, "");
					case 3: cmd_deleteattachedobjectfile(playerid, "");
				}
			}
			else SendClientMessage(playerid, AOE_COLOR0, AOE_M_FILE_CANCEL);
		}
		case AOE_D_LOAD:
		{
			if(response)
			{
				if(AOE_EnteredValidFileName(playerid, inputtext))
				{
					strupdate(EPV[playerid][PAO_NAME], inputtext);
					format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, inputtext);
					if(AOE_EnteredExistedFileName(playerid, AOFileName)) AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_LOAD_SLOT, AOE_T_LOAD, AOE_B_LOAD, AOE_B_BACK);
					else AOE_ShowPlayerDialog(playerid, AOE_C_LOAD, AOE_D_LOAD, AOE_T_LOAD, AOE_B_ENTER, AOE_B_BACK);
				}
				else if(isnull(inputtext)) AOE_ShowPlayerDialog(playerid, AOE_C_LOAD, AOE_D_LOAD, AOE_T_LOAD, AOE_B_ENTER, AOE_B_BACK);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_FILE, AOE_D_FILE, AOE_T_FILE, AOE_B_SELECT, AOE_B_CANCEL);
		}
		case AOE_D_LOAD_SLOT:
		{
			if(response)
			{
				format(AOE_STR, sizeof AOE_STR, "%s %d", EPV[playerid][PAO_NAME], strval(inputtext));
				cmd_loadattachedobject(playerid, AOE_STR);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_LOAD, AOE_D_LOAD, AOE_T_LOAD, AOE_B_ENTER, AOE_B_BACK);
		}
		case AOE_D_LOAD_REPLACE:
		{
			if(response)
			{
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_LOADING);
				format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, EPV[playerid][PAO_NAME]);
				if(AOE_LoadPlayerAttachedObject(playerid, AOFileName, EPV[playerid][PAO_INDEX1], AOComment))
				{
					format(AOE_STR, sizeof AOE_STR, "* You've loaded & replaced your attached object from file \"{FFFFFF}%s{%06x}\" [Index: %d|Model: %d|Bone: %d]!",
					EPV[playerid][PAO_NAME], AOE_COLOR2 >>> 8, EPV[playerid][PAO_INDEX1], PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_MODEL_ID], PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_BONE_ID]);
					SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
					if(!isnull(AOComment))
					{
						format(AOE_STR, sizeof AOE_STR, "** Comment: %s.", AOComment);
						SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
					}
					format(AOE_STR, sizeof AOE_STR, "~g~~h~Attached object file loaded~n~%s", EPV[playerid][PAO_NAME]);
					AOE_GameTextForPlayer(playerid, AOE_STR);
				}
				else SendClientMessage(playerid, AOE_COLOR1, AOE_M_ERROR);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_LOAD_SLOT, AOE_T_LOAD, AOE_B_LOAD, AOE_B_BACK);
		}
		case AOE_D_LOAD2:
		{
			if(response)
			{
				if(AOE_EnteredValidFileName(playerid, inputtext))
				{
					strupdate(EPV[playerid][PAO_NAME], inputtext);
					format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, inputtext);
					if(AOE_EnteredExistedFileName(playerid, AOFileName)) cmd_loadattachedobjects(playerid, inputtext);
					else AOE_ShowPlayerDialog(playerid, AOE_C_LOAD, AOE_D_LOAD2, AOE_T_LOAD_SET, AOE_B_LOAD, AOE_B_BACK);
				}
				else if(isnull(inputtext)) AOE_ShowPlayerDialog(playerid, AOE_C_LOAD, AOE_D_LOAD2, AOE_T_LOAD_SET, AOE_B_LOAD, AOE_B_BACK);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_FILE, AOE_D_FILE, AOE_T_FILE, AOE_B_SELECT, AOE_B_CANCEL);
		}
		case AOE_D_SAVE_SLOT:
		{
			if(response)
			{
				if(listitem == 10) cmd_saveallattachedobjects(playerid, "");
				else
				{
					if(AOE_HasSlot(playerid, listitem))
					{
						valstr(AOE_STR, listitem);
						cmd_saveattachedobject(playerid, AOE_STR);
					}
					else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_ALL, AOE_D_SAVE_SLOT, AOE_T_SAVE, AOE_B_SELECT, AOE_B_BACK);
				}
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_FILE, AOE_D_FILE, AOE_T_FILE, AOE_B_SELECT, AOE_B_CANCEL);
		}
		case AOE_D_SAVE:
		{
			if(response)
			{
				if(AOE_EnteredValidFileName(playerid, inputtext))
				{
					strupdate(EPV[playerid][PAO_NAME], inputtext);
					format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, inputtext);
					if(AOE_EnteredNonExistFileName(playerid, AOFileName))
					{
						format(AOE_STR, sizeof AOE_STR, "%d %s", EPV[playerid][PAO_INDEX1], inputtext);
						cmd_saveattachedobject(playerid, AOE_STR);
					}
				}
				else AOE_ShowPlayerDialog(playerid, AOE_C_SAVE, AOE_D_SAVE, AOE_T_SAVE, AOE_B_SAVE, AOE_B_BACK);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_ALL, AOE_D_SAVE_SLOT, AOE_T_SAVE, AOE_B_SELECT, AOE_B_SELECT_INDEX);
		}
		case AOE_D_SAVE_REPLACE:
		{
			if(response)
			{
				format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, EPV[playerid][PAO_NAME]);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SAVING);
				if(AOE_SavePlayerAttachedObject(playerid, AOFileName, EPV[playerid][PAO_INDEX1], "", AOFileLen))
				{
					format(AOE_STR, sizeof AOE_STR, "* Your attached object from index %d has been saved as \"{FFFFFF}%s{%06x}\" [Model: %d|Bone: %d|%.2f KB]!",
						EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_NAME], AOE_COLOR2 >>> 8, PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_MODEL_ID], PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_BONE_ID], AOFileLen);
					SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
					SendClientMessage(playerid, AOE_COLOR2, AOE_M_SAVE_OVERWRITE);
					format(AOE_STR, sizeof AOE_STR, "~g~~h~Attached object file saved~n~%s", EPV[playerid][PAO_NAME]);
					AOE_GameTextForPlayer(playerid, AOE_STR);
				}
				else
				{
					SendClientMessage(playerid, AOE_COLOR1, AOE_M_SAVE_ERROR);
					AOE_GameTextForPlayer(playerid, AOE_G_INVALID_DATA);
				}
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SAVE, AOE_D_SAVE, AOE_T_SAVE, AOE_B_SAVE, AOE_B_BACK);
		}
		case AOE_D_SAVE2:
		{
			if(response)
			{
				if(AOE_EnteredValidFileName(playerid, inputtext))
				{
					strupdate(EPV[playerid][PAO_NAME], inputtext);
					format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, inputtext);
					if(AOE_EnteredNonExistFileName2(playerid, AOFileName)) cmd_saveallattachedobjects(playerid, inputtext);
				}
				else AOE_ShowPlayerDialog(playerid, AOE_C_SAVE, AOE_D_SAVE2, AOE_T_SAVE_SET, AOE_B_SAVE, AOE_B_BACK);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_ALL, AOE_D_SAVE_SLOT, AOE_T_SAVE_SET, AOE_B_SELECT, AOE_B_SELECT_INDEX);
		}
		case AOE_D_SAVE2_REPLACE:
		{
			if(response)
			{
				format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, EPV[playerid][PAO_NAME]);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_SAVING_SET);
				slots = AOE_SavePlayerAttachedObject(playerid, AOFileName, MAX_PLAYER_ATTACHED_OBJECTS, "", AOFileLen);
				if(slots)
				{
					format(AOE_STR, sizeof AOE_STR, "* Your attached object set has been saved as \"{FFFFFF}%s{%06x}\" (Total: %d|Size: %.2f KB)!", EPV[playerid][PAO_NAME], AOE_COLOR2 >>> 8, slots, AOFileLen);
					SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
					SendClientMessage(playerid, AOE_COLOR2, AOE_M_SAVE_SET_OVERWRITE);
					format(AOE_STR, sizeof AOE_STR, "~g~~h~Attached object(s) file saved~n~%s", EPV[playerid][PAO_NAME]);
					AOE_GameTextForPlayer(playerid, AOE_STR);
				}
				else SendClientMessage(playerid, AOE_COLOR1, AOE_M_SAVE_SET_ERROR);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SAVE, AOE_D_SAVE2, AOE_T_SAVE_SET, AOE_B_SAVE, AOE_B_BACK);
		}
		case AOE_D_DELETE:
		{
			if(response)
			{
				if(AOE_EnteredValidFileName(playerid, inputtext))
				{
					format(AOFileName, sizeof AOFileName, AOE_FILE_NAME, inputtext);
					if(AOE_EnteredExistedFileName(playerid, AOFileName))
					{
						cmd_deleteattachedobjectfile(playerid, inputtext);
					}
					else AOE_ShowPlayerDialog(playerid, AOE_C_DELETE, AOE_D_DELETE, AOE_T_DELETE, AOE_B_DELETE, AOE_B_CANCEL);
				}
				else if(isnull(inputtext)) AOE_ShowPlayerDialog(playerid, AOE_C_DELETE, AOE_D_DELETE, AOE_T_DELETE, AOE_B_DELETE, AOE_B_CANCEL);
			}
			else SendClientMessage(playerid, AOE_COLOR4, AOE_M_DELETE_CANCEL);
		}
		case AOE_D_EDIT_SLOT:
		{
			if(response)
			{
				if(IsPlayerAttachedObjectSlotUsed(playerid, listitem))
				{
					EPV[playerid][PAO_INDEX1] = listitem;
					format(AOE_STR, sizeof AOE_STR, "Edit Attached Object (%d)", listitem);
					AOE_ShowPlayerDialog(playerid, AOE_C_EDIT, AOE_D_EDIT, AOE_STR, AOE_B_SELECT, AOE_B_CANCEL);
				}
				else
				{
					valstr(AOE_STR, listitem);
					cmd_createattachedobject(playerid, AOE_STR);
				}
			}
			else SendClientMessage(playerid, AOE_COLOR0, AOE_M_EDIT_CANCEL);
		}
		case AOE_D_EDIT:
		{
			if(response)
			{
				valstr(AOE_STR, EPV[playerid][PAO_INDEX1]);
				switch(listitem)
				{
					case 0: cmd_editattachedobject(playerid, AOE_STR);
					case 1:
					{
						format(AOE_STR, sizeof AOE_STR, "Edit Attached Object Properties (%d)", listitem);
						AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_PROPERTIES, AOE_D_EDIT_PROPERTIES, AOE_STR, AOE_B_EDIT, AOE_B_CANCEL);
					}
					case 2: cmd_attachedobjectproperties(playerid, AOE_STR);
					case 3: cmd_duplicateattachedobject(playerid, AOE_STR);
					case 4: cmd_removeattachedobject(playerid, AOE_STR);
				}
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_USED, AOE_D_EDIT_SLOT, AOE_T_EDIT, AOE_B_SELECT, AOE_B_CLOSE);
		}
		case AOE_D_EDIT_PROPERTIES:
		{
			if(response)
			{
				valstr(AOE_STR, EPV[playerid][PAO_INDEX1]);
				if(3 <= listitem <= 13) EPV[playerid][PAO_EDITING] = listitem;
				switch(listitem)
				{
					case 0: cmd_setattachedobjectindex(playerid, AOE_STR);
					case 1: cmd_setattachedobjectmodel(playerid, AOE_STR);
					case 2: cmd_setattachedobjectbone(playerid, AOE_STR);
					case 3..5: // offset
					{
						format(AOE_STR, sizeof AOE_STR, "Edit Attached Object %c (%d)", ('X'-3)+listitem, EPV[playerid][PAO_INDEX1]);
						AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_XYZ, AOE_D_EDIT_XYZ, AOE_STR, AOE_B_ENTER, AOE_B_BACK);
					}
					case 6..8: // rotation
					{
						format(AOE_STR, sizeof AOE_STR, "Edit Attached Object R%c (%d)", ('X'-6)+listitem, EPV[playerid][PAO_INDEX1]);
						AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_XYZ, AOE_D_EDIT_XYZ, AOE_STR, AOE_B_ENTER, AOE_B_BACK);
					}
					case 9..11: // scale
					{
						format(AOE_STR, sizeof AOE_STR, "Edit Attached Object S%c (%d)", ('X'-9)+listitem, EPV[playerid][PAO_INDEX1]);
						AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_XYZ, AOE_D_EDIT_XYZ, AOE_STR, AOE_B_ENTER, AOE_B_BACK);
					}
					case 12..13: // color
					{
						format(AOE_STR, sizeof AOE_STR, "Edit Attached Object Color %c (%d)", ('1'-12)+listitem, EPV[playerid][PAO_INDEX1]);
						AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_COLOR, AOE_D_EDIT_COLOR, AOE_STR, AOE_B_ENTER, AOE_B_BACK);
					}
				}
			}
			else
			{
				format(AOE_STR, sizeof AOE_STR, "Edit Attached Object (%d)", EPV[playerid][PAO_INDEX1]);
				AOE_ShowPlayerDialog(playerid, AOE_C_EDIT, AOE_D_EDIT, AOE_STR, AOE_B_SELECT, AOE_B_CANCEL);
			}
		}
		case AOE_D_SET_SLOT:
		{
			if(response)
			{
				format(AOE_STR, sizeof AOE_STR, "%d %d", EPV[playerid][PAO_INDEX1], listitem);
				cmd_setattachedobjectindex(playerid, AOE_STR);
			}
			else
			{
				format(AOE_STR, sizeof AOE_STR, "Edit Attached Object (%d)", EPV[playerid][PAO_INDEX1]);
				AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_PROPERTIES, AOE_D_EDIT_PROPERTIES, AOE_STR, AOE_B_SELECT, AOE_B_BACK);
			}
		}
		case AOE_D_SET_SLOT_REPLACE:
		{
			if(response)
			{
				if(ChangePlayerAttachedObjectIndex(playerid, EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_INDEX2]))
				{
					format(AOE_STR, sizeof AOE_STR, "* Moved & replaced your attached object from index number %d to %d!", EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_INDEX2]);
					SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
					format(AOE_STR, sizeof AOE_STR, "~g~Attached object moved~n~~w~index/number:~n~%d to %d", EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_INDEX2]);
					AOE_GameTextForPlayer(playerid, AOE_STR);
				}
				else SendClientMessage(playerid, AOE_COLOR1, AOE_M_SET_SLOT_FAIL);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_SET_SLOT, AOE_T_SET_INDEX, AOE_B_SELECT, AOE_B_BACK);
		}
		case AOE_D_SET_MODEL:
		{
			if(response)
			{
				format(AOE_STR, sizeof AOE_STR, "%d %d", EPV[playerid][PAO_INDEX1], strval(inputtext));
				cmd_setattachedobjectmodel(playerid, AOE_STR);
			}
			else
			{
				format(AOE_STR, sizeof AOE_STR, "Edit Attached Object (%d)", EPV[playerid][PAO_INDEX1]);
				AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_PROPERTIES, AOE_D_EDIT_PROPERTIES, AOE_STR, AOE_B_SELECT, AOE_B_BACK);
			}
		}
		case AOE_D_SET_BONE:
		{
			if(response)
			{
				format(AOE_STR, sizeof AOE_STR, "%d %d", EPV[playerid][PAO_INDEX1], listitem+1);
				cmd_setattachedobjectbone(playerid, AOE_STR);
			}
			else
			{
				format(AOE_STR, sizeof AOE_STR, "Edit Attached Object (%d)", EPV[playerid][PAO_INDEX1]);
				AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_PROPERTIES, AOE_D_EDIT_PROPERTIES, AOE_STR, AOE_B_SELECT, AOE_B_BACK);
			}
		}
		case AOE_D_EDIT_XYZ:
		{
			AOSelection = EPV[playerid][PAO_EDITING];
			if(response)
			{
				if(sscanf(inputtext, "f", AOAxis))
				{
					SendClientMessage(playerid, AOE_COLOR4, AOE_M_INVALID_XYZ);
					format(AOE_STR, sizeof AOE_STR, "Edit Attached Object XYZ (%d)", EPV[playerid][PAO_INDEX1]);
					AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_XYZ, AOE_D_EDIT_XYZ, AOE_STR, AOE_B_ENTER, AOE_B_BACK);
				}
				else
				{
					EPV[playerid][PAO_EDITING] = 0;
					switch(AOSelection)
					{
						case 3..5:
						{
							format(AOE_STR, sizeof AOE_STR, "%d %c %f", EPV[playerid][PAO_INDEX1], ('x'-3)+AOSelection, AOAxis);
							cmd_setattachedobjectoffset(playerid, AOE_STR);
						}
						case 6..8:
						{
							format(AOE_STR, sizeof AOE_STR, "%d %c %f", EPV[playerid][PAO_INDEX1], ('x'-6)+AOSelection, AOAxis);
							cmd_setattachedobjectrot(playerid, AOE_STR);
						}
						case 9..11:
						{
							format(AOE_STR, sizeof AOE_STR, "%d %c %f", EPV[playerid][PAO_INDEX1], ('x'-9)+AOSelection, AOAxis);
							cmd_setattachedobjectscale(playerid, AOE_STR);
						}
					}
				}
			}
			else
			{
				EPV[playerid][PAO_EDITING] = 0;
				format(AOE_STR, sizeof AOE_STR, "Edit Attached Object (%d)", EPV[playerid][PAO_INDEX1]);
				AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_PROPERTIES, AOE_D_EDIT_PROPERTIES, AOE_STR, AOE_B_SELECT, AOE_B_BACK);
			}
		}
		case AOE_D_EDIT_COLOR:
		{
			AOSelection = EPV[playerid][PAO_EDITING];
			if(response)
			{
				if(sscanf(inputtext, "x", AOMC))
				{
					SendClientMessage(playerid, AOE_COLOR4, AOE_M_INVALID_COLOR);
					format(AOE_STR, sizeof AOE_STR, "Edit Attached Object Color (%d)", EPV[playerid][PAO_INDEX1]);
					AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_COLOR, AOE_D_EDIT_COLOR, AOE_STR, AOE_B_ENTER, AOE_B_BACK);
				}
				else
				{
					EPV[playerid][PAO_EDITING] = 0;
					format(AOE_STR, sizeof AOE_STR, "%d %x", EPV[playerid][PAO_INDEX1], AOMC);
					switch(AOSelection)
					{
						case 12: cmd_setattachedobjectmc1(playerid, AOE_STR);
						case 13: cmd_setattachedobjectmc2(playerid, AOE_STR);
					}
				}
			}
			else
			{
				EPV[playerid][PAO_EDITING] = 0;
				format(AOE_STR, sizeof AOE_STR, "Edit Attached Object (%d)", EPV[playerid][PAO_INDEX1]);
				AOE_ShowPlayerDialog(playerid, AOE_C_EDIT_PROPERTIES, AOE_D_EDIT_PROPERTIES, AOE_STR, AOE_B_SELECT, AOE_B_BACK);
			}
		}
		case AOE_D_PROPERTIES:
		{
			if(response && IsPlayerAdmin(playerid))
			{
				AOSlot = EPV[playerid][PAO_INDEX1], AOTarget = EPV[playerid][PAO_TARGET];
				GetPlayerName(playerid, pName, sizeof pName);
				printf("  >> Admin %s (ID:%d) has requested to print attached object properties", pName, playerid);
				GetPlayerName(AOTarget, pName, sizeof pName);
				printf("  Player: %s (ID:%d)\n  Attached object index number: %d\n  - Model ID/type number: %d\n  - Bone: %s (%d)\n  - Offsets:\n  -- X: %.2f ~ Y: %.2f ~ Z: %.2f\n  - Rotations:\n  -- RX: %.2f ~ RY: %.2f ~ RZ: %.2f\
				\n  - Scales:\n  -- SX: %.2f ~ SY: %.2f ~ SZ: %.2f\n  - Material Colors:\n  -- Color 1: 0x%04x%04x (%i) ~ Color 2: 0x%04x%04x (%i)", pName, AOTarget, AOSlot, PAO[AOTarget][AOSlot][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[AOTarget][AOSlot][AO_BONE_ID]),
				PAO[AOTarget][AOSlot][AO_BONE_ID], PAO[AOTarget][AOSlot][AO_X], PAO[AOTarget][AOSlot][AO_Y], PAO[AOTarget][AOSlot][AO_Z], PAO[AOTarget][AOSlot][AO_RX], PAO[AOTarget][AOSlot][AO_RY], PAO[AOTarget][AOSlot][AO_RZ],
				PAO[AOTarget][AOSlot][AO_SX], PAO[AOTarget][AOSlot][AO_SY], PAO[AOTarget][AOSlot][AO_SZ], HexPrintFormat(PAO[AOTarget][AOSlot][AO_MC1]), PAO[AOTarget][AOSlot][AO_MC1], HexPrintFormat(PAO[AOTarget][AOSlot][AO_MC2], PAO[AOTarget][AOSlot][AO_MC2]));
				printf("  Skin: %d ~ Code usage (playerid = %d):\n	SetPlayerAttachedObject(playerid, %d, %d, %d, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %d, %d);", GetPlayerSkin(AOTarget), AOTarget,
				AOSlot, PAO[AOTarget][AOSlot][AO_MODEL_ID], PAO[AOTarget][AOSlot][AO_BONE_ID], PAO[AOTarget][AOSlot][AO_X], PAO[AOTarget][AOSlot][AO_Y], PAO[AOTarget][AOSlot][AO_Z], PAO[AOTarget][AOSlot][AO_RX], PAO[AOTarget][AOSlot][AO_RY], PAO[AOTarget][AOSlot][AO_RZ],
				PAO[AOTarget][AOSlot][AO_SX], PAO[AOTarget][AOSlot][AO_SY], PAO[AOTarget][AOSlot][AO_SZ], PAO[AOTarget][AOSlot][AO_MC1], PAO[AOTarget][AOSlot][AO_MC2]);
				SendClientMessage(playerid, AOE_COLOR0, AOE_M_OBJECT_DATA_S_PRINT);
			}
			else SendClientMessage(playerid, AOE_COLOR0, AOE_M_PROPERTIES_CLOSE);
		}
		case AOE_D_DUPLICATE_SLOT:
		{
			if(response)
			{
				format(AOE_STR, sizeof AOE_STR, "%d %d", EPV[playerid][PAO_INDEX1], listitem);
				cmd_duplicateattachedobject(playerid, AOE_STR);
			}
			else
			{
				format(AOE_STR, sizeof AOE_STR, "Edit Attached Object (%d)", EPV[playerid][PAO_INDEX1]);
				AOE_ShowPlayerDialog(playerid, AOE_C_EDIT, AOE_D_EDIT, AOE_STR, AOE_B_SELECT, AOE_B_CANCEL);
			}
		}
		case AOE_D_DUPLICATE_REPLACE:
		{
			if(response)
			{
				DuplicatePlayerAttachedObject(playerid, EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_INDEX2]);
				format(AOE_STR, sizeof AOE_STR, "* Duplicated your attached object from index number %d to %d!", EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_INDEX2]);
				SendClientMessage(playerid, AOE_COLOR2, AOE_STR);
				format(AOE_STR, sizeof AOE_STR, "~g~Attached object duplicated~n~~w~index/number:~n~%d to %d", EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_INDEX2]);
				AOE_GameTextForPlayer(playerid, AOE_STR);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_SLOT_EMPTY, AOE_D_DUPLICATE_SLOT, AOE_T_DUPLICATE, AOE_B_SELECT, AOE_B_BACK);
		}
		case AOE_D_REMOVE_ALL:
		{
			if(response)
			{
				slots = RemovePlayerAttachedObjectEx(playerid, MAX_PLAYER_ATTACHED_OBJECTS);
				format(AOE_STR, sizeof AOE_STR, "* You've removed all %d of your attached object(s)!", slots);
				SendClientMessage(playerid, AOE_COLOR1, AOE_STR);
				format(AOE_STR, sizeof AOE_STR, "~r~Removed all your attached object(s)~n~~w~Total: %d", slots);
				AOE_GameTextForPlayer(playerid, AOE_STR);
			}
			else SendClientMessage(playerid, AOE_COLOR0, AOE_M_REMOVE_ALL_CANCEL);
		}
		case AOE_D_REFRESH:
		{
			AOTarget = EPV[playerid][PAO_TARGET];
			if(response)
			{
				if(AOE_TargetHasSlot(playerid, AOTarget, listitem))
				{
					format(AOE_STR, sizeof AOE_STR, "%d %d", AOTarget, listitem);
					cmd_refreshattachedobject(playerid, AOE_STR);
				}
				else AOE_ShowPlayerDialog(playerid, AOE_C_REFRESH, AOE_D_REFRESH, AOE_T_REFRESH, AOE_B_SELECT, AOE_B_CANCEL);
			}
			else
			{
				GetPlayerName(AOTarget, pName, sizeof pName);
				format(AOE_STR, sizeof AOE_STR, "* You've canceled loading %s (ID:%d)'s attached object from index %d.", pName, EPV[playerid][PAO_TARGET], listitem);
				SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
			}
		}
		case AOE_D_REFRESH_REPLACE:
		{
			AOTarget = EPV[playerid][PAO_TARGET];
			if(response)
			{
				format(AOE_STR, sizeof AOE_STR, "%d %d", AOTarget, EPV[playerid][PAO_INDEX1]);
				RemovePlayerAttachedObject(playerid, EPV[playerid][PAO_INDEX1]);
				cmd_refreshattachedobject(playerid, AOE_STR);
			}
			else AOE_ShowPlayerDialog(playerid, AOE_C_REFRESH, AOE_D_REFRESH, AOE_T_REFRESH, AOE_B_SELECT, AOE_B_CANCEL);
		}
	}
	return 0;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	if(response == EDIT_RESPONSE_FINAL)
	{
		if(MAX_ATTACHED_OBJECT_OFFSET <= fOffsetX <= MIN_ATTACHED_OBJECT_OFFSET || MAX_ATTACHED_OBJECT_OFFSET <= fOffsetY <= MIN_ATTACHED_OBJECT_OFFSET || MAX_ATTACHED_OBJECT_OFFSET <= fOffsetZ <= MIN_ATTACHED_OBJECT_OFFSET
			|| MAX_ATTACHED_OBJECT_ROTATION <= fRotX <= MIN_ATTACHED_OBJECT_ROTATION || MAX_ATTACHED_OBJECT_ROTATION <= fRotY <= MIN_ATTACHED_OBJECT_ROTATION || MAX_ATTACHED_OBJECT_ROTATION <= fRotZ <= MIN_ATTACHED_OBJECT_ROTATION
			|| MAX_ATTACHED_OBJECT_SIZE <= fScaleX <= MIN_ATTACHED_OBJECT_SIZE || MAX_ATTACHED_OBJECT_SIZE <= fScaleY <= MIN_ATTACHED_OBJECT_SIZE || MAX_ATTACHED_OBJECT_SIZE <= fScaleZ <= MIN_ATTACHED_OBJECT_SIZE)
		{
			format(AOE_STR, sizeof AOE_STR, "* Sorry your edit on index %d was aborted, because you cannot edit with value of:", index);
			SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
			SendClientMessage(playerid, AOE_COLOR0, AOE_M_ACCEPTABLE_OFFSET);
			SendClientMessage(playerid, AOE_COLOR0, AOE_M_ACCEPTABLE_ROTATION);
			SendClientMessage(playerid, AOE_COLOR0, AOE_M_ACCEPTABLE_SCALE);
			format(AOE_STR, sizeof AOE_STR, "* Edit was: X=%.2f|Y=%.2f|Z=%.2f|RX=%.2f|RY=%.2f|RZ=%.2f|SX=%.2f|SY=%.2f|SZ=%.2f", fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
			SetPlayerAttachedObject(playerid, index, PAO[playerid][index][AO_MODEL_ID], PAO[playerid][index][AO_BONE_ID], PAO[playerid][index][AO_X], PAO[playerid][index][AO_Y], PAO[playerid][index][AO_Z],
			PAO[playerid][index][AO_RX], PAO[playerid][index][AO_RY], PAO[playerid][index][AO_RZ], PAO[playerid][index][AO_SX], PAO[playerid][index][AO_SY], PAO[playerid][index][AO_SZ], PAO[playerid][index][AO_MC1], PAO[playerid][index][AO_MC2]);
			PAO[playerid][index][AO_STATUS] = 1;
		}
		else
		{
			if(IsValidPlayerAttachedObject(playerid, index) != 1)
			{
				format(AOE_STR, sizeof AOE_STR, "* Refreshing attached object (ID:%d) data (excluding material colors)...", index);
				SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
			}
			if(EPV[playerid][PAO_EDITING] == 2)
			{
				PAO[playerid][index][AO_STATUS] = 1;
				PAO[playerid][index][AO_MODEL_ID] = modelid;
				PAO[playerid][index][AO_BONE_ID] = boneid;
			}
			PAO[playerid][index][AO_X] = fOffsetX, PAO[playerid][index][AO_Y] = fOffsetY, PAO[playerid][index][AO_Z] = fOffsetZ;
			PAO[playerid][index][AO_RX] = fRotX, PAO[playerid][index][AO_RY] = fRotY, PAO[playerid][index][AO_RZ] = fRotZ;
			PAO[playerid][index][AO_SX] = fScaleX, PAO[playerid][index][AO_SY] = fScaleY, PAO[playerid][index][AO_SZ] = fScaleZ;
			format(AOE_STR, sizeof AOE_STR, "* You've edited your attached object from index number %d.", index);
			SendClientMessage(playerid, AOE_COLOR5, AOE_STR);
			format(AOE_STR, sizeof AOE_STR, "~b~~h~Edited your attached object~n~~w~index/number: %d", index);
			AOE_GameTextForPlayer(playerid, AOE_STR);
		}
	}
	if(response == EDIT_RESPONSE_CANCEL)
	{
		SetPlayerAttachedObject(playerid, index, PAO[playerid][index][AO_MODEL_ID], PAO[playerid][index][AO_BONE_ID], PAO[playerid][index][AO_X], PAO[playerid][index][AO_Y], PAO[playerid][index][AO_Z],
		PAO[playerid][index][AO_RX], PAO[playerid][index][AO_RY], PAO[playerid][index][AO_RZ], PAO[playerid][index][AO_SX], PAO[playerid][index][AO_SY], PAO[playerid][index][AO_SZ], PAO[playerid][index][AO_MC1], PAO[playerid][index][AO_MC2]);
		PAO[playerid][index][AO_STATUS] = 1;
		format(AOE_STR, sizeof AOE_STR, "* You've canceled editing your attached object from index number %d.", index);
		SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		format(AOE_STR, sizeof AOE_STR, "~r~~h~Canceled editing your attached object~n~~w~index/number: %d", index);
		AOE_GameTextForPlayer(playerid, AOE_STR);
	}
	EPV[playerid][PAO_EDITING] = 0;
	return 1;
}
// =============================================================================
public AOE_GetPVar(playerid, varname[])
{
	if(!strcmp(varname, "PAO_INDEX1")) return EPV[playerid][PAO_INDEX1];
	else if(!strcmp(varname, "PAO_INDEX2")) return EPV[playerid][PAO_INDEX2];
	else if(!strcmp(varname, "PAO_MODEL_ID")) return EPV[playerid][PAO_MODEL_ID];
	else if(!strcmp(varname, "PAO_BONE_ID")) return EPV[playerid][PAO_BONE_ID];
	else if(!strcmp(varname, "PAO_EDITING")) return EPV[playerid][PAO_EDITING];
	else if(!strcmp(varname, "PAO_TARGET")) return EPV[playerid][PAO_TARGET];
	else if(!strcmp(varname, "PAO_LAST_REMOVED")) return EPV[playerid][PAO_LAST_REMOVED];
	else if(!strcmp(varname, "PAO_NAME")) return EPV[playerid][PAO_NAME];
	return -1;
}

AOE_UnsetValues(playerid, index)
{
	PAO[playerid][index][AO_STATUS] = 0;
	PAO[playerid][index][AO_MODEL_ID] = 0, PAO[playerid][index][AO_BONE_ID] = 0;
	PAO[playerid][index][AO_X] = 0.0, PAO[playerid][index][AO_Y] = 0.0, PAO[playerid][index][AO_Z] = 0.0;
	PAO[playerid][index][AO_RX] = 0.0, PAO[playerid][index][AO_RY] = 0.0, PAO[playerid][index][AO_RZ] = 0.0;
	PAO[playerid][index][AO_SX] = 0.0, PAO[playerid][index][AO_SY] = 0.0, PAO[playerid][index][AO_SZ] = 0.0;
	PAO[playerid][index][AO_MC1] = 0, PAO[playerid][index][AO_MC2] = 0;
}

AOE_UnsetVars(playerid)
{
	if(EPV[playerid][PAO_EDITING] >= 1) CancelEdit(playerid);
	EPV[playerid][PAO_INDEX1] = 0;
	EPV[playerid][PAO_INDEX2] = 0;
	EPV[playerid][PAO_MODEL_ID] = 0;
	EPV[playerid][PAO_BONE_ID] = 0;
	EPV[playerid][PAO_EDITING] = 0;
	EPV[playerid][PAO_TARGET] = 0;
	EPV[playerid][PAO_NAME][0] = EOS;
	EPV[playerid][PAO_LAST_REMOVED] = MAX_PLAYER_ATTACHED_OBJECTS;
}

AOE_ShowPlayerDialog(playerid, class, dialogid, caption[], button1[], button2[] = "")
{
	new slots, AOE_STR2[1430];
	switch(class)
	{
		case AOE_C: // Menu
		{
			slots = GetPlayerAttachedObjectsCount(playerid);
			if(slots) format(AOE_STR, sizeof AOE_STR, "Edit...\nClear all [%d]", slots);
			else AOE_STR = "{808080}Edit...\n{808080}Clear all";
			if(0 <= EPV[playerid][PAO_LAST_REMOVED] < MAX_PLAYER_ATTACHED_OBJECTS)
			{
				if(IsPlayerAttachedObjectSlotUsed(playerid, EPV[playerid][PAO_LAST_REMOVED])) format(AOE_STR2, sizeof AOE_STR2, "{FF3333}Restore last deleted", EPV[playerid][PAO_LAST_REMOVED]);
				else format(AOE_STR2, sizeof AOE_STR2, "Restore last deleted [index: %d]", EPV[playerid][PAO_LAST_REMOVED]);
			}
			else AOE_STR2 = "{808080}Restore last deleted";
			format(AOE_STR2, sizeof AOE_STR2, "%sCreate...\nFile...\n%s\n%s\n%sStatistics\nHelp commands\nAbout this editor",
				(slots == MAX_PLAYER_ATTACHED_OBJECTS ? ("{FF3333}") : ("")), AOE_STR, AOE_STR2, (IsPlayerAdmin(playerid) ? ("{006699}") : ("")));
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, AOE_STR2, button1, button2);
		}
		case AOE_C_FILE: // File menu
		{
			slots = GetPlayerAttachedObjectsCount(playerid);
			if(slots == MAX_PLAYER_ATTACHED_OBJECTS) AOE_STR2 = "{FF3333}Load an attached object\n{FF3333}Load attached object(s) set\nSave attached object";
			else if(slots == 0) AOE_STR2 = "Load an attached object\nLoad attached object(s) set\n{808080}Save attached object";
			else AOE_STR2 = "Load an attached object\nLoad attached object(s) set\nSave attached object";
			if(IsPlayerAdmin(playerid)) strcat(AOE_STR2, "\n{FFFF66}Delete attached object file");
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, AOE_STR2, button1, button2);
		}
		case AOE_C_EDIT: // Edit menu
		{
			slots = GetPlayerAttachedObjectsCount(playerid);
			format(AOE_STR2, sizeof AOE_STR2, "Adjust\nEdit Properties\nView Properties\n%sDuplicate\n%sRemove",
				(slots == MAX_PLAYER_ATTACHED_OBJECTS ? ("{FF3333}") : ("")), (slots == MAX_PLAYER_ATTACHED_OBJECTS ? ("{FFFFFF}") : ("")));
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, AOE_STR2, button1, button2);
		}
		case AOE_C_HELP: // Help
		{
			AOE_STR2 = "/attachedobjecteditor (/aoe): Shows attached object editor menu dialog\n\
				/createattachedobject (/cao): Create your attached object\n\
				/editattachedobject (/eao): Edit your attached object\n\
				/duplicateattachedobject (/dao): Duplicate your attached object\n";
			strcat(AOE_STR2, "/removeattachedobject (/rao): Remove your attached object\n\
				/removeattachedobjects (/raos): Remove all of your attached object(s)\n\
				/undeleteattachedobject (/udao): Restore your deleted attached object\n\
				/saveattachedobject (/sao): Save your attached object to a file\n");
			strcat(AOE_STR2, "/saveattachedobjects (/saos): Save all of your attached object(s) to a set file\n\
				/loadattachedobject (/lao): Load existing attached object file\n\
				/loadattachedobjects (/laos): Load existing attached object(s) set file\n\
				/attachedobjectstats (/aos): Shows a player or your attached object stats\n");
			strcat(AOE_STR2, "/refreshattachedobject (/rpao): Refresh another player's attached object\n\
				/setattachedobjectindex (/saoi): Set your attached object index\n\
				/setattachedobjectmodel (/saom): Set your attached object model\n");
			strcat(AOE_STR2, "/setattachedobjectbone (/saob): Set your attached object bone\n\
				/setattachedobjectoffset (/saoo): Set your attached object offset [X/Y/Z]\n\
				/setattachedobjectrot (/saor): Set your attached object rotation [RX/RY/RZ]\n");
			strcat(AOE_STR2, "/setattachedobjectscale (/saos): Set your attached object size [SX/SY/SZ]\n\
				/setattachedobjectmc (/saomc[1/2]): Set your attached object material color [#1/#2]");
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR2, button1, button2);
		}
		case AOE_C_ABOUT: // About
		{
			GetPlayerName(playerid, pName, sizeof pName);
			format(AOE_STR2, sizeof AOE_STR2, "[FilterScript] Attached Object Editor for SA:MP 0.3e or upper\nAn editor for player attachment\n\nVersion: %s\nCreated by: Robo_N1X\nhttp://forum.sa-mp.com/showthread.php?t=416138\n\nCredits & Thanks to:\n\
			> SA:MP Team (www.sa-mp.com)\n> Scott: attachments editor idea\n> Y_Less (y-less.com)\n> Zeex: ZCMD\n> SA:MP Wiki Contributors (wiki.sa-mp.com)\nAnd whoever that made useful function for this script\nAlso you, %s for using this editor!",
			AOE_VERSION, pName); // Keep the script form like this or the compiler will crash!
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR2, button1, button2);
		}
		case AOE_C_SLOT_EMPTY: // Free slot list
		{
			for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
			{
				if(IsValidPlayerAttachedObject(playerid, i) == -1) format(AOE_STR2, sizeof AOE_STR2, "%s{FFFFFF}%d. None\n", AOE_STR2, i);
				else if(!IsValidPlayerAttachedObject(playerid, i)) format(AOE_STR2, sizeof AOE_STR2, "%s{808080}%d. Unknown - Invalid attached object info\n", AOE_STR2, i);
				else format(AOE_STR2, sizeof AOE_STR2, "%s{FF3333}%d. %d - %s (Bone:%d) - (Used)\n", AOE_STR2, i, PAO[playerid][i][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[playerid][i][AO_BONE_ID]), PAO[playerid][i][AO_BONE_ID]);
			}
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, AOE_STR2, button1, button2);
			if(!strcmp(button1, AOE_B_SELECT, true)) format(AOE_STR, sizeof AOE_STR, "* %s: Please select attached object index number...", caption);
			else format(AOE_STR, sizeof AOE_STR, "* %s: Please select attached object index number to %s...", caption, button1);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
		}
		case AOE_C_SLOT_USED: // Used slot list
		{
			for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
			{
				if(IsValidPlayerAttachedObject(playerid, i) == -1) format(AOE_STR2, sizeof AOE_STR2, "%s{FF3333}%d. None - (Not Used)\n", AOE_STR2, i);
				else if(!IsValidPlayerAttachedObject(playerid, i)) format(AOE_STR2, sizeof AOE_STR2, "%s{CCCCCC}%d. Unknown - Invalid attached object info\n", AOE_STR2, i);
				else format(AOE_STR2, sizeof AOE_STR2, "%s{FFFFFF}%d. %d - %s (Bone:%d)\n", AOE_STR2, i, PAO[playerid][i][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[playerid][i][AO_BONE_ID]), PAO[playerid][i][AO_BONE_ID]);
			}
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, AOE_STR2, button1, button2);
			if(!strcmp(button1, AOE_B_SELECT, true)) format(AOE_STR, sizeof AOE_STR, "* %s: Please select attached object index number...", caption);
			else format(AOE_STR, sizeof AOE_STR, "* %s: Please select attached object index number to %s...", caption, button1);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
		}
		case AOE_C_SLOT_ALL: // Used slot list + all
		{
			for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
			{
				if(IsValidPlayerAttachedObject(playerid, i) == -1) format(AOE_STR2, sizeof AOE_STR2, "%s{FF3333}%d. None - (Not Used)\n", AOE_STR2, i);
				else if(!IsValidPlayerAttachedObject(playerid, i))
				{
					format(AOE_STR2, sizeof AOE_STR2, "%s{808080}%d. Unknown - Invalid attached object info\n", AOE_STR2, i);
					slots++;
				}
				else
				{
					format(AOE_STR2, sizeof AOE_STR2, "%s{FFFFFF}%d. %d - %s (Bone:%d)\n", AOE_STR2, i, PAO[playerid][i][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[playerid][i][AO_BONE_ID]), PAO[playerid][i][AO_BONE_ID]);
					slots++;
				}
			}
			format(AOE_STR2, sizeof AOE_STR2, "%s{CCFFFF}%s all used attached object index (%d)", AOE_STR2, button1, slots);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, AOE_STR2, button1, button2);
			if(!strcmp(button1, AOE_B_SELECT, true)) format(AOE_STR, sizeof AOE_STR, "* %s: Please select attached object index number...", caption);
			else format(AOE_STR, sizeof AOE_STR, "* %s: Please select attached object index number to %s...", caption, button1);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
		}
		case AOE_C_REFRESH: // Target's used slot list
		{
			AOTarget = EPV[playerid][PAO_TARGET];
			for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
			{
				if(IsValidPlayerAttachedObject(AOTarget, i) == -1) format(AOE_STR2, sizeof AOE_STR2, "%s{FF3333}%d. None - (Not Used)\n", AOE_STR2, i);
				else if(!IsValidPlayerAttachedObject(AOTarget, i)) format(AOE_STR2, sizeof AOE_STR2, "%s{CCCCCC}%d. Unknown - Invalid attached object info\n", AOE_STR2, i);
				else format(AOE_STR2, sizeof AOE_STR2, "%s{FFFFFF}%d. %d - %s (Bone:%d)\n", AOE_STR2, i, PAO[AOTarget][i][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[AOTarget][i][AO_BONE_ID]), PAO[AOTarget][i][AO_BONE_ID]);
			}
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, AOE_STR2, button1, button2);
			format(AOE_STR, sizeof AOE_STR, "* Refresh Attached Object: Please select attached object index number from target player...", caption);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
		}
		case AOE_C_MODEL: // Object model input
		{
			format(AOE_STR, sizeof AOE_STR, "* %s: Please enter object model id/number...", caption);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, caption, AOE_I_ENTER_MODEL, button1, button2);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
		}
		case AOE_C_BONE: // Bone list
		{
			for(new i = 1; i <= MAX_ATTACHED_OBJECT_BONES; i++)
			{
				format(AOE_STR2, sizeof AOE_STR2, "%s%d. %s\n", AOE_STR2, i, GetAttachedObjectBoneName(i));
			}
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, AOE_STR2, button1, button2);
			format(AOE_STR, sizeof AOE_STR, "* %s: Please select attached object bone...", caption);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
		}
		case AOE_C_CREATE_FINAL: // Final create
		{
			format(AOE_STR2, sizeof AOE_STR2, "You've created your attached object\nat index number: %d\nModel: %d\nBone: %s (%d)\n\nDo you want to edit your attached object?", EPV[playerid][PAO_INDEX1],
			EPV[playerid][PAO_MODEL_ID], GetAttachedObjectBoneName(EPV[playerid][PAO_BONE_ID]), EPV[playerid][PAO_BONE_ID]);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR2, button1, button2);
		}
		case AOE_C_REMOVE_ALL: // Remove all
		{
			format(AOE_STR2, sizeof AOE_STR2, "You're about to remove all of your attached object(s)\nTotal: %d\nAre you sure you want to remove them?\n(This action can't be undone)", GetPlayerAttachedObjectsCount(playerid));
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR2, button1, button2);
		}
		case AOE_C_PROPERTIES: // View properties
		{
			AOSlot = EPV[playerid][PAO_INDEX1], AOTarget = EPV[playerid][PAO_TARGET];
			GetPlayerName(AOTarget, pName, sizeof pName);
			format(AOE_STR2, sizeof AOE_STR2, "Attached object index number %d properties...\n\nStatus: %s\nModel ID/Number/Type: %d\nBone: %s (%d)\n\nOffsets\nX Offset: %f\nY Offset: %f\nZ Offset: %f\n\nRotations\nX Rotation: %f\nY Rotation: %f\
			\nZ Rotation: %f\n\nScales\nX Scale: %f\nY Scale: %f\nZ Scale: %f\n\nMaterials\nColor 1: 0x%x (%i) {%06x}{A9C4E4}\nColor 2: 0x%x (%i) {%06x}{A9C4E4}\n\nSkin ID: %d\nTotal of %s's attached object(s): %d", AOSlot,
			((PAO[AOTarget][AOSlot][AO_STATUS] == 0) ? ("Invalid data") : ((PAO[AOTarget][AOSlot][AO_STATUS] == 1) ? ("Valid Data") : ("Editing"))), PAO[AOTarget][AOSlot][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[AOTarget][AOSlot][AO_BONE_ID]), PAO[AOTarget][AOSlot][AO_BONE_ID],
			PAO[AOTarget][AOSlot][AO_X], PAO[AOTarget][AOSlot][AO_Y], PAO[AOTarget][AOSlot][AO_Z], PAO[AOTarget][AOSlot][AO_RX], PAO[AOTarget][AOSlot][AO_RY], PAO[AOTarget][AOSlot][AO_RZ], PAO[AOTarget][AOSlot][AO_SX], PAO[AOTarget][AOSlot][AO_SY], PAO[AOTarget][AOSlot][AO_SZ],
			PAO[AOTarget][AOSlot][AO_MC1], PAO[AOTarget][AOSlot][AO_MC1], PAO[AOTarget][AOSlot][AO_MC1] & 0xFFFFFF, PAO[AOTarget][AOSlot][AO_MC2], PAO[AOTarget][AOSlot][AO_MC2], PAO[AOTarget][AOSlot][AO_MC2] & 0xFFFFFF, GetPlayerSkin(AOTarget), pName, GetPlayerAttachedObjectsCount(AOTarget));
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR2, (IsPlayerAdmin(playerid) ? button1 : button2), (IsPlayerAdmin(playerid) ? button2 : "")); // Only show close button for non-admin
			if(AOTarget == playerid) format(AOE_STR, sizeof AOE_STR, "* You're viewing your attached object properties from index number %d.", AOSlot);
			else format(AOE_STR, sizeof AOE_STR, "* You're viewing %s's attached object properties from index number %d.", pName, AOSlot);
			SendClientMessage(playerid, AOE_COLOR5, AOE_STR);
			if(IsPlayerAdmin(playerid)) SendClientMessage(playerid, AOE_COLOR0, AOE_M_OBJECT_DATA_PRINT);
		}
		case AOE_C_EDIT_PROPERTIES: // Edit properties
		{
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, caption, "Change index\nChange model\nChange bone\nChange X offset\nChange Y offset\nChange Z offset\n\
				Change X rotation\nChange Y rotation\nChange Z rotation\nChange X scale\nChange Y scale\nChange Z scale\nChange #1 material color\nChange #2 material color", button1, button2);
		}
		case AOE_C_EDIT_XYZ: // Edit property value
		{
			new xyz_selection[3];
			switch(EPV[playerid][PAO_EDITING])
			{
				case 3:
				{
					xyz_selection = "X";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_X];
				}
				case 4:
				{
					xyz_selection = "Y";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_Y];
				}
				case 5:
				{
					xyz_selection = "Z";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_Z];
				}
				case 6:
				{
					xyz_selection = "RX";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_RX];
				}
				case 7:
				{
					xyz_selection = "RY";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_RY];
				}
				case 8:
				{
					xyz_selection = "RZ";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_RZ];
				}
				case 9:
				{
					xyz_selection = "SX";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_SX];
				}
				case 10:
				{
					xyz_selection = "SY";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_SY];
				}
				case 11:
				{
					xyz_selection = "SZ";
					AOAxis = PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_SZ];
				}
				default: return;
			}
			format(AOE_STR2, sizeof AOE_STR2, "Current %s value is %.4f\nEnter a new value below:", xyz_selection, AOAxis);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, caption, AOE_STR2, button1, button2);
		}
		case AOE_C_EDIT_COLOR: // Edit color
		{
			switch(EPV[playerid][PAO_EDITING])
			{
				case 12:
				{
					format(AOE_STR2, sizeof AOE_STR2, "Current material color (#1) value is: 0x%x (%i) {%06x}{A9C4E4}\n\nEnter a new value below:",
						PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_MC1], PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_MC1], PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_MC1] & 0xFFFFFF);
				}
				case 13:
				{
					format(AOE_STR2, sizeof AOE_STR2, "Current material color (#2) value is: 0x%x (%i) {%06x}{A9C4E4}\n\nEnter a new value below:",
						PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_MC2], PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_MC2], PAO[playerid][EPV[playerid][PAO_INDEX1]][AO_MC2] & 0xFFFFFF);
				}
				default: return;
			}
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, caption, AOE_STR2, button1, button2);

		}
		case AOE_C_DUPLICATE_REPLACE: // Replace duplicate
		{
			format(AOE_STR, sizeof AOE_STR, "You already have attached object at index number %d!\nDo you want to replace it with attached object from slot %d?", EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_INDEX2]);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR, button1, button2);
		}
		case AOE_C_CREATE_REPLACE: // Replace create
		{
			format(AOE_STR, sizeof AOE_STR, "Sorry, attached object index number %d\nis already used, do you want to replace it?\n(This action can't be undone)", EPV[playerid][PAO_INDEX1]);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR, button1, button2);
		}
		case AOE_C_SET_INDEX_REPLACE: // Replace set index
		{
			format(AOE_STR, sizeof AOE_STR, "You already have attached object at index number %d!\nDo you want to replace it with attached object from slot %d?", EPV[playerid][PAO_INDEX1], EPV[playerid][PAO_INDEX2]);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR, button1, button2);
		}
		case AOE_C_REFRESH_REPLACE: // Replace refresh
		{
			AOSlot = EPV[playerid][PAO_INDEX1], AOTarget = EPV[playerid][PAO_TARGET];
			GetPlayerName(AOTarget, pName, sizeof pName);
			format(AOE_STR2, sizeof AOE_STR2, "You are about to replace your attached object,\nIndex: %d, Model: %d, Bone: %s (%d)\nwith %s (ID:%d)'s attached object,\nIndex: %d, Model: %d, Bone: %s (%d)\n\nContinue?", AOSlot, PAO[playerid][AOSlot][AO_MODEL_ID],
			GetAttachedObjectBoneName(PAO[playerid][AOSlot][AO_BONE_ID]), PAO[playerid][AOSlot][AO_BONE_ID], pName, AOTarget, AOSlot, PAO[AOTarget][AOSlot][AO_MODEL_ID], GetAttachedObjectBoneName(PAO[AOTarget][AOSlot][AO_BONE_ID]), PAO[AOTarget][AOSlot][AO_BONE_ID]);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR2, button1, button2);
			SendClientMessage(playerid, AOE_COLOR4, AOE_M_REFRESH_WARNING);
		}
		case AOE_C_LOAD_REPLACE: // Replace load
		{
			format(AOE_STR, sizeof AOE_STR, "You already have attached object at index number %d!\nDo you want to continue loading and replace it?", EPV[playerid][PAO_INDEX1]);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR, button1, button2);
		}
		case AOE_C_SAVE_REPLACE: // Replace save
		{
			format(AOE_STR2, sizeof AOE_STR2, "The file \"{FFFFFF}%s{A9C4E4}\" is already exist!\nDo you want to replace and overwrite it?\n(This action can't be undone)", EPV[playerid][PAO_NAME]);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption, AOE_STR2, button1, button2);
			SendClientMessage(playerid, AOE_COLOR0, AOE_M_OVERWRITE);
		}
		case AOE_C_SAVE: // Save
		{
			format(AOE_STR, sizeof AOE_STR, "* %s: Please enter attached object file name to save...", caption);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, caption, AOE_I_SAVE_NAME, button1, button2);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
		}
		case AOE_C_LOAD: // Load
		{
			format(AOE_STR, sizeof AOE_STR, "* %s: Please enter attached object file name to load...", caption);
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, caption, AOE_I_LOAD_NAME, button1, button2);
			SendClientMessage(playerid, AOE_COLOR0, AOE_STR);
		}
		case AOE_C_DELETE: // Delete
		{
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, caption, "Please enter attached object file name below\n\nName length must be 1-24 characters without extension\n\
				Valid characters are: A to Z or a to z, 0 to 9 and @, $, (, ), [, ], _, =\n\nPlease note that the file will be deleted permanently and can't be restored", button1, button2);
		}
	}
}

AOE_GameTextForPlayer(playerid, const string[])
	return GameTextForPlayer(playerid, string, 3000, 3);

AOE_CanEdit(playerid)
{
	new playerState = GetPlayerState(playerid);
	if(playerState == PLAYER_STATE_WASTED || playerState == PLAYER_STATE_SPECTATING)
	{
		SendClientMessage(playerid, AOE_COLOR1, AOE_M_CANT_EDIT);
		return false;
	}
	else if(EPV[playerid][PAO_EDITING] != 0)
	{
		SendClientMessage(playerid, AOE_COLOR4, AOE_M_EDIT_NOTICE);
		return false;
	}
	else return true;
}

AOE_HasFreeSlot(playerid)
{
	if(GetPlayerAttachedObjectsCount(playerid) == MAX_PLAYER_ATTACHED_OBJECTS)
	{
		SendClientMessage(playerid, AOE_COLOR4, AOE_M_NO_ENOUGH_SLOT);
		AOE_GameTextForPlayer(playerid, AOE_G_NO_ENOUGH_SLOT);
		SendClientMessage(playerid, AOE_COLOR0, AOE_M_MAX_SLOT_INFO);
		return false;
	}
	else return true;
}

AOE_HasSlot(playerid, index)
{
	if(!IsPlayerAttachedObjectSlotUsed(playerid, index))
	{
		format(AOE_STR, sizeof AOE_STR, "* Sorry, you don't have attached object at index number %d.", index);
		SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		format(AOE_STR, sizeof AOE_STR, "~r~~h~You have no attached object~n~~w~index number: %d", index);
		AOE_GameTextForPlayer(playerid, AOE_STR);
		return false;
	}
	return true;
}

AOE_TargetHasSlot(playerid, targetid, index)
{
	if(!IsPlayerAttachedObjectSlotUsed(targetid, index))
	{
		GetPlayerName(targetid, pName, sizeof pName);
		format(AOE_STR, sizeof AOE_STR, "* Sorry, %s (ID:%d) has no attached object at index number {FFFFFF}%d{%06x}.", pName, targetid, index, AOE_COLOR4 >>> 8);
		SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		return false;
	}
	return true;
}

AOE_HasAttachedObject(playerid)
{
	if(GetPlayerAttachedObjectsCount(playerid) == 0)
	{
		SendClientMessage(playerid, AOE_COLOR4, AOE_M_NO_ATTACHED_OBJECT);
		AOE_GameTextForPlayer(playerid, AOE_G_NO_ATTACHED_OBJECT);
		return false;
	}
	return true;
}

AOE_EnteredValidSlot(playerid, index)
{
	if(!IsValidAttachedObjectSlot(index))
	{
		format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object index number (%d).", index);
		SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		AOE_GameTextForPlayer(playerid, AOE_G_INVALID_SLOT);
		return false;
	}
	return true;
}

AOE_EnteredValidModel(playerid, modelid)
{
	if(!IsValidObjectModel(modelid))
	{
		format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid object model number (%d).", modelid);
		SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		AOE_GameTextForPlayer(playerid, AOE_G_INVALID_MODEL);
		return false;
	}
	return true;
}

AOE_EnteredValidBone(playerid, const bone[])
{
	if(!IsValidAttachedObjectBoneName(bone))
	{
		format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object bone name/number (%s).", bone);
		SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		AOE_GameTextForPlayer(playerid, AOE_G_INVALID_BONE);
		return false;
	}
	return true;
}

AOE_EnteredValidFileName(playerid, const filename[])
{
	if(!IsValidFileName(filename))
	{
		format(AOE_STR, sizeof AOE_STR, "* Sorry, you've entered invalid attached object(s) file name ({FFFFFF}%s{%06x}).", filename, AOE_COLOR4 >>> 8);
		SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		SendClientMessage(playerid, AOE_COLOR4, AOE_M_VALID_NAME_INFO1);
		SendClientMessage(playerid, AOE_COLOR4, AOE_M_VALID_NAME_INFO2);
		AOE_GameTextForPlayer(playerid, AOE_G_INVALID_FILE_NAME);
		return false;
	}
	return true;
}

AOE_EnteredExistedFileName(playerid, filename[])
{
	if(!fexist(filename))
	{
		new len = strlen(filename);
		strdel(filename, len-(strlen(AOE_FILE_NAME)-2), len);
		format(AOE_STR, sizeof AOE_STR, "* Sorry, attached object(s) file \"{FFFFFF}%s{%06x}\" does not exist.", filename, AOE_COLOR4 >>> 8);
		SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		AOE_GameTextForPlayer(playerid, AOE_G_FILE_NOT_EXIST);
		return false;
	}
	return true;
}

AOE_EnteredNonExistFileName(playerid, filename[])
{
	if(fexist(filename))
	{
		if(IsPlayerAdmin(playerid)) AOE_ShowPlayerDialog(playerid, AOE_C_SAVE_REPLACE, AOE_D_SAVE_REPLACE, AOE_T_SAVE#AOE_T_REPLACE, AOE_B_YES, AOE_B_BACK);
		else
		{
			new len = strlen(filename);
			strdel(filename, len-(strlen(AOE_FILE_NAME)-2), len);
			format(AOE_STR, sizeof AOE_STR, "* Sorry, attached object file \"{FFFFFF}%s{%06x}\" already exists.", filename, AOE_COLOR4 >>> 8);
			SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
			AOE_GameTextForPlayer(playerid, AOE_G_FILE_EXISTED);
		}
		return false;
	}
	return true;
}

AOE_EnteredNonExistFileName2(playerid, filename[])
{
	if(fexist(filename))
	{
		if(IsPlayerAdmin(playerid)) AOE_ShowPlayerDialog(playerid, AOE_C_SAVE_REPLACE, AOE_D_SAVE2_REPLACE, AOE_T_SAVE_SET#AOE_T_REPLACE, AOE_B_YES, AOE_B_BACK);
		else
		{
			new len = strlen(filename);
			strdel(filename, len-(strlen(AOE_FILE_NAME)-2), len);
			format(AOE_STR, sizeof AOE_STR, "* Sorry, attached object(s) set file \"{FFFFFF}%s{%06x}\" already exists.", filename, AOE_COLOR4 >>> 8);
			SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
			AOE_GameTextForPlayer(playerid, AOE_G_FILE_EXISTED);
		}
		return false;
	}
	return true;
}

AOE_SavePlayerAttachedObject(playerid, const filename[], index, const comment[] = "", &Float:filelen) // MAX_PLAYER_ATTACHED_OBJECTS for all slot
{
	if(!IsPlayerConnected(playerid)) return INVALID_PLAYER_ID;
	new File:SAO = fopen(filename, io_write), slots;
	if(SAO)
	{
		new year, month, day, hour, minute, second, AOE_STR2[256];
		GetPlayerName(playerid, pName, sizeof pName);
		getdate(year, month, day);
		gettime(hour, minute, second);
		if(isnull(comment))
		{
			format(AOE_STR2, sizeof AOE_STR2, "// Created by %s (Skin ID %d) on %02d/%02d/%d %02d:%02d:%02d (server time)", pName, GetPlayerSkin(playerid), day, month, year, hour, minute, second);
			fwrite(SAO, AOE_STR2);
		}
		new i = ((index == MAX_PLAYER_ATTACHED_OBJECTS) ? (0) : (index));
		SaveLoop:
		{
			if(IsValidPlayerAttachedObject(playerid, i) == 1)
			{
				#if AOE_SMALLER_SAVE true
				if(PAO[playerid][i][AO_MC1] == 0 && PAO[playerid][i][AO_MC2] == 0)
				{
					if(PAO[playerid][i][AO_SX] == 1.0 && PAO[playerid][i][AO_SY] == 1.0 && PAO[playerid][i][AO_SZ] == 1.0)
					{
						if(PAO[playerid][i][AO_RX] == 0.0 && PAO[playerid][i][AO_RY] == 0.0 && PAO[playerid][i][AO_RZ] == 0.0)
						{
							if(PAO[playerid][i][AO_X] == 0.0 && PAO[playerid][i][AO_Y] == 0.0 && PAO[playerid][i][AO_Z] == 0.0)
							{
								format(AOE_STR2, sizeof AOE_STR2, "\r\nSetPlayerAttachedObject(playerid, %d, %d, %d);", i, PAO[playerid][i][AO_MODEL_ID], PAO[playerid][i][AO_BONE_ID]);
							}
							else
							{
								format(AOE_STR2, sizeof AOE_STR2, "\r\nSetPlayerAttachedObject(playerid, %d, %d, %d, %f, %f, %f);", i,
									PAO[playerid][i][AO_MODEL_ID], PAO[playerid][i][AO_BONE_ID],PAO[playerid][i][AO_X], PAO[playerid][i][AO_Y], PAO[playerid][i][AO_Z]);
							}
						}
						else
						{
							format(AOE_STR2, sizeof AOE_STR2, "\r\nSetPlayerAttachedObject(playerid, %d, %d, %d, %f, %f, %f, %f, %f, %f);", i, PAO[playerid][i][AO_MODEL_ID], PAO[playerid][i][AO_BONE_ID],
							PAO[playerid][i][AO_X], PAO[playerid][i][AO_Y], PAO[playerid][i][AO_Z], PAO[playerid][i][AO_RX], PAO[playerid][i][AO_RY], PAO[playerid][i][AO_RZ]);
						}
					}
					else
					{
						format(AOE_STR2, sizeof AOE_STR2, "\r\nSetPlayerAttachedObject(playerid, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f);", i,
							PAO[playerid][i][AO_MODEL_ID], PAO[playerid][i][AO_BONE_ID], PAO[playerid][i][AO_X], PAO[playerid][i][AO_Y], PAO[playerid][i][AO_Z],
							PAO[playerid][i][AO_RX], PAO[playerid][i][AO_RY], PAO[playerid][i][AO_RZ], PAO[playerid][i][AO_SX], PAO[playerid][i][AO_SY], PAO[playerid][i][AO_SZ]);
					}
				}
				else
				{
				#endif
					format(AOE_STR2, sizeof AOE_STR2, "\r\nSetPlayerAttachedObject(playerid, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, 0x%x, 0x%x);", i, PAO[playerid][i][AO_MODEL_ID], PAO[playerid][i][AO_BONE_ID],
						PAO[playerid][i][AO_X], PAO[playerid][i][AO_Y], PAO[playerid][i][AO_Z], PAO[playerid][i][AO_RX], PAO[playerid][i][AO_RY], PAO[playerid][i][AO_RZ],
						PAO[playerid][i][AO_SX], PAO[playerid][i][AO_SY], PAO[playerid][i][AO_SZ], PAO[playerid][i][AO_MC1], PAO[playerid][i][AO_MC2]);
				#if AOE_SMALLER_SAVE true
				}
				#endif
				fwrite(SAO, AOE_STR2);
				slots++;
			}
		}
		if(index == MAX_PLAYER_ATTACHED_OBJECTS && i < MAX_PLAYER_ATTACHED_OBJECTS)
		{
			i++;
			goto SaveLoop;
		}
		fclose(SAO);
		if(fexist(filename))
		{
			if(!slots) fremove(filename);
			else
			{
				SAO = fopen(filename, io_read);
				if(SAO)
				{
					filelen = float(flength(SAO))/1024.0;
					fclose(SAO);
				}
			}
		}
	}
	return slots;
}

AOE_LoadPlayerAttachedObject(playerid, const filename[], index, const comment[])
{
	#pragma unused comment
	if(!IsPlayerConnected(playerid)) return INVALID_PLAYER_ID;
	if(!fexist(filename)) return 0;
	new File:LAO = fopen(filename, io_read), slots;
	if(LAO)
	{
		AOComment[0] = EOS;
		new idx, replaced, LAOD[E_ATTACHED_OBJECT], AOE_STR2[256];
		while(fread(LAO, AOE_STR2) && slots != MAX_PLAYER_ATTACHED_OBJECTS)
		{
			if(!unformat(AOE_STR2, "'SetPlayerAttachedObject'P<();,>{s[3]}{s[32]}dddF(0.0)F(0.0)F(0.0)F(0.0)F(0.0)F(0.0)F(1.0)F(1.0)F(1.0)X(0)X(0)", idx, LAOD[AO_MODEL_ID], LAOD[AO_BONE_ID],
				LAOD[AO_X], LAOD[AO_Y], LAOD[AO_Z], LAOD[AO_RX], LAOD[AO_RY], LAOD[AO_RZ], LAOD[AO_SX], LAOD[AO_SY], LAOD[AO_SZ], LAOD[AO_MC1], LAOD[AO_MC2]))
			{
				if(IsValidAttachedObjectSlot(idx) && IsValidObjectModel(LAOD[AO_MODEL_ID]) && IsValidAttachedObjectBone(LAOD[AO_BONE_ID]))
				{
					if(index == MAX_PLAYER_ATTACHED_OBJECTS)
					{
						if(IsPlayerAttachedObjectSlotUsed(playerid, idx))
						{
							switch(replaced++)
							{
								case 0: format(AOE_STR, sizeof AOE_STR, "** Attached object index number %d", idx);
								default: format(AOE_STR, sizeof AOE_STR, "%s, %d", AOE_STR, idx);
							}
						}
						slots += UpdatePlayerAttachedObjectEx(playerid, idx, LAOD[AO_MODEL_ID], LAOD[AO_BONE_ID], LAOD[AO_X], LAOD[AO_Y], LAOD[AO_Z],
									LAOD[AO_RX], LAOD[AO_RY], LAOD[AO_RZ], LAOD[AO_SX], LAOD[AO_SY], LAOD[AO_SZ], LAOD[AO_MC1], LAOD[AO_MC2]);
					}
					else
					{
						if(index == idx)
						{
							slots += UpdatePlayerAttachedObjectEx(playerid, idx, LAOD[AO_MODEL_ID], LAOD[AO_BONE_ID], LAOD[AO_X], LAOD[AO_Y], LAOD[AO_Z],
										LAOD[AO_RX], LAOD[AO_RY], LAOD[AO_RZ], LAOD[AO_SX], LAOD[AO_SY], LAOD[AO_SZ], LAOD[AO_MC1], LAOD[AO_MC2]);
							break;
						}
					}
				}
			}
			else if(!unformat(AOE_STR2, "'/*'s[251]'*/'", comment) || !unformat(AOE_STR2, "'//'s[253]", comment)) { }
		}
		if(0 < replaced < MAX_PLAYER_ATTACHED_OBJECTS)
		{
			format(AOE_STR, sizeof AOE_STR, "%s was replaced (Total: %d).", AOE_STR, replaced);
			SendClientMessage(playerid, AOE_COLOR4, AOE_STR);
		}
		fclose(LAO);
	}
	return slots;
}
//------------------------------------------------------------------------------
UpdatePlayerAttachedObject(playerid, index, modelid, boneid)
	return UpdatePlayerAttachedObjectEx(playerid, index, modelid, boneid, PAO[playerid][index][AO_X], PAO[playerid][index][AO_Y], PAO[playerid][index][AO_Z], PAO[playerid][index][AO_RX], PAO[playerid][index][AO_RY], PAO[playerid][index][AO_RZ],
	PAO[playerid][index][AO_SX], PAO[playerid][index][AO_SY], PAO[playerid][index][AO_SZ], PAO[playerid][index][AO_MC1], PAO[playerid][index][AO_MC2]);

UpdatePlayerAttachedObjectEx(playerid, index, modelid, boneid, Float:fOffsetX = 0.0, Float:fOffsetY = 0.0, Float:fOffsetZ = 0.0, Float:fRotX = 0.0, Float:fRotY = 0.0, Float:fRotZ = 0.0, Float:fScaleX = 1.0, Float:fScaleY = 1.0, Float:fScaleZ = 1.0, materialcolor1 = 0, materialcolor2 = 0)
{
	if(IsValidAttachedObjectSlot(index) || IsValidObjectModel(modelid) || IsValidAttachedObjectBone(boneid))
	{
		if(SetPlayerAttachedObject(playerid, index, modelid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ, materialcolor1, materialcolor2))
		{
			PAO[playerid][index][AO_MODEL_ID] = modelid;
			PAO[playerid][index][AO_BONE_ID] = boneid;
			PAO[playerid][index][AO_X] = fOffsetX, PAO[playerid][index][AO_Y] = fOffsetY, PAO[playerid][index][AO_Z] = fOffsetZ;
			PAO[playerid][index][AO_RX] = fRotX, PAO[playerid][index][AO_RY] = fRotY, PAO[playerid][index][AO_RZ] = fRotZ;
			PAO[playerid][index][AO_SX] = fScaleX, PAO[playerid][index][AO_SY] = fScaleY, PAO[playerid][index][AO_SZ] = fScaleZ;
			PAO[playerid][index][AO_MC1] = materialcolor1, PAO[playerid][index][AO_MC2] = materialcolor2;
			PAO[playerid][index][AO_STATUS] = 1;
			return 1;
		}
	}
	return 0;
}

DuplicatePlayerAttachedObject(playerid, fromindex, asindex)
{
	if(IsValidAttachedObjectSlot(fromindex) && IsValidAttachedObjectSlot(asindex))
	{
		return UpdatePlayerAttachedObjectEx(playerid, asindex, PAO[playerid][fromindex][AO_MODEL_ID], PAO[playerid][fromindex][AO_BONE_ID], PAO[playerid][fromindex][AO_X], PAO[playerid][fromindex][AO_Y], PAO[playerid][fromindex][AO_Z],
		PAO[playerid][fromindex][AO_RX], PAO[playerid][fromindex][AO_RY], PAO[playerid][fromindex][AO_RZ], PAO[playerid][fromindex][AO_SX], PAO[playerid][fromindex][AO_SY], PAO[playerid][fromindex][AO_SZ], PAO[playerid][fromindex][AO_MC1], PAO[playerid][fromindex][AO_MC2]);
	}
	return 0;
}

ChangePlayerAttachedObjectIndex(playerid, fromindex, toindex)
{
	if(IsValidAttachedObjectSlot(toindex) && IsValidPlayerAttachedObject(playerid, fromindex))
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, fromindex)) RemovePlayerAttachedObject(playerid, fromindex), PAO[playerid][fromindex][AO_STATUS] = 0;
		return UpdatePlayerAttachedObjectEx(playerid, toindex, PAO[playerid][fromindex][AO_MODEL_ID], PAO[playerid][fromindex][AO_BONE_ID], PAO[playerid][fromindex][AO_X], PAO[playerid][fromindex][AO_Y], PAO[playerid][fromindex][AO_Z],
		PAO[playerid][fromindex][AO_RX], PAO[playerid][fromindex][AO_RY], PAO[playerid][fromindex][AO_RZ], PAO[playerid][fromindex][AO_SX], PAO[playerid][fromindex][AO_SY], PAO[playerid][fromindex][AO_SZ], PAO[playerid][fromindex][AO_MC1], PAO[playerid][fromindex][AO_MC2]);
	}
	return 0;
}

RefreshPlayerAttachedObject(playerid, forplayerid, index)
{
	if(IsValidPlayerAttachedObject(playerid, index) == 1)
	{
		return UpdatePlayerAttachedObjectEx(forplayerid, index, PAO[playerid][index][AO_MODEL_ID], PAO[playerid][index][AO_BONE_ID], PAO[playerid][index][AO_X], PAO[playerid][index][AO_Y], PAO[playerid][index][AO_Z],
		PAO[playerid][index][AO_RX], PAO[playerid][index][AO_RY], PAO[playerid][index][AO_RZ], PAO[playerid][index][AO_SX], PAO[playerid][index][AO_SY], PAO[playerid][index][AO_SZ], PAO[playerid][index][AO_MC1], PAO[playerid][index][AO_MC2]);
	}
	return 0;
}

RestorePlayerAttachedObject(playerid, index)
{
	if(IsValidAttachedObjectSlot(index) && IsValidObjectModel(PAO[playerid][index][AO_MODEL_ID]) && IsValidAttachedObjectBone(PAO[playerid][index][AO_BONE_ID]))
	{
		if(SetPlayerAttachedObject(playerid, index, PAO[playerid][index][AO_MODEL_ID], PAO[playerid][index][AO_BONE_ID], PAO[playerid][index][AO_X], PAO[playerid][index][AO_Y], PAO[playerid][index][AO_Z],
			PAO[playerid][index][AO_RX], PAO[playerid][index][AO_RY], PAO[playerid][index][AO_RZ], PAO[playerid][index][AO_SX], PAO[playerid][index][AO_SY], PAO[playerid][index][AO_SZ], PAO[playerid][index][AO_MC1], PAO[playerid][index][AO_MC2]))
		{
			PAO[playerid][index][AO_STATUS] = 1;
			return 1;
		}
	}
	return 0;
}

RemovePlayerAttachedObjectEx(playerid, index) // MAX_PLAYER_ATTACHED_OBJECTS for all slot
{
	new attachedobjectsremoved;
	if(index == MAX_PLAYER_ATTACHED_OBJECTS)
	{
		for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
		{
			if(IsPlayerAttachedObjectSlotUsed(playerid, i))
			{
				attachedobjectsremoved += RemovePlayerAttachedObject(playerid, i);
				if(PAO[playerid][i][AO_STATUS] == 0)
				{
					AOE_UnsetValues(playerid, i);
				}
				else
				{
					PAO[playerid][i][AO_STATUS] = 0;
					EPV[playerid][PAO_LAST_REMOVED] = i;
				}
			}
		}
	}
	else
	{
		if(!IsValidAttachedObjectSlot(index)) return 0;
		if(IsPlayerAttachedObjectSlotUsed(playerid, index))
		{
			attachedobjectsremoved += RemovePlayerAttachedObject(playerid, index);
			if(PAO[playerid][index][AO_STATUS] == 0)
			{
				AOE_UnsetValues(playerid, index);
			}
			else
			{
				PAO[playerid][index][AO_STATUS] = 0;
				EPV[playerid][PAO_LAST_REMOVED] = index;
			}
		}
	}
	return attachedobjectsremoved;
}

GetAttachedObjectBoneName(boneid)
{
	new attachedobjectbonename[MAX_ATTACHED_OBJECT_BONE_NAME];
	if(!IsValidAttachedObjectBone(boneid)) attachedobjectbonename = "Invalid Bone ID";
	else attachedobjectbonename = AttachedObjectBones[boneid-1];
	return attachedobjectbonename;
}

GetAttachedObjectBone(const bonename[])
{
	if(!IsValidAttachedObjectBoneName(bonename)) return 0;
	if(IsNumeric(bonename)) return strval(bonename);
	for(new i = 0; i < sizeof AttachedObjectBones; i++)
	{
		if(strfind(AttachedObjectBones[i], bonename, true) != -1) return i+1;
	}
	return 0;
}

GetPlayerAttachedObjectsCount(playerid)
{
	new playerattachedobjectscount;
	for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		playerattachedobjectscount += IsPlayerAttachedObjectSlotUsed(playerid, i);
	}
	return playerattachedobjectscount;
}

IsValidPlayerAttachedObject(playerid, index)
{
	if(!IsPlayerConnected(playerid)) return INVALID_PLAYER_ID; // Player is offline
	if(!IsPlayerAttachedObjectSlotUsed(playerid, index)) return -1; // Not used
	if(!IsValidAttachedObjectSlot(index) || !IsValidObjectModel(PAO[playerid][index][AO_MODEL_ID]) || !IsValidAttachedObjectBone(PAO[playerid][index][AO_BONE_ID]) || !PAO[playerid][index][AO_STATUS]) return 0; // Invalid data
	return 1;
}

IsValidAttachedObjectSlot(slotid)
	return (0 <= slotid < MAX_PLAYER_ATTACHED_OBJECTS);

IsValidAttachedObjectBone(boneid)
	return (1 <= boneid <= MAX_ATTACHED_OBJECT_BONES);

IsValidAttachedObjectBoneName(const bonename[])
{
	new len = strlen(bonename);
	if(len < 1 || len >= MAX_ATTACHED_OBJECT_BONE_NAME) return false;
	for(new i = 0; i < sizeof AttachedObjectBones; i++)
	{
		if(!strcmp(bonename, AttachedObjectBones[i], true)) return true;
	}
	if(IsNumeric(bonename) && IsValidAttachedObjectBone(strval(bonename))) return true;
	return false;
}

IsValidComment(const comment[])
{
	new len = strlen(comment);
	if(len < 1 || len >= sizeof AOComment) return false;
	for(new j = 0; j < len; j++)
	{
		if((comment[j] < 'A' || comment[j] > 'Z') && (comment[j] < 'a' || comment[j] > 'z') && (comment[j] < '0' || comment[j] > '9')
			&& comment[j] != ' ') return false;
	}
	return true;
}

IsValidFileName(const filename[])
{
	new len = strlen(filename);
	if(!(1 <= len <= 24)) return false;
	for(new j = 0; j < len; j++)
	{
		if((filename[j] < 'A' || filename[j] > 'Z') && (filename[j] < 'a' || filename[j] > 'z') && (filename[j] < '0' || filename[j] > '9')
			&& (filename[j] != '@' || filename[j] != '$' || filename[j] != '(' || filename[j] != ')' || filename[j] != '['
			|| filename[j] != ']' || filename[j] != '_' || filename[j] != '=')) return false;
	}
	return true;
}

IsValidObjectModel(modelid)
{
	return((321 <= modelid <= 328)
	|| (330 <= modelid <= 331)
	|| (333 <= modelid <= 339)
	|| (341 <= modelid <= 373)
	|| (615 <= modelid <= 698)
	|| (700 <= modelid <= 1193)
	|| (1207 <= modelid <= 1698)
	|| (1700 <= modelid <= 4762)
	|| (4806 <= modelid <= 6525)
	|| (6863 <= modelid <= 11681)
	|| (11682 <= modelid <= 12799) // SA:MP 0.3.7 Objects
	|| (12800 <= modelid <= 13890)
	|| (14383 <= modelid <= 14898)
	|| (14900 <= modelid <= 14903)
	|| (15025 <= modelid <= 15064)
	|| (15065 <= modelid <= 15999) // SA:MP Custom IMG Objects
	|| (16000 <= modelid <= 16790)
	|| (17000 <= modelid <= 18630)
	|| (18631 <= modelid <= 19999)); // SA:MP 0.3.7 Objects
}

IsNumeric(const string[])
{
	new len = strlen(string);
	if(len == 0) return false;
	for(new i = 0; i < len; i++)
	{
		if(string[i] > '9' || string[i] < '0') return false;
	}
	return true;
}
