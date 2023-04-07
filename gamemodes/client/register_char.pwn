#include <ysilib\YSI_Coding\y_hooks>

enum    E_REG_CHAR_SKIN_DATA
{
	skin_desc_name[20],
	skin_id
}
new Male_Skins_Data[][E_REG_CHAR_SKIN_DATA] = {
	{"Konobar", 	20},
	{"Deejay", 		19},
	{"Kapuljaca", 	29},
	{"Starac", 		43},
	{"Biker", 	    67}
};
new Female_Skins_Data[][E_REG_CHAR_SKIN_DATA] = {
	{"Direktorica", 9},
	{"Baba", 		10},
	{"Hostesa", 	12},
	{"Konobar", 	64},
	{"Plavusa", 	93}
};

enum    E_REG_CHAR_FIGHT_STYLES
{
	fight_style_name[15],
	fight_style_id
}
new Fight_Styles[][E_REG_CHAR_FIGHT_STYLES] = {
	{"Normalno", 	        4},
	{"Boks", 		        5},
	{"Kung-Fu", 	        6},
	{"Koljeno-Glava", 		7},
	{"Lakat", 	            16}
};

enum    E_REG_CHAR_HISTORY
{
	history_name[15],
	Float:history_cam_pos[6],
    Float:history_cam_look_pos[6],
    Float:history_char_pos[4]
}
new Char_Histories[][E_REG_CHAR_HISTORY] = {
	{   
        "Turista", 
        {1632.648681, -2325.904541, 14.549610, 1632.648681, -2325.904541, 14.549610}, 
        {1636.590576, -2328.916748, 13.927350, 1636.590576, -2328.916748, 13.927350},
        {1637.9888, -2332.0828, 13.5469, 52.5358}
    },
	{   
        "Ulicni Diler", 
        {2417.961181, -1227.408935, 26.250349, 2417.961181, -1227.408935, 26.250349}, 
        {2418.163574, -1222.493286, 25.358394, 2418.163574, -1222.493286, 25.358394},
        {2419.6116, -1222.6368, 25.2446, 176.9361}
    },
    {   
        "Zatvorenik", 
        {1811.704711, -1577.008056, 14.939336, 1811.704711, -1577.008056, 14.939336}, 
        {1806.918212, -1578.152343, 14.056106, 1806.918212, -1578.152343, 14.056106},
        {1804.4203, -1576.7646, 13.4281, 280.5467}
    }
};

new 
    Text:Register_Char_Global[22],
    PlayerText:Register_Char_Player[MAX_PLAYERS][4]= {PlayerText:INVALID_TEXT_DRAW, ...},
    char_Register_Pol[MAX_PLAYERS], 
    char_Register_Skin_Index[MAX_PLAYERS],
    char_Register_Fight_Index[MAX_PLAYERS],
    char_Register_Historija[MAX_PLAYERS],
    char_Register_Actor[MAX_PLAYERS][sizeof(Char_Histories)],
    char_Operations_Tick[MAX_PLAYERS];

StartCharacterRegistration(playerid) {
    ClearChat(playerid, 50);
    TogglePlayerSpectating(playerid, true);
    ToggleCharacterRegistrationGUI(playerid, true);
    char_Register_Pol[playerid] = 0;
    new skin = char_Register_Skin_Index[playerid] = 0;
    char_Register_Fight_Index[playerid] = 0;
    char_Register_Historija[playerid] = 0;
    for(new i; i < sizeof(Char_Histories); i++) {
        char_Register_Actor[playerid][i] = CreateDynamicActor(
                Male_Skins_Data[skin][skin_id], 
                Char_Histories[i][history_char_pos][0], Char_Histories[i][history_char_pos][1], Char_Histories[i][history_char_pos][2], Char_Histories[i][history_char_pos][3], 
                1, 100.0, 
                playerid, 0, playerid
            );
    }
    UpdateCharacterGUI(playerid);
}

