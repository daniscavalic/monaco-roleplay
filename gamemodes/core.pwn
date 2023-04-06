/**
TODO:
 */

#define YSI_YES_HEAP_MALLOC

#define CGEN_MEMORY 60000

#include <a_samp>
#include <a_actor>
#include <a_objects>
#include <a_players>
#include <a_vehicles>
#include <ysilib\YSI_Coding\y_hooks>
#include <ysilib\YSI_Coding\y_va>
#include <ysilib\YSI_Core\y_utils.inc>
#include <ysilib\YSI_Storage\y_ini>
#include <ysilib\YSI_Coding\y_timers>
#include <ysilib\YSI_Visual\y_commands>
#include <ysilib\YSI_Data\y_foreach>
#include <ysilib\YSI_Data\y_iterate>
#include <sscanf2>
#include <streamer>
#include <mapfix>
#include <easyDialog>
#include <formatex>
#include <distance>

// - assets
#include "utils/main.pwn"
#include "assets/stock.pwn"
//-
#include "assets/end/do-not-look"

static stock const USER_PATH[64] = "/Users/%s.ini";

#define	 	SECONDS_TO_LOGIN 		30
#define 	DEFAULT_POS_X 			1958.3783
#define 	DEFAULT_POS_Y 			1343.1572
#define 	DEFAULT_POS_Z 			15.3746
#define 	DEFAULT_POS_A 			270.1425
const 		MAX_PASSWORD_LENGTH = 64;
const 		MIN_PASSWORD_LENGTH = 6;
const 		MAX_LOGIN_ATTEMPTS = 	3;

enum
{
	e_SPAWN_TYPE_REGISTER = 1,
    e_SPAWN_TYPE_LOGIN
};

enum E_PLAYERS
{
	ORM: ORM_ID,

	ID,
	Name[MAX_PLAYER_NAME],
	Password[65],
	Salt[17],
	AdminLevel,
	Kills,
	Deaths,
	Float: X_Pos,
	Float: Y_Pos,
	Float: Z_Pos,
	Float: A_Pos,
	Interior,

	bool: IsLoggedIn,
	LoginAttempts,
	LoginTimer
};
new Player[MAX_PLAYERS][E_PLAYERS],
	g_MysqlRaceCheck[MAX_PLAYERS];

static
    player_Score[MAX_PLAYERS],
	player_Skin[MAX_PLAYERS],
    player_Money[MAX_PLAYERS],
	player_Staff[MAX_PLAYERS];

new stfveh[MAX_PLAYERS] = { INVALID_VEHICLE_ID, ... };

main()
{
    print("-                                     -");
	print(" Founder : Nickname");
	print(" Version : 1.0 - Naziv");
	print(" Credits : realnaith for Scripting ");
	print(" Frontend : ");
	print("-                                     -");
	print("> Gamemode Starting...");
	print(">> myproject Gamemode Started");
    print("-                                     -");
}

#define PRESSED(%0) \
    ( newkeys & %0 == %0 && oldkeys & %0 != %0 )

public OnGameModeInit()
{
	DisableInteriorEnterExits();
	ManualVehicleEngineAndLights();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	SetNameTagDrawDistance(20.0);
	LimitGlobalChatRadius(20.0);
	AllowInteriorWeapons(1);
	EnableVehicleFriendlyFire();
	EnableStuntBonusForAll(0);

	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

	return 1;
}

