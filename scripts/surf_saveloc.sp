/*
Author: Nyaaaa (STEAM_0:1:37408546)
Description: Saveloc system to help with practicing surf/bhop maps.
Based on tm-saveloc by horsefeathers.
*/

#include <sourcemod>
#include <sdktools>

#define DEFAULT_MAX_LOCS "250"
#define DEFAULT_CHAT_TAG "[SM] "

//float vectors saving the positions, angles, and velocities of each client
//add one because client indexes start on 1 (0 is server)

ConVar g_Convar_MaxLocs;
ConVar g_Convar_ChatTag;

ArrayList g_Array_posData;
ArrayList g_Array_angData;
ArrayList g_Array_velData;

char g_chatTag[128];
int locCount = 0;

//plugin info
public Plugin:myinfo =
{
	name = "surf-Saveloc",
	author = "Nyaaaa~ [U:1:74817093]",
	description = "Surf/Bhop saveloc plugin.",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	RegConsoleCmd("sm_saveloc", Command_SaveLoc);
	RegConsoleCmd("sm_tele", Command_Teleport);

	g_Convar_MaxLocs = CreateConVar("saveloc_maxlocations", DEFAULT_MAX_LOCS, "Maximum number of save locations. Set to -1 to disable limit and 0 to disable saveloc entirely.", FCVAR_NONE, true, -1.0, false);
	g_Convar_ChatTag = CreateConVar("saveloc_chattag", DEFAULT_CHAT_TAG, "Tag to use before all output in chat. If using a tag, leave a blank space at the end.", FCVAR_NONE)

	//create config files in cfg/sourcemod/
	AutoExecConfig(true, "saveloc_config");

	//Each array will store arrays of size 3
	g_Array_posData = new ArrayList(3);
	g_Array_angData = new ArrayList(3);
	g_Array_velData = new ArrayList(3);

	g_Convar_ChatTag.GetString(g_chatTag, 128);
}

public OnMapEnd()
{
	resetData();
}

//command callbacks
public Action:Command_SaveLoc(client, args)
{
	if(g_Convar_MaxLocs == 0.0){
		PrintToChat(client, "%sSaveloc is currently disabled!", g_chatTag);
	}
	//check if player is alive
	if(client>0&&IsPlayerAlive(client))
	{
		float origin[3];
		GetClientAbsOrigin(client, origin);//save position
		float angles[3];
		GetClientEyeAngles(client, angles);//save angles
		float velocity[3];
		GetClientVelocity(client, velocity);//save velocity - internal

		if(g_Convar_MaxLocs != -1.0 && locCount >= g_Convar_MaxLocs){
			PrintToChat(client, "%sMaximum number of savelocs reached (%d)!", g_chatTag, g_Convar_MaxLocs);
			return Plugin_Handled;
		}

		g_Array_posData.PushArray(origin);
		g_Array_angData.PushArray(angles);
		g_Array_velData.PushArray(velocity);

		locCount ++;
		//debug
		//PrintToConsole(client, "save vel: %f, %f, %f",
			//velData[client][0],velData[client][1],velData[client][2]);

		PrintToChat(client, "%sLocation #%d Saved.", g_chatTag, locCount);//notify client
	}
	else//print out error and exit
	{
		PrintToChat(client, "%sMust be alive to Saveloc!", g_chatTag);
	}
	return Plugin_Handled;
}
public Action:Command_Teleport(client, args)
{
	if(args < 1){
		PrintToChat(client, "%sUsage: sm_tele #<loc num>", g_chatTag);
		return Plugin_Handled;
	}
	char arg[5];
  GetCmdArg(1, arg, sizeof(arg));
  int locationNum = StringToInt(arg);

	if(!locationNum || locationNum > locCount)
	{
		PrintToChat(client, "%sLocation not found.", g_chatTag);
		return Plugin_Handled;
	}

	//check if player is alive
	if(client>0&&IsPlayerAlive(client))
	{
		//check if any location was saved
		float pos[3];
		float ang[3];
		float vel[3];

		//Get From array at number provided-1 as array starts at 0
		GetArrayArray(g_Array_posData, locationNum-1, pos);
		GetArrayArray(g_Array_angData, locationNum-1, ang);
		GetArrayArray(g_Array_velData, locationNum-1, vel);

		if((GetVectorDistance(pos,NULL_VECTOR) > 0.00)&&
		   (GetVectorDistance(ang,NULL_VECTOR) > 0.00))
		{
			new Float:newVel[3];
			TeleportEntity(client, pos, ang, vel);
			GetClientVelocity(client,newVel);

			PrintToChat(client, "%sLoaded location #%d.", g_chatTag, locationNum);

			//debug
			//PrintToConsole(client, "tele vel: %f, %f, %f", vel[0],vel[1],vel[2]);
		}
		else//print error and exit
		{
			PrintToChat(client, "%sNo Saveloc found.", g_chatTag);
		}
	}
	else//print error and exit
	{
		PrintToChat(client,"%sMust be alive to Saveloc!", g_chatTag);
	}
	return Plugin_Handled;
}
GetClientVelocity(client, Float:vel[3])
{
	//dig into the entity properties for the client
	vel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	vel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
}
resetData()
{
	ClearArray(g_Array_posData);
	ClearArray(g_Array_angData);
	ClearArray(g_Array_velData);
}