UpdateCharacterGUI(playerid, bool:update_actor = true) {
    new gender = char_Register_Pol[playerid];
    new skin = char_Register_Skin_Index[playerid];
    new fightstyle = char_Register_Fight_Index[playerid];
    new history = char_Register_Historija[playerid];
    new skinid = (gender == 0) ? Male_Skins_Data[skin][skin_id] : Female_Skins_Data[skin][skin_id];

    // textdraw update
    PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][0], (gender == 0) ? "Muski" : "Zenski");
    if(gender == 0) PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][1], Male_Skins_Data[skin][skin_desc_name]);
    else PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][1], Female_Skins_Data[skin][skin_desc_name]);
    PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][2], Fight_Styles[fightstyle][fight_style_name]);
    PlayerTextDrawSetString(playerid, Register_Char_Player[playerid][3], Char_Histories[history][history_name]);

    // actor update
    if (update_actor) {
        for(new i; i < sizeof(Char_Histories); i++) {
            Streamer_SetIntData(STREAMER_TYPE_ACTOR, char_Register_Actor[playerid][i], E_STREAMER_MODEL_ID, skinid);
        }
    }

    // camera update
    InterpolateCameraPos(
        playerid, 
        Char_Histories[history][history_cam_pos][0], Char_Histories[history][history_cam_pos][1], Char_Histories[history][history_cam_pos][2], 
        Char_Histories[history][history_cam_pos][3], Char_Histories[history][history_cam_pos][4], Char_Histories[history][history_cam_pos][5], 
        1000
    );
    InterpolateCameraLookAt(
        playerid, 
        Char_Histories[history][history_cam_look_pos][0], Char_Histories[history][history_cam_look_pos][1], Char_Histories[history][history_cam_look_pos][2], 
        Char_Histories[history][history_cam_look_pos][3], Char_Histories[history][history_cam_look_pos][4], Char_Histories[history][history_cam_look_pos][5], 
        1000
    );

    Streamer_Update(playerid);
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
    if(GetTickCount() >= char_Operations_Tick[playerid]) 
    {
        if(clickedid == Register_Char_Global[6] || clickedid == Register_Char_Global[7]) 
        {
            char_Register_Pol[playerid] = (char_Register_Pol[playerid] == 0) ? 1 : 0;
            UpdateCharacterGUI(playerid);
            char_Operations_Tick[playerid] = GetTickCount() + 500;
        } 
        else if(clickedid == Register_Char_Global[10]) 
        {
            new index_size = (char_Register_Pol[playerid] == 0) ? sizeof(Male_Skins_Data) : sizeof(Female_Skins_Data);
            if(char_Register_Skin_Index[playerid] == 0) char_Register_Skin_Index[playerid] = index_size - 1;
            else char_Register_Skin_Index[playerid]--;
            UpdateCharacterGUI(playerid);
            char_Operations_Tick[playerid] = GetTickCount() + 500;
        } 
        else if(clickedid == Register_Char_Global[11]) 
        {
            new index_size = (char_Register_Pol[playerid] == 0) ? sizeof(Male_Skins_Data) : sizeof(Female_Skins_Data);
            if(char_Register_Skin_Index[playerid] == index_size - 1) char_Register_Skin_Index[playerid] = 0;
            else char_Register_Skin_Index[playerid]++;
            UpdateCharacterGUI(playerid);
            char_Operations_Tick[playerid] = GetTickCount() + 500;
        } 
        else if(clickedid == Register_Char_Global[14]) 
        {
            new index_size = sizeof(Fight_Styles);
            if(char_Register_Fight_Index[playerid] == 0) char_Register_Fight_Index[playerid] = index_size - 1;
            else char_Register_Fight_Index[playerid]--;
            UpdateCharacterGUI(playerid, false);
        } 
        else if(clickedid == Register_Char_Global[15]) 
        {
            new index_size = sizeof(Fight_Styles);
            if(char_Register_Fight_Index[playerid] == index_size - 1) char_Register_Fight_Index[playerid] = 0;
            else char_Register_Fight_Index[playerid]++;
            UpdateCharacterGUI(playerid, false);
        } 
        else if(clickedid == Register_Char_Global[18]) 
        {
            new index_size = sizeof(Char_Histories);
            if(char_Register_Historija[playerid] == 0) char_Register_Historija[playerid] = index_size - 1;
            else char_Register_Historija[playerid]--;
            UpdateCharacterGUI(playerid, false);
            char_Operations_Tick[playerid] = GetTickCount() + 1000;
        }
        else if(clickedid == Register_Char_Global[19]) 
        {
            new index_size = sizeof(Char_Histories);
            if(char_Register_Historija[playerid] == index_size - 1) char_Register_Historija[playerid] = 0;
            else char_Register_Historija[playerid]++;
            UpdateCharacterGUI(playerid, false);
            char_Operations_Tick[playerid] = GetTickCount() + 1000;
        }
        else if(clickedid == Register_Char_Global[21]) {
            CompleteRegistration(playerid);
        }
    }
}