public OnPlayerConnect(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	SetPlayerColor(playerid, x_white);
	LoadPlayer(playerid);

	stfveh[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

LoadPlayer(playerid) {
	g_MysqlRaceCheck[playerid]++;

	// reset player data
	static const empty_player[E_PLAYERS];
	Player[playerid] = empty_player;

	GetPlayerName(playerid, Player[playerid][Name], MAX_PLAYER_NAME);

	// create orm instance and register all needed variables
	new ORM: ormid = Player[playerid][ORM_ID] = orm_create("players", Database);

	orm_addvar_int(ormid, Player[playerid][ID], "id");
	orm_addvar_string(ormid, Player[playerid][Name], MAX_PLAYER_NAME, "username");
	orm_addvar_string(ormid, Player[playerid][Password], 65, "password");
	orm_addvar_string(ormid, Player[playerid][Salt], 17, "salt");
	orm_addvar_int(ormid, Player[playerid][AdminLevel], "admin");
	orm_addvar_int(ormid, Player[playerid][Kills], "kills");
	orm_addvar_int(ormid, Player[playerid][Deaths], "deaths");
	orm_addvar_float(ormid, Player[playerid][X_Pos], "x");
	orm_addvar_float(ormid, Player[playerid][Y_Pos], "y");
	orm_addvar_float(ormid, Player[playerid][Z_Pos], "z");
	orm_addvar_float(ormid, Player[playerid][A_Pos], "angle");
	orm_addvar_int(ormid, Player[playerid][Interior], "interior");
	orm_setkey(ormid, "username");

	// tell the orm system to load all data, assign it to our variables and call our callback when ready
	orm_load(ormid, "OnPlayerDataLoaded", "dd", playerid, g_MysqlRaceCheck[playerid]);
}

public OnPlayerDisconnect(playerid, reason)
{
	OnPlayerExitCleanup(playerid, reason);
	DestroyVehicle(stfveh[playerid]);
	stfveh[playerid] = INVALID_PLAYER_ID;

	return 1;
}

// ====================================================================================================================== //

OnPlayerExitCleanup(playerid, reason) {
	g_MysqlRaceCheck[playerid]++;

	UpdatePlayerData(playerid, reason);
	if (Player[playerid][LoginTimer])
	{
		KillTimer(Player[playerid][LoginTimer]);
		Player[playerid][LoginTimer] = 0;
	}
	Player[playerid][IsLoggedIn] = false;
}

forward OnPlayerDataLoaded(playerid, race_check);
public OnPlayerDataLoaded(playerid, race_check)
{
	/*	race condition check:
		player A connects -> SELECT query is fired -> this query takes very long
		while the query is still processing, player A with playerid 2 disconnects
		player B joins now with playerid 2 -> our laggy SELECT query is finally finished, but for the wrong player
		what do we do against it?
		we create a connection count for each playerid and increase it everytime the playerid connects or disconnects
		we also pass the current value of the connection count to our OnPlayerDataLoaded callback
		then we check if current connection count is the same as connection count we passed to the callback
		if yes, everything is okay, if not, we just kick the player
	*/
	if (race_check != g_MysqlRaceCheck[playerid]) return Kick(playerid);

	orm_setkey(Player[playerid][ORM_ID], "id");
	switch (orm_errno(Player[playerid][ORM_ID]))
	{
		case ERROR_OK:
		{
			Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
				"Prijavljivanje",
				"%s, unesite Vasu tacnu lozinku: ",
				"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
			);

			// from now on, the player has 30 seconds to login
			Player[playerid][LoginTimer] = SetTimerEx("OnLoginTimeout", SECONDS_TO_LOGIN * 1000, false, "d", playerid);
		}
		case ERROR_NO_DATA:
		{
			Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
				"Registracija",
				"%s, unesite Vasu zeljenu lozinku: ",
				"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
			);
		}
	}
	return 1;
}

forward OnLoginTimeout(playerid);
public OnLoginTimeout(playerid)
{
	// reset the variable that stores the timerid
	Player[playerid][LoginTimer] = 0;
	DelayedKick(playerid);
	return 1;
}

forward _KickPlayerDelayed(playerid);
public _KickPlayerDelayed(playerid)
{
	Kick(playerid);
	return 1;
}

DelayedKick(playerid, time = 500)
{
	SetTimerEx("_KickPlayerDelayed", time, false, "d", playerid);
	return 1;
}

SetupPlayerTable()
{
	mysql_tquery(Database, "CREATE TABLE IF NOT EXISTS `players` (`id` int(11) NOT NULL AUTO_INCREMENT,`username` varchar(24) NOT NULL,`password` char(64) NOT NULL,`salt` char(16) NOT NULL,`kills` mediumint(8) NOT NULL DEFAULT '0',`deaths` mediumint(8) NOT NULL DEFAULT '0',`x` float NOT NULL DEFAULT '0',`y` float NOT NULL DEFAULT '0',`z` float NOT NULL DEFAULT '0',`angle` float NOT NULL DEFAULT '0',`interior` tinyint(3) NOT NULL DEFAULT '0', PRIMARY KEY (`id`), UNIQUE KEY `username` (`username`))");
	return 1;
}

UpdatePlayerData(playerid, reason)
{
	if (Player[playerid][IsLoggedIn] == false) return 0;

	// if the client crashed, it's not possible to get the player's position in OnPlayerDisconnect callback
	// so we will use the last saved position (in case of a player who registered and crashed/kicked, the position will be the default spawn point)
	if (reason == 1)
	{
		GetPlayerPos(playerid, Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos]);
		GetPlayerFacingAngle(playerid, Player[playerid][A_Pos]);
	}

	// it is important to store everything in the variables registered in ORM instance
	Player[playerid][Interior] = GetPlayerInterior(playerid);

	// orm_save sends an UPDATE query
	orm_save(Player[playerid][ORM_ID]);
	orm_destroy(Player[playerid][ORM_ID]);
	return 1;
}