CompleteRegistration(playerid) {
    new gender = char_Register_Pol[playerid];
    new skin = char_Register_Skin_Index[playerid];
    new fightstyle = char_Register_Fight_Index[playerid];
    new history = char_Register_Historija[playerid];
    new skinid = (gender == 0) ? Male_Skins_Data[skin][skin_id] : Female_Skins_Data[skin][skin_id];

    Player[playerid][IsLoggedIn] = true;
	Player[playerid][X_Pos] = Char_Histories[history][history_char_pos][0];
	Player[playerid][Y_Pos] = Char_Histories[history][history_char_pos][1];
	Player[playerid][Z_Pos] = Char_Histories[history][history_char_pos][2];
	Player[playerid][A_Pos] = Char_Histories[history][history_char_pos][3];
	Player[playerid][Skin] = skinid;
    Player[playerid][Skin] = skinid;

	//SendClientMessage(playerid, -1, ""c_server"myproject // "c_white"Uspesno ste se registrovali!");
	SetSpawnInfo(playerid, 0, Player[playerid][Skin],
		Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos], Player[playerid][A_Pos],
		0, 0, 0, 0, 0, 0
	);
	SpawnPlayer(playerid);
    SetPlayerFightingStyle(playerid, Fight_Styles[fightstyle][fight_style_id]);
}