UpdatePlayerDeaths(playerid)
{
	if (Player[playerid][IsLoggedIn] == false) return 0;

	Player[playerid][Deaths]++;

	orm_update(Player[playerid][ORM_ID]);
	return 1;
}

UpdatePlayerKills(killerid)
{
	// we must check before if the killer wasn't valid (connected) player to avoid run time error 4
	if (killerid == INVALID_PLAYER_ID) return 0;
	if (Player[killerid][IsLoggedIn] == false) return 0;

	Player[killerid][Kills]++;

	orm_update(Player[killerid][ORM_ID]);
	return 1;
}

// ====================================================================================================================== //

public OnPlayerSpawn(playerid)
{
	SetPlayerTeam(playerid, NO_TEAM);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	DestroyVehicle(stfveh[playerid]);
	stfveh[playerid] = INVALID_PLAYER_ID;

	UpdatePlayerDeaths(playerid);
	UpdatePlayerKills(killerid);

	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

timer Spawn_Player[100](playerid, type)
{
	if (type == e_SPAWN_TYPE_REGISTER)
		{
			SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Uspesno ste se registrovali!");
			SetSpawnInfo(playerid, 0, player_Skin[playerid],
				154.2401,-1942.5531,3.7734,0.4520,
				0, 0, 0, 0, 0, 0
			);
			SpawnPlayer(playerid);

			SetPlayerScore(playerid, player_Score[playerid]);
			GivePlayerMoney(playerid, player_Money[playerid]);
			SetPlayerSkin(playerid, player_Skin[playerid]);
		}

		else if (type == e_SPAWN_TYPE_LOGIN)
		{
			SendClientMessage(playerid, x_server,"myproject // "c_white"Uspesno ste se prijavli!");
			SetSpawnInfo(playerid, 0, player_Skin[playerid],
				154.2401,-1942.5531,3.7734,0.4520,
				0, 0, 0, 0, 0, 0
			);
			SpawnPlayer(playerid);

			SetPlayerScore(playerid, player_Score[playerid]);
			GivePlayerMoney(playerid, player_Money[playerid]);
			SetPlayerSkin(playerid, player_Skin[playerid]);
		}

}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{

	Player[playerid][IsLoggedIn] = true;

	Player[playerid][X_Pos] = DEFAULT_POS_X;
	Player[playerid][Y_Pos] = DEFAULT_POS_Y;
	Player[playerid][Z_Pos] = DEFAULT_POS_Z;
	Player[playerid][A_Pos] = DEFAULT_POS_A;
	defer Spawn_Player(playerid, e_SPAWN_TYPE_REGISTER);

	//SetSpawnInfo(playerid, NO_TEAM, 0, Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos], Player[playerid][A_Pos], 0, 0, 0, 0, 0, 0);
	//SpawnPlayer(playerid);
	return 1;
}

Dialog: dialog_regpassword(playerid, response, listitem, string: inputtext[])
{
	if (!response) return Kick(playerid);

	if (strlen(inputtext) <= 5) return Dialog_Show(playerid, "dialog_regpassword", DIALOG_STYLE_INPUT,
											"Registracija",
											"%s, unesite Vasu zeljenu lozinku: ",
											"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
										);

	// 16 random characters from 33 to 126 (in ASCII) for the salt
	for (new i = 0; i < 16; i++) Player[playerid][Salt][i] = random(94) + 33;
	SHA256_PassHash(inputtext, Player[playerid][Salt], Player[playerid][Password], 65);

	// sends an INSERT query
	orm_save(Player[playerid][ORM_ID], "OnPlayerRegister", "d", playerid);

	return 1;
}

Dialog: dialog_login(const playerid, response, listitem, string: inputtext[])
{
	if (!response) return Kick(playerid);

	new hashed_pass[65];
	SHA256_PassHash(inputtext, Player[playerid][Salt], hashed_pass, 65);

	if (strcmp(hashed_pass, Player[playerid][Password]) == 0)
	{
		KillTimer(Player[playerid][LoginTimer]);
		Player[playerid][LoginTimer] = 0;
		Player[playerid][IsLoggedIn] = true;

		// spawn the player to their last saved position after login
		SetSpawnInfo(playerid, NO_TEAM, 0, Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos], Player[playerid][A_Pos], 0, 0, 0, 0, 0, 0);
		SpawnPlayer(playerid);
	}
	else
	{
		Player[playerid][LoginAttempts]++;

		if (Player[playerid][LoginAttempts] >= 3)
		{
			DelayedKick(playerid);
		}
		else Dialog_Show(playerid, "dialog_login", DIALOG_STYLE_PASSWORD,
				"Prijavljivanje",
				"%s, unesite Vasu tacnu lozinku: ",
				"Potvrdi", "Izlaz", ReturnPlayerName(playerid)
			);
	}

	return 1;
}

stock Account_Path(const playerid)
{
	new tmp_fmt[64];
	format(tmp_fmt, sizeof(tmp_fmt), USER_PATH, ReturnPlayerName(playerid));

	return tmp_fmt;
}

YCMD:help(playerid, params[], help)
{
	if (help)
	{
		SendClientMessage(playerid, -1, "Use `/help <command>` to get information about the command.");
	}
	else if (IsNull(params))
	{
		SendClientMessage(playerid, -1, "Please enter a command.");
	}
	else
	{
		Command_ReProcess(playerid, params, true);
	}
	return 1;
}


YCMD:staffcmd(playerid, const string: params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam prikazuje sve Staff Komande.");
        return 1;
    }

	if(!player_Staff[playerid])
		return SendClientMessage(playerid, x_red, "myserver // "c_white"Samo staff moze ovo!");

	Dialog_Show(playerid, "dialog_staffcmd", DIALOG_STYLE_MSGBOX,
	""c_server"myserver // "c_white"Staff Commands",
	""c_white"%s, Vi ste deo naseg "c_server"staff "c_white"tima!\n\
	"c_server"SLVL1 >> "c_white"/sduty\n\
	"c_server"SLVL1 >> "c_white"/sc\n\
	"c_server"SLVL1 >> "c_white"/staffcmd\n\
	"c_server"SLVL1 >> "c_white"/sveh\n\
	"c_server"SLVL1 >> "c_white"/goto\n\
	"c_server"SLVL1 >> "c_white"/cc\n\
	"c_server"SLVL1 >> "c_white"/fv\n\
	"c_server"SLVL2 >> "c_white"/gethere\n\
	"c_server"SLVL3 >> "c_white"/nitro\n\
	"c_server"SLVL4 >> "c_white"/jetpack\n\
	"c_server"SLVL4 >> "c_white"/setskin\n\
	"c_server"SLVL4 >> "c_white"/xgoto\n\
	"c_server"SLVL4 >> "c_white"/spanel\n\
	"c_server"SLVL4 >> "c_white"/setstaff",
	"U redu", "", ReturnPlayerName(playerid)
	);

    return 1;
}

YCMD:sc(playerid, const string: params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam omogucava da pisete u Staff Chat.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	if (isnull(params))
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"/sc [text]");

	static tmp_str[128];

	format(tmp_str, sizeof(tmp_str), "Staff - %s(%d): "c_white"%s", ReturnPlayerName(playerid), playerid, params);

	foreach (new i: Player)
		if (player_Staff[i])
			SendClientMessage(i, x_ltblue, tmp_str);
	
    return 1;
}

YCMD:sveh(playerid, params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam Kreira Staff Vozilo.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	if (stfveh[playerid] == INVALID_VEHICLE_ID) 
	{
		if (isnull(params))
			return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"/sveh [Model ID]");

		new modelid = strval(params);

		if (400 > modelid > 611)
			return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"* Validni modeli su od 400 do 611.");

		new vehicleid = stfveh[playerid] = CreateVehicle(modelid, x, y, z, 0.0, 1, 0, -1);

		SetVehicleNumberPlate(vehicleid, "STAFF");
		PutPlayerInVehicle(playerid, vehicleid, 0);
		
	    new engine, lights, alarm, doors, bonnet, boot, objective;
	    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

	    if (IsVehicleBicycle(GetVehicleModel(vehicleid)))
	    {
	        SetVehicleParamsEx(vehicleid, 1, 0, 0, doors, bonnet, boot, objective);
	    }
	    else
	    {
	        SetVehicleParamsEx(vehicleid, 0, 0, 0, doors, bonnet, boot, objective);
	    }
		SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Stvorili ste vozilo, da ga unistite kucajte '/sveh'.");
	}
	else 
	{
		DestroyVehicle(stfveh[playerid]);
		stfveh[playerid] = INVALID_PLAYER_ID;
		SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Unistili ste vozilo, da ga stvorite kucajte '/veh [Model ID]'.");
	}
	
    return 1;
}

YCMD:goto(playerid, params[],help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam omogucava da odete do odredjenog igraca.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	new giveplayerid, giveplayer[MAX_PLAYER_NAME];

	new Float:plx,Float:ply,Float:plz;

	GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));

	if(!sscanf(params, "u", giveplayerid))
	{	
		GetPlayerPos(giveplayerid, plx, ply, plz);
			
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, plx, ply+4, plz);
		}
		else
		{
			SetPlayerPos(playerid,plx,ply+2, plz);
		}
		SetPlayerInterior(playerid, GetPlayerInterior(giveplayerid));
	}
    return 1;
}