hook OnGameModeInit() {

    Register_Char_Global[0] = TextDrawCreate(161.000000, 74.000000, "_");
    TextDrawFont(Register_Char_Global[0], 1);
    TextDrawLetterSize(Register_Char_Global[0], 1.391666, 27.999977);
    TextDrawTextSize(Register_Char_Global[0], 298.500000, 215.000000);
    TextDrawSetOutline(Register_Char_Global[0], 1);
    TextDrawSetShadow(Register_Char_Global[0], 0);
    TextDrawAlignment(Register_Char_Global[0], 2);
    TextDrawColor(Register_Char_Global[0], -1);
    TextDrawBackgroundColor(Register_Char_Global[0], 255);
    TextDrawBoxColor(Register_Char_Global[0], 1296911751);
    TextDrawUseBox(Register_Char_Global[0], 1);
    TextDrawSetProportional(Register_Char_Global[0], 1);
    TextDrawSetSelectable(Register_Char_Global[0], 0);

    Register_Char_Global[1] = TextDrawCreate(161.000000, 80.000000, "_");
    TextDrawFont(Register_Char_Global[1], 1);
    TextDrawLetterSize(Register_Char_Global[1], 1.391666, 26.649997);
    TextDrawTextSize(Register_Char_Global[1], 298.500000, 204.000000);
    TextDrawSetOutline(Register_Char_Global[1], 1);
    TextDrawSetShadow(Register_Char_Global[1], 0);
    TextDrawAlignment(Register_Char_Global[1], 2);
    TextDrawColor(Register_Char_Global[1], -1);
    TextDrawBackgroundColor(Register_Char_Global[1], 255);
    TextDrawBoxColor(Register_Char_Global[1], 135);
    TextDrawUseBox(Register_Char_Global[1], 1);
    TextDrawSetProportional(Register_Char_Global[1], 1);
    TextDrawSetSelectable(Register_Char_Global[1], 0);

    Register_Char_Global[2] = TextDrawCreate(136.000000, 78.000000, "~r~MON~w~ACO");
    TextDrawFont(Register_Char_Global[2], 2);
    TextDrawLetterSize(Register_Char_Global[2], 0.262499, 1.399999);
    TextDrawTextSize(Register_Char_Global[2], 400.000000, 17.000000);
    TextDrawSetOutline(Register_Char_Global[2], 1);
    TextDrawSetShadow(Register_Char_Global[2], 0);
    TextDrawAlignment(Register_Char_Global[2], 1);
    TextDrawColor(Register_Char_Global[2], -1);
    TextDrawBackgroundColor(Register_Char_Global[2], 255);
    TextDrawBoxColor(Register_Char_Global[2], 0);
    TextDrawUseBox(Register_Char_Global[2], 1);
    TextDrawSetProportional(Register_Char_Global[2], 1);
    TextDrawSetSelectable(Register_Char_Global[2], 0);

    Register_Char_Global[3] = TextDrawCreate(135.000000, 88.000000, "Character");
    TextDrawFont(Register_Char_Global[3], 3);
    TextDrawLetterSize(Register_Char_Global[3], 0.262499, 1.000000);
    TextDrawTextSize(Register_Char_Global[3], 400.000000, 17.000000);
    TextDrawSetOutline(Register_Char_Global[3], 1);
    TextDrawSetShadow(Register_Char_Global[3], 0);
    TextDrawAlignment(Register_Char_Global[3], 1);
    TextDrawColor(Register_Char_Global[3], -1);
    TextDrawBackgroundColor(Register_Char_Global[3], 255);
    TextDrawBoxColor(Register_Char_Global[3], 0);
    TextDrawUseBox(Register_Char_Global[3], 1);
    TextDrawSetProportional(Register_Char_Global[3], 1);
    TextDrawSetSelectable(Register_Char_Global[3], 0);

    Register_Char_Global[4] = TextDrawCreate(161.000000, 102.000000, "_");
    TextDrawFont(Register_Char_Global[4], 1);
    TextDrawLetterSize(Register_Char_Global[4], 1.391666, 0.249976);
    TextDrawTextSize(Register_Char_Global[4], 298.500000, 204.500000);
    TextDrawSetOutline(Register_Char_Global[4], 1);
    TextDrawSetShadow(Register_Char_Global[4], 0);
    TextDrawAlignment(Register_Char_Global[4], 2);
    TextDrawColor(Register_Char_Global[4], -1);
    TextDrawBackgroundColor(Register_Char_Global[4], 255);
    TextDrawBoxColor(Register_Char_Global[4], 1296911751);
    TextDrawUseBox(Register_Char_Global[4], 1);
    TextDrawSetProportional(Register_Char_Global[4], 1);
    TextDrawSetSelectable(Register_Char_Global[4], 0);

    Register_Char_Global[5] = TextDrawCreate(62.000000, 109.000000, "odabir spola:");
    TextDrawFont(Register_Char_Global[5], 3);
    TextDrawLetterSize(Register_Char_Global[5], 0.262499, 1.000000);
    TextDrawTextSize(Register_Char_Global[5], 400.000000, 17.000000);
    TextDrawSetOutline(Register_Char_Global[5], 1);
    TextDrawSetShadow(Register_Char_Global[5], 0);
    TextDrawAlignment(Register_Char_Global[5], 1);
    TextDrawColor(Register_Char_Global[5], -1);
    TextDrawBackgroundColor(Register_Char_Global[5], 255);
    TextDrawBoxColor(Register_Char_Global[5], 0);
    TextDrawUseBox(Register_Char_Global[5], 1);
    TextDrawSetProportional(Register_Char_Global[5], 1);
    TextDrawSetSelectable(Register_Char_Global[5], 0);

    Register_Char_Global[6] = TextDrawCreate(130.000000, 108.000000, "ld_beat:left");
    TextDrawFont(Register_Char_Global[6], 4);
    TextDrawLetterSize(Register_Char_Global[6], 0.600000, 2.000000);
    TextDrawTextSize(Register_Char_Global[6], 11.500000, 11.500000);
    TextDrawSetOutline(Register_Char_Global[6], 1);
    TextDrawSetShadow(Register_Char_Global[6], 0);
    TextDrawAlignment(Register_Char_Global[6], 1);
    TextDrawColor(Register_Char_Global[6], -1);
    TextDrawBackgroundColor(Register_Char_Global[6], 255);
    TextDrawBoxColor(Register_Char_Global[6], 50);
    TextDrawUseBox(Register_Char_Global[6], 1);
    TextDrawSetProportional(Register_Char_Global[6], 1);
    TextDrawSetSelectable(Register_Char_Global[6], 1);

    Register_Char_Global[7] = TextDrawCreate(148.000000, 108.000000, "LD_BEAT:right");
    TextDrawFont(Register_Char_Global[7], 4);
    TextDrawLetterSize(Register_Char_Global[7], 0.600000, 2.000000);
    TextDrawTextSize(Register_Char_Global[7], 11.500000, 11.500000);
    TextDrawSetOutline(Register_Char_Global[7], 1);
    TextDrawSetShadow(Register_Char_Global[7], 0);
    TextDrawAlignment(Register_Char_Global[7], 1);
    TextDrawColor(Register_Char_Global[7], -1);
    TextDrawBackgroundColor(Register_Char_Global[7], 255);
    TextDrawBoxColor(Register_Char_Global[7], 50);
    TextDrawUseBox(Register_Char_Global[7], 1);
    TextDrawSetProportional(Register_Char_Global[7], 1);
    TextDrawSetSelectable(Register_Char_Global[7], 1);

    Register_Char_Global[8] = TextDrawCreate(161.000000, 124.000000, "_");
    TextDrawFont(Register_Char_Global[8], 1);
    TextDrawLetterSize(Register_Char_Global[8], 1.391666, 0.249976);
    TextDrawTextSize(Register_Char_Global[8], 298.500000, 204.500000);
    TextDrawSetOutline(Register_Char_Global[8], 1);
    TextDrawSetShadow(Register_Char_Global[8], 0);
    TextDrawAlignment(Register_Char_Global[8], 2);
    TextDrawColor(Register_Char_Global[8], -1);
    TextDrawBackgroundColor(Register_Char_Global[8], 255);
    TextDrawBoxColor(Register_Char_Global[8], 1296911751);
    TextDrawUseBox(Register_Char_Global[8], 1);
    TextDrawSetProportional(Register_Char_Global[8], 1);
    TextDrawSetSelectable(Register_Char_Global[8], 0);

    Register_Char_Global[9] = TextDrawCreate(62.000000, 130.000000, "odjeca:");
    TextDrawFont(Register_Char_Global[9], 3);
    TextDrawLetterSize(Register_Char_Global[9], 0.262499, 1.000000);
    TextDrawTextSize(Register_Char_Global[9], 400.000000, 17.000000);
    TextDrawSetOutline(Register_Char_Global[9], 1);
    TextDrawSetShadow(Register_Char_Global[9], 0);
    TextDrawAlignment(Register_Char_Global[9], 1);
    TextDrawColor(Register_Char_Global[9], -1);
    TextDrawBackgroundColor(Register_Char_Global[9], 255);
    TextDrawBoxColor(Register_Char_Global[9], 0);
    TextDrawUseBox(Register_Char_Global[9], 1);
    TextDrawSetProportional(Register_Char_Global[9], 1);
    TextDrawSetSelectable(Register_Char_Global[9], 0);

    Register_Char_Global[10] = TextDrawCreate(130.000000, 129.000000, "ld_beat:left");
    TextDrawFont(Register_Char_Global[10], 4);
    TextDrawLetterSize(Register_Char_Global[10], 0.600000, 2.000000);
    TextDrawTextSize(Register_Char_Global[10], 11.500000, 11.500000);
    TextDrawSetOutline(Register_Char_Global[10], 1);
    TextDrawSetShadow(Register_Char_Global[10], 0);
    TextDrawAlignment(Register_Char_Global[10], 1);
    TextDrawColor(Register_Char_Global[10], -1);
    TextDrawBackgroundColor(Register_Char_Global[10], 255);
    TextDrawBoxColor(Register_Char_Global[10], 50);
    TextDrawUseBox(Register_Char_Global[10], 1);
    TextDrawSetProportional(Register_Char_Global[10], 1);
    TextDrawSetSelectable(Register_Char_Global[10], 1);

    Register_Char_Global[11] = TextDrawCreate(148.000000, 129.000000, "LD_BEAT:right");
    TextDrawFont(Register_Char_Global[11], 4);
    TextDrawLetterSize(Register_Char_Global[11], 0.600000, 2.000000);
    TextDrawTextSize(Register_Char_Global[11], 11.500000, 11.500000);
    TextDrawSetOutline(Register_Char_Global[11], 1);
    TextDrawSetShadow(Register_Char_Global[11], 0);
    TextDrawAlignment(Register_Char_Global[11], 1);
    TextDrawColor(Register_Char_Global[11], -1);
    TextDrawBackgroundColor(Register_Char_Global[11], 255);
    TextDrawBoxColor(Register_Char_Global[11], 50);
    TextDrawUseBox(Register_Char_Global[11], 1);
    TextDrawSetProportional(Register_Char_Global[11], 1);
    TextDrawSetSelectable(Register_Char_Global[11], 1);

    Register_Char_Global[12] = TextDrawCreate(161.000000, 145.000000, "_");
    TextDrawFont(Register_Char_Global[12], 1);
    TextDrawLetterSize(Register_Char_Global[12], 1.391666, 0.249976);
    TextDrawTextSize(Register_Char_Global[12], 298.500000, 204.500000);
    TextDrawSetOutline(Register_Char_Global[12], 1);
    TextDrawSetShadow(Register_Char_Global[12], 0);
    TextDrawAlignment(Register_Char_Global[12], 2);
    TextDrawColor(Register_Char_Global[12], -1);
    TextDrawBackgroundColor(Register_Char_Global[12], 255);
    TextDrawBoxColor(Register_Char_Global[12], 1296911751);
    TextDrawUseBox(Register_Char_Global[12], 1);
    TextDrawSetProportional(Register_Char_Global[12], 1);
    TextDrawSetSelectable(Register_Char_Global[12], 0);

    Register_Char_Global[13] = TextDrawCreate(62.000000, 151.000000, "borbeni stil:");
    TextDrawFont(Register_Char_Global[13], 3);
    TextDrawLetterSize(Register_Char_Global[13], 0.262499, 1.000000);
    TextDrawTextSize(Register_Char_Global[13], 400.000000, 17.000000);
    TextDrawSetOutline(Register_Char_Global[13], 1);
    TextDrawSetShadow(Register_Char_Global[13], 0);
    TextDrawAlignment(Register_Char_Global[13], 1);
    TextDrawColor(Register_Char_Global[13], -1);
    TextDrawBackgroundColor(Register_Char_Global[13], 255);
    TextDrawBoxColor(Register_Char_Global[13], 0);
    TextDrawUseBox(Register_Char_Global[13], 1);
    TextDrawSetProportional(Register_Char_Global[13], 1);
    TextDrawSetSelectable(Register_Char_Global[13], 0);

    Register_Char_Global[14] = TextDrawCreate(130.000000, 150.000000, "ld_beat:left");
    TextDrawFont(Register_Char_Global[14], 4);
    TextDrawLetterSize(Register_Char_Global[14], 0.600000, 2.000000);
    TextDrawTextSize(Register_Char_Global[14], 11.500000, 11.500000);
    TextDrawSetOutline(Register_Char_Global[14], 1);
    TextDrawSetShadow(Register_Char_Global[14], 0);
    TextDrawAlignment(Register_Char_Global[14], 1);
    TextDrawColor(Register_Char_Global[14], -1);
    TextDrawBackgroundColor(Register_Char_Global[14], 255);
    TextDrawBoxColor(Register_Char_Global[14], 50);
    TextDrawUseBox(Register_Char_Global[14], 1);
    TextDrawSetProportional(Register_Char_Global[14], 1);
    TextDrawSetSelectable(Register_Char_Global[14], 1);

    Register_Char_Global[15] = TextDrawCreate(148.000000, 150.000000, "LD_BEAT:right");
    TextDrawFont(Register_Char_Global[15], 4);
    TextDrawLetterSize(Register_Char_Global[15], 0.600000, 2.000000);
    TextDrawTextSize(Register_Char_Global[15], 11.500000, 11.500000);
    TextDrawSetOutline(Register_Char_Global[15], 1);
    TextDrawSetShadow(Register_Char_Global[15], 0);
    TextDrawAlignment(Register_Char_Global[15], 1);
    TextDrawColor(Register_Char_Global[15], -1);
    TextDrawBackgroundColor(Register_Char_Global[15], 255);
    TextDrawBoxColor(Register_Char_Global[15], 50);
    TextDrawUseBox(Register_Char_Global[15], 1);
    TextDrawSetProportional(Register_Char_Global[15], 1);
    TextDrawSetSelectable(Register_Char_Global[15], 1);

    Register_Char_Global[16] = TextDrawCreate(161.000000, 164.000000, "_");
    TextDrawFont(Register_Char_Global[16], 1);
    TextDrawLetterSize(Register_Char_Global[16], 1.391666, 0.249976);
    TextDrawTextSize(Register_Char_Global[16], 298.500000, 204.500000);
    TextDrawSetOutline(Register_Char_Global[16], 1);
    TextDrawSetShadow(Register_Char_Global[16], 0);
    TextDrawAlignment(Register_Char_Global[16], 2);
    TextDrawColor(Register_Char_Global[16], -1);
    TextDrawBackgroundColor(Register_Char_Global[16], 255);
    TextDrawBoxColor(Register_Char_Global[16], 1296911751);
    TextDrawUseBox(Register_Char_Global[16], 1);
    TextDrawSetProportional(Register_Char_Global[16], 1);
    TextDrawSetSelectable(Register_Char_Global[16], 0);

    Register_Char_Global[17] = TextDrawCreate(62.000000, 170.000000, "Historija:");
    TextDrawFont(Register_Char_Global[17], 3);
    TextDrawLetterSize(Register_Char_Global[17], 0.262499, 1.000000);
    TextDrawTextSize(Register_Char_Global[17], 400.000000, 17.000000);
    TextDrawSetOutline(Register_Char_Global[17], 1);
    TextDrawSetShadow(Register_Char_Global[17], 0);
    TextDrawAlignment(Register_Char_Global[17], 1);
    TextDrawColor(Register_Char_Global[17], -1);
    TextDrawBackgroundColor(Register_Char_Global[17], 255);
    TextDrawBoxColor(Register_Char_Global[17], 0);
    TextDrawUseBox(Register_Char_Global[17], 1);
    TextDrawSetProportional(Register_Char_Global[17], 1);
    TextDrawSetSelectable(Register_Char_Global[17], 0);

    Register_Char_Global[18] = TextDrawCreate(130.000000, 169.000000, "ld_beat:left");
    TextDrawFont(Register_Char_Global[18], 4);
    TextDrawLetterSize(Register_Char_Global[18], 0.600000, 2.000000);
    TextDrawTextSize(Register_Char_Global[18], 11.500000, 11.500000);
    TextDrawSetOutline(Register_Char_Global[18], 1);
    TextDrawSetShadow(Register_Char_Global[18], 0);
    TextDrawAlignment(Register_Char_Global[18], 1);
    TextDrawColor(Register_Char_Global[18], -1);
    TextDrawBackgroundColor(Register_Char_Global[18], 255);
    TextDrawBoxColor(Register_Char_Global[18], 50);
    TextDrawUseBox(Register_Char_Global[18], 1);
    TextDrawSetProportional(Register_Char_Global[18], 1);
    TextDrawSetSelectable(Register_Char_Global[18], 1);

    Register_Char_Global[19] = TextDrawCreate(148.000000, 169.000000, "LD_BEAT:right");
    TextDrawFont(Register_Char_Global[19], 4);
    TextDrawLetterSize(Register_Char_Global[19], 0.600000, 2.000000);
    TextDrawTextSize(Register_Char_Global[19], 11.500000, 11.500000);
    TextDrawSetOutline(Register_Char_Global[19], 1);
    TextDrawSetShadow(Register_Char_Global[19], 0);
    TextDrawAlignment(Register_Char_Global[19], 1);
    TextDrawColor(Register_Char_Global[19], -1);
    TextDrawBackgroundColor(Register_Char_Global[19], 255);
    TextDrawBoxColor(Register_Char_Global[19], 50);
    TextDrawUseBox(Register_Char_Global[19], 1);
    TextDrawSetProportional(Register_Char_Global[19], 1);
    TextDrawSetSelectable(Register_Char_Global[19], 1);

    Register_Char_Global[20] = TextDrawCreate(62.000000, 186.000000, 
                            "Pazljivo odaberite historiju vaseg lika. Ona ce odluciti gdje cete zapoceti vasu igru. Ulicni diler igru zapocinje u Jefferson \
                            naselju ispred javne kuce. Turista u grad dolazi iz druge drzave te sa aerodroma pocinje zivot u Los Santosu. \
                            Zatvorenik nastavlja zivot izlaskom iz Los Santos zatvora.\n\nNapomena: Odabir historije ne utice na pocetni kapital lika.");
    TextDrawFont(Register_Char_Global[20], 1);
    TextDrawLetterSize(Register_Char_Global[20], 0.187500, 0.850000);
    TextDrawTextSize(Register_Char_Global[20], 259.000000, 12.500000);
    TextDrawSetOutline(Register_Char_Global[20], 0);
    TextDrawSetShadow(Register_Char_Global[20], 1);
    TextDrawAlignment(Register_Char_Global[20], 1);
    TextDrawColor(Register_Char_Global[20], 1296911871);
    TextDrawBackgroundColor(Register_Char_Global[20], 255);
    TextDrawBoxColor(Register_Char_Global[20], 63);
    TextDrawUseBox(Register_Char_Global[20], 1);
    TextDrawSetProportional(Register_Char_Global[20], 1);
    TextDrawSetSelectable(Register_Char_Global[20], 0);

    Register_Char_Global[21] = TextDrawCreate(163.000000, 307.000000, "~r~ZAV~w~RSI");
    TextDrawFont(Register_Char_Global[21], 2);
    TextDrawLetterSize(Register_Char_Global[21], 0.258332, 1.399999);
    TextDrawTextSize(Register_Char_Global[21], 16.500000, 90.500000);
    TextDrawSetOutline(Register_Char_Global[21], 1);
    TextDrawSetShadow(Register_Char_Global[21], 0);
    TextDrawAlignment(Register_Char_Global[21], 2);
    TextDrawColor(Register_Char_Global[21], -1);
    TextDrawBackgroundColor(Register_Char_Global[21], 255);
    TextDrawBoxColor(Register_Char_Global[21], 64);
    TextDrawUseBox(Register_Char_Global[21], 1);
    TextDrawSetProportional(Register_Char_Global[21], 1);
    TextDrawSetSelectable(Register_Char_Global[21], 1);
}