YCMD:cc(playerid, params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja ce Ocistiti Chat svim igracima.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	for(new cc; cc < 110; cc++)
	{
		SendClientMessageToAll(-1, "");
	}

	if(player_Staff[playerid] < 1)
	{
		static fmt_string[120];
		format(fmt_string, sizeof(fmt_string), ""c_server"myproject // "c_white"chat je ocistio"c_server" %s", ReturnPlayerName(playerid));
		SendClientMessageToAll(-1, fmt_string);
	}
    return 1;
}

YCMD:fv(playerid, params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam Popravlja Vozilo.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Niste u vozilu!");

	RepairVehicle(vehicleid);

	SetVehicleHealth(vehicleid, 999.0);

	return 1;
}
YCMD:gethere(playerid, const params[], help)
{
	if(help)
    {
        SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja teleportuje igraca do vas.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	new targetid = INVALID_PLAYER_ID;

	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"/gethere [id]");

	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, x_server, "myproject // "c_white"Taj ID nije konektovan.");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetPlayerPos(targetid, x+1, y, z+1);

	SetPlayerInterior(targetid, GetPlayerInterior(playerid));

	SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

	new name[MAX_PLAYER_NAME];
	GetPlayerName(targetid, name, sizeof(name));

	static fmt_string[60];

	format(fmt_string, sizeof(fmt_string),""c_server"myproject // "c_white"Teleportovali ste igraca %s do sebe.", name);
	SendClientMessage(playerid, -1, fmt_string);

	GetPlayerName(playerid, name, sizeof(name));

	format(fmt_string, sizeof(fmt_string), ""c_server"myproject // "c_white"Staff %s vas je teleportovao do sebe.", name);
	SendClientMessage(targetid, -1, fmt_string);

    return 1;
}

YCMD:nitro(playerid, params[], help)
{
	if(help)
    {
		SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam daje Nitro.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);

	SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Ugradili ste nitro u vase vozilo.");

	return 1;
}

YCMD:jetpack(playerid, params[], help)
{
	if(help)
    {
		SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam daje Jetpack.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);

	SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Uzeli ste Jetpack.");

	return 1;
}

YCMD:setskin(playerid, const string: params[], help)
{
	if(help)
    {
		SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam omogucava da postavite odredjeni skin od 1 do 311.");
        return 1;
    }

	if (player_Staff[playerid] < 1)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Samo staff moze ovo!");

	static
		targetid,
		skinid;

	if (sscanf(params, "ri", targetid, skinid))
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"/setskin [targetid] [skinid]");

	if (!(1 <= skinid <= 311))
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Pogresan ID skina!");

	if (GetPlayerSkin(targetid) == skinid)
		return SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Taj igrac vec ima taj skin!");

	SetPlayerSkin(targetid, skinid);

	player_Skin[targetid] = skinid;

    new INI:File = INI_Open(Account_Path(playerid));
	INI_SetTag( File, "data" );
    INI_WriteInt(File, "Skin", GetPlayerSkin(playerid));
	INI_Close( File );

    return 1;
}

YCMD:xgoto(playerid, params[], help)
{
	if(help)
    {
		SendClientMessage(playerid, x_blue, "HELP >> "c_white"Komanda koja vam pruza mogucnost teleportiranja na odredjene koordinate.");
        return 1;
    }

	if (Player[playerid][AdminLevel] < 1)
		return Error(playerid, "Nemate ovlasti za upotrebu ove komande!");

	new Float:x, Float:y, Float:z;

	static fmt_string[100];

	if (sscanf(params, "fff", x, y, z)) SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"xgoto <X Float> <Y Float> <Z Float>");
	else
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    SetVehiclePos(GetPlayerVehicleID(playerid), x,y,z);
		}
		else
		{
		    SetPlayerPos(playerid, x, y, z);
		}
		format(fmt_string, sizeof(fmt_string), ""c_server"myproject // "c_white"Postavili ste koordinate na %f, %f, %f", x, y, z);
		SendClientMessage(playerid, x_ltblue, fmt_string);
	}
 	return 1;
}

stock SendClientMessageEx(id, color, const fmt[], va_args<>) {
	new str[128]; 
	va_format(str, sizeof str, fmt, va_start<3>); 
	return SendClientMessage(id, color, str); 
}

//- backend
#include "backend/vehicle.pwn"

//- test
//-
//#include "test/"