ToggleCharacterRegistrationGUI(playerid, bool:toggle = true) 
{
    if (toggle) 
    {
        Register_Char_Player[playerid][0] = CreatePlayerTextDraw(playerid, 165.000000, 109.000000, "ZENSKI");
        PlayerTextDrawFont(playerid, Register_Char_Player[playerid][0], 2);
        PlayerTextDrawLetterSize(playerid, Register_Char_Player[playerid][0], 0.262499, 1.000000);
        PlayerTextDrawTextSize(playerid, Register_Char_Player[playerid][0], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, Register_Char_Player[playerid][0], 1);
        PlayerTextDrawSetShadow(playerid, Register_Char_Player[playerid][0], 0);
        PlayerTextDrawAlignment(playerid, Register_Char_Player[playerid][0], 1);
        PlayerTextDrawColor(playerid, Register_Char_Player[playerid][0], -1);
        PlayerTextDrawBackgroundColor(playerid, Register_Char_Player[playerid][0], 255);
        PlayerTextDrawBoxColor(playerid, Register_Char_Player[playerid][0], 0);
        PlayerTextDrawUseBox(playerid, Register_Char_Player[playerid][0], 1);
        PlayerTextDrawSetProportional(playerid, Register_Char_Player[playerid][0], 1);
        PlayerTextDrawSetSelectable(playerid, Register_Char_Player[playerid][0], 0);

        Register_Char_Player[playerid][1] = CreatePlayerTextDraw(playerid, 165.000000, 130.000000, "KAPULJACA");
        PlayerTextDrawFont(playerid, Register_Char_Player[playerid][1], 2);
        PlayerTextDrawLetterSize(playerid, Register_Char_Player[playerid][1], 0.262499, 1.000000);
        PlayerTextDrawTextSize(playerid, Register_Char_Player[playerid][1], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, Register_Char_Player[playerid][1], 1);
        PlayerTextDrawSetShadow(playerid, Register_Char_Player[playerid][1], 0);
        PlayerTextDrawAlignment(playerid, Register_Char_Player[playerid][1], 1);
        PlayerTextDrawColor(playerid, Register_Char_Player[playerid][1], -1);
        PlayerTextDrawBackgroundColor(playerid, Register_Char_Player[playerid][1], 255);
        PlayerTextDrawBoxColor(playerid, Register_Char_Player[playerid][1], 0);
        PlayerTextDrawUseBox(playerid, Register_Char_Player[playerid][1], 1);
        PlayerTextDrawSetProportional(playerid, Register_Char_Player[playerid][1], 1);
        PlayerTextDrawSetSelectable(playerid, Register_Char_Player[playerid][1], 0);

        Register_Char_Player[playerid][2] = CreatePlayerTextDraw(playerid, 165.000000, 151.000000, "lakat-koljeno");
        PlayerTextDrawFont(playerid, Register_Char_Player[playerid][2], 2);
        PlayerTextDrawLetterSize(playerid, Register_Char_Player[playerid][2], 0.262499, 1.000000);
        PlayerTextDrawTextSize(playerid, Register_Char_Player[playerid][2], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, Register_Char_Player[playerid][2], 1);
        PlayerTextDrawSetShadow(playerid, Register_Char_Player[playerid][2], 0);
        PlayerTextDrawAlignment(playerid, Register_Char_Player[playerid][2], 1);
        PlayerTextDrawColor(playerid, Register_Char_Player[playerid][2], -1);
        PlayerTextDrawBackgroundColor(playerid, Register_Char_Player[playerid][2], 255);
        PlayerTextDrawBoxColor(playerid, Register_Char_Player[playerid][2], 0);
        PlayerTextDrawUseBox(playerid, Register_Char_Player[playerid][2], 1);
        PlayerTextDrawSetProportional(playerid, Register_Char_Player[playerid][2], 1);
        PlayerTextDrawSetSelectable(playerid, Register_Char_Player[playerid][2], 0);

        Register_Char_Player[playerid][3] = CreatePlayerTextDraw(playerid, 165.000000, 170.000000, "Ulicni Diler");
        PlayerTextDrawFont(playerid, Register_Char_Player[playerid][3], 2);
        PlayerTextDrawLetterSize(playerid, Register_Char_Player[playerid][3], 0.262499, 1.000000);
        PlayerTextDrawTextSize(playerid, Register_Char_Player[playerid][3], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, Register_Char_Player[playerid][3], 1);
        PlayerTextDrawSetShadow(playerid, Register_Char_Player[playerid][3], 0);
        PlayerTextDrawAlignment(playerid, Register_Char_Player[playerid][3], 1);
        PlayerTextDrawColor(playerid, Register_Char_Player[playerid][3], -1);
        PlayerTextDrawBackgroundColor(playerid, Register_Char_Player[playerid][3], 255);
        PlayerTextDrawBoxColor(playerid, Register_Char_Player[playerid][3], 0);
        PlayerTextDrawUseBox(playerid, Register_Char_Player[playerid][3], 1);
        PlayerTextDrawSetProportional(playerid, Register_Char_Player[playerid][3], 1);
        PlayerTextDrawSetSelectable(playerid, Register_Char_Player[playerid][3], 0);

        for(new i; i < sizeof(Register_Char_Global); i++) {
            TextDrawShowForPlayer(playerid, Register_Char_Global[i]);
        }

        for(new i; i < 4; i++) {
            PlayerTextDrawShow(playerid, Register_Char_Player[playerid][i]);
        }

        SelectTextDraw( playerid, 0x12C706FF );
    } 
    else {
        for(new i = 0; i < 4; i++) {
            if(Register_Char_Player[playerid][i] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, Register_Char_Player[playerid][i]);
            Register_Char_Player[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new i; i < sizeof(Register_Char_Global); i++) {
            TextDrawHideForPlayer(playerid, Register_Char_Global[i]);
        }
        CancelSelectTextDraw(playerid);
    }
}