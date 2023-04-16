/*
   ______              ____             __               __    _     
  / ____/___ ______   / __ \___  ____ _/ /__  __________/ /_  (_)___ 
 / /   / __ `/ ___/  / / / / _ \/ __ `/ / _ \/ ___/ ___/ __ \/ / __ \
/ /___/ /_/ / /     / /_/ /  __/ /_/ / /  __/ /  (__  ) / / / / /_/ /
\____/\__,_/_/     /_____/\___/\__,_/_/\___/_/  /____/_/ /_/_/ .___/ 
                                                            /_/      
    Developed by Danis Čavalić.
*/
 
#include    <ysilib\YSI_Coding\y_hooks>
#include 	"backend/vehicles/vehicles_data/utilities.pwn"

#define     MAX_DEALERSHIP_MODELS   8

static // ui
    Text:Dealership_GlobalTD[17],
    PlayerText:Dealership_PTD[MAX_PLAYERS][9] = {PlayerText:INVALID_TEXT_DRAW, ...},
    Text:Contract_GlobalTD[13],
    PlayerText:Contract_PTD[MAX_PLAYERS][7] = {PlayerText:INVALID_TEXT_DRAW, ...},
    // operations
    dealer_Player_Dealership[MAX_PLAYERS],
    dealer_Player_VehIndex[MAX_PLAYERS],
    dealer_Player_FuelIndex[MAX_PLAYERS],
    dealer_Player_ColIndex[MAX_PLAYERS],
    dealer_Player_WheelIndex[MAX_PLAYERS],
    dealer_Player_PayType[MAX_PLAYERS];

enum    E_DLS_PLAYER_PAY_TYPES
{
	pay_type_name[33],
    e_PAY_TYPE:pay_type,
	bool:pay_type_credit
}
static PayTypes[][E_DLS_PLAYER_PAY_TYPES] = {
	{"Cash", 				PAY_TYPE_POCKET,    false},
	{"Bankovni transfer", 	PAY_TYPE_BANK,      false},
	{"Kredit", 				PAY_TYPE_CREDIT,    true}
};

enum    E_DEALERSHIP_VEH_COLORS
{
	color_name[33],
	color_code,
	color_hex[10]
}
static VehicleColors[][E_DEALERSHIP_VEH_COLORS] = {
	{"Bijela", 				1, 		"FFFFFF"},
	{"Crna", 				0, 		"000000"},
	{"Plava", 				2, 		"00C0FF"},
	{"Crvena", 				3, 		"F81414"},
	{"Maslinasta", 	        51, 	"60B554"},
	{"Zelena", 				86, 	"36D720"},
	{"Roza", 				126, 	"FF9CFA"},
	{"Tamno plava", 		79, 	"0B72D3"},
	{"Svijetlo zuta", 		65, 	"F1F57A"},
	{"Narandzasta", 		158, 	"FF9300"}
};

enum    E_DEALERSHIP_VEH_WHEELS
{
	wheel_name[33],
	wheel_comp_id
}
static VehicleWheels[][E_DEALERSHIP_VEH_WHEELS] = {
	{"Shadow", 		1073},
	{"Mega", 		1074},
	{"Rimshine", 	1075},
	{"Wires", 		1076},
	{"Classic", 	1077},
	{"Twist", 		1078},
	{"Cutter", 		1079},
	{"Switch", 		1080},
	{"Grove", 		1081},
	{"Ahab", 		1096},
	{"Virtual", 	1097},
	{"Atomic", 		1085}
};

enum    E_DEALERSHIP_DATA
{
	dship_name[20],
    Float:dship_cam_pos[6],
    Float:dship_cam_look_pos[6],
    Float:dship_pos[3],
    Float:dship_vehicle_pos[4],
    Float:dship_vehicle_buy_pos[4],
    dship_veh_models[MAX_DEALERSHIP_MODELS],
    dship_int,
    dship_vw,

    dship_vehicle_id,
    Text3D:dship_label,
    dship_pickup,
    dship_player_id
}
static Dealership[][E_DEALERSHIP_DATA] = {
	{
        /* naziv salona */ "Grotti Cars",
        /* camera pos */ {1401.918090, -24.882469, 1003.693115, 1401.918090, -24.882469, 1003.693115},
        /* camera look at */ {1405.063842, -28.588148, 1002.521606, 1405.063842, -28.588148, 1002.521606},
        /* pozicija za kupovinu */ {1391.8030, -27.7318, 1000.8630},
        /* izlozbeni primjerak */ {1406.0607, -32.8932, 1002.6105, 64.3434},
        /* parking ispred salona */ {0.0, 0.0, 0.0, 0.0},
        /* dostupni modeli vozila */ {411, 560, 400, 541, 451, 581, 408, 522},
        /* interior id */ 1,
        /* virtual world */ 333
    }
};

OperateDealershipContract(playerid) {

    new 
        veh_index = dealer_Player_VehIndex[playerid],
        col_index = dealer_Player_ColIndex[playerid],
        wheel_index = dealer_Player_WheelIndex[playerid],
        id = dealer_Player_Dealership[playerid];
    dealer_Player_PayType[playerid] = 0;

    // toggle ui
    ToggleDealershipUI(playerid, false);
    ToggleContractUI(playerid, true);
    SetCameraBehindPlayer(playerid);

    // update ui
    new ui_operate_string[180];
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][0], Dealership[id][dship_name]);
    form:ui_operate_string("Ugovor o kupovini: %s", GetVehicleNameEx(Dealership[id][dship_veh_models][veh_index]));
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][1], ui_operate_string);
    form:ui_operate_string("Vozilo: %s~n~Boja: %s~n~Felge: %s~n~Cijena: $%d", 
                      GetVehicleNameEx(Dealership[id][dship_veh_models][veh_index]),
                      VehicleColors[col_index][color_name],
                      VehicleWheels[wheel_index][wheel_name],
                      VehPrice[ Dealership[id][dship_veh_models][veh_index]-400 ][ 1 ]);
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][2], ui_operate_string);
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][3], PayTypes[dealer_Player_PayType[playerid]][pay_type_name]);
    form:ui_operate_string("%s Dealership", Dealership[id][dship_name]);
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][4], ui_operate_string);
    form:ui_operate_string("Potvrdi: ~g~$%d", VehPrice[ Dealership[id][dship_veh_models][veh_index]-400 ][ 1 ]);
    PlayerTextDrawSetString(playerid, Contract_PTD[playerid][6], ui_operate_string);
}

stock OperateDealership(playerid) {
    new id = GetClosestDealershipID(playerid);
    if(id != -1 && Dealership[id][dship_player_id] == -1) {
        InterpolateCameraPos(
            playerid, 
            Dealership[id][dship_cam_pos][0], Dealership[id][dship_cam_pos][1], Dealership[id][dship_cam_pos][2],
            Dealership[id][dship_cam_pos][3], Dealership[id][dship_cam_pos][4], Dealership[id][dship_cam_pos][5],
            1000
        );
        InterpolateCameraLookAt(
            playerid, 
            Dealership[id][dship_cam_look_pos][0], Dealership[id][dship_cam_look_pos][1], Dealership[id][dship_cam_look_pos][2],
            Dealership[id][dship_cam_look_pos][3], Dealership[id][dship_cam_look_pos][4], Dealership[id][dship_cam_look_pos][5],
            1000
        );
        dealer_Player_Dealership[playerid] = id;
        dealer_Player_VehIndex[playerid] = dealer_Player_FuelIndex[playerid] = dealer_Player_ColIndex[playerid] = dealer_Player_WheelIndex[playerid] = 0;
        Dealership[id][dship_player_id] = playerid;

        ToggleDealershipUI(playerid, true);
        UpdateDealershipParams(playerid, true);
    }
}

DS_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
    // dealership > ugovor
    if(playertextid == Dealership_PTD[playerid][8]) {
        OperateDealershipContract(playerid);
    }
    // potpis ugovora
    else if(playertextid == Contract_PTD[playerid][6]) {
        //SendClientMessage(playerid, -1, "TBD");
    }
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
        if(newkeys & KEY_SECONDARY_ATTACK) {
            OperateDealership(playerid);
        }
    }
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
    // hide cursor
    /*if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        for(new i; i < sizeof(Dealership); i++) {
            if(Dealership[i][dship_player_id] == playerid) {
                Dealership[i][dship_player_id] = -1;
            }
        }
        ToggleDealershipUI(playerid, false);
        ToggleContractUI(playerid, false);
        SetCameraBehindPlayer(playerid);
    }*/
    // model
    if(clickedid == Dealership_GlobalTD[5]) {
        new index_size = MAX_DEALERSHIP_MODELS;
        if(dealer_Player_VehIndex[playerid] == 0) dealer_Player_VehIndex[playerid] = index_size - 1;
        else dealer_Player_VehIndex[playerid]--;
        UpdateDealershipParams(playerid, true);
    }
    else if(clickedid == Dealership_GlobalTD[6]) {
        new index_size = MAX_DEALERSHIP_MODELS;
        if(dealer_Player_VehIndex[playerid] == index_size - 1) dealer_Player_VehIndex[playerid] = 0;
        else dealer_Player_VehIndex[playerid]++;
        UpdateDealershipParams(playerid, true);
    }
    // gorivo
    else if(clickedid == Dealership_GlobalTD[8] || clickedid == Dealership_GlobalTD[9]) {
        dealer_Player_FuelIndex[playerid] = (dealer_Player_FuelIndex[playerid] == 0) ? 1 : 0;
        UpdateDealershipParams(playerid, false);
    }
    // boja
    else if(clickedid == Dealership_GlobalTD[12]) {
        new index_size = sizeof(VehicleColors);
        if(dealer_Player_ColIndex[playerid] == 0) dealer_Player_ColIndex[playerid] = index_size - 1;
        else dealer_Player_ColIndex[playerid]--;
        UpdateDealershipParams(playerid, false);
    }
    else if(clickedid == Dealership_GlobalTD[13]) {
        new index_size = sizeof(VehicleColors);
        if(dealer_Player_ColIndex[playerid] == index_size - 1) dealer_Player_ColIndex[playerid] = 0;
        else dealer_Player_ColIndex[playerid]++;
        UpdateDealershipParams(playerid, false);
    }
    // felge
    else if(clickedid == Dealership_GlobalTD[14]) {
        new index_size = sizeof(VehicleWheels);
        if(dealer_Player_WheelIndex[playerid] == 0) dealer_Player_WheelIndex[playerid] = index_size - 1;
        else dealer_Player_WheelIndex[playerid]--;
        UpdateDealershipParams(playerid, false);
    }
    else if(clickedid == Dealership_GlobalTD[15]) {
        new index_size = sizeof(VehicleWheels);
        if(dealer_Player_WheelIndex[playerid] == index_size - 1) dealer_Player_WheelIndex[playerid] = 0;
        else dealer_Player_WheelIndex[playerid]++;
        UpdateDealershipParams(playerid, false);
    }
    // contract: vrsta placanja
    else if(clickedid == Contract_GlobalTD[5]) {
        new index_size = sizeof(PayTypes);
        if(dealer_Player_PayType[playerid] == 0) dealer_Player_PayType[playerid] = index_size - 1;
        else dealer_Player_PayType[playerid]--;
        PlayerTextDrawSetString(playerid, Contract_PTD[playerid][3], PayTypes[dealer_Player_PayType[playerid]][pay_type_name]);
    }
    else if(clickedid == Contract_GlobalTD[6]) {
        new index_size = sizeof(PayTypes);
        if(dealer_Player_PayType[playerid] == index_size - 1) dealer_Player_PayType[playerid] = 0;
        else dealer_Player_PayType[playerid]++;
        PlayerTextDrawSetString(playerid, Contract_PTD[playerid][3], PayTypes[dealer_Player_PayType[playerid]][pay_type_name]);
    }
}

UpdateDealershipParams(playerid, bool: updatecar = false) {
    new 
        veh_index = dealer_Player_VehIndex[playerid],
        fuel_index = dealer_Player_FuelIndex[playerid],
        col_index = dealer_Player_ColIndex[playerid],
        wheel_index = dealer_Player_WheelIndex[playerid],
        id = dealer_Player_Dealership[playerid];

    // vehicle update
    if (updatecar) 
    {
        DestroyVehicle(Dealership[id][dship_vehicle_id]);
        Dealership[id][dship_vehicle_id] = CreateVehicle(
                Dealership[id][dship_veh_models][veh_index], 
                Dealership[id][dship_vehicle_pos][0], Dealership[id][dship_vehicle_pos][1], Dealership[id][dship_vehicle_pos][2], Dealership[id][dship_vehicle_pos][3], 
                VehicleColors[col_index][color_code], VehicleColors[col_index][color_code], 
                -1
            );
        LinkVehicleToInterior(Dealership[id][dship_vehicle_id], Dealership[id][dship_int]);
        SetVehicleVirtualWorld(Dealership[id][dship_vehicle_id], Dealership[id][dship_vw]);
    }
    AddVehicleComponent(Dealership[id][dship_vehicle_id], VehicleWheels[wheel_index][wheel_comp_id]);
    ChangeVehicleColor(Dealership[id][dship_vehicle_id], VehicleColors[col_index][color_code], VehicleColors[col_index][color_code]);

    // ui update
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][0], Dealership[id][dship_name]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][1], GetVehicleNameEx(Dealership[id][dship_veh_models][veh_index]));
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][2], (fuel_index == 0) ? ("Benzin") : ("Dizel"));
    new temporary_string[12];
    format(temporary_string, sizeof(temporary_string), "0x%sFF", VehicleColors[col_index][color_hex]);
    PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][3], HexToInt(temporary_string));
    PlayerTextDrawColor(playerid, Dealership_PTD[playerid][3], HexToInt(temporary_string));
    PlayerTextDrawShow(playerid, Dealership_PTD[playerid][3]);
    PlayerTextDrawSetPreviewModel(playerid, Dealership_PTD[playerid][4], VehicleWheels[wheel_index][wheel_comp_id]);
    PlayerTextDrawShow(playerid, Dealership_PTD[playerid][4]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][5], VehicleColors[col_index][color_name]);
    PlayerTextDrawColor(playerid, Dealership_PTD[playerid][5], HexToInt(temporary_string));
    PlayerTextDrawShow(playerid, Dealership_PTD[playerid][5]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][6], VehicleWheels[wheel_index][wheel_name]);
    new ugovor_text[180], pregled_text[35];
    form:ugovor_text("Nakon odabira zeljenog modela, tipa pogonskog goriva, te specifikacija vezanih za samo vozilo \
                      biti ce vam prikazan salonski ugovor, cijim potpisom osiguravate kupovinu vozila. Nakon potpisa \
                      vozilo ce vam biti dostavljeno ispred salona. Vrijednost ugovora je: ~g~$%d", VehPrice[ Dealership[id][dship_veh_models][veh_index]-400 ][ 1 ]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][7], ugovor_text);
    form:pregled_text("Pregledaj ugovor: ~g~$%d", VehPrice[ Dealership[id][dship_veh_models][veh_index]-400 ][ 1 ]);
    PlayerTextDrawSetString(playerid, Dealership_PTD[playerid][8], pregled_text);
}

stock GetClosestDealershipID(playerid, Float: range = 5.0) 
{
    new Float:x, Float:y, Float:z;

	if (!GetPlayerPos(playerid, x, y, z))
	{
		return -1;
	}

	new Float:distance = FLOAT_INFINITY, closestid = -1, Float:distance2;

    for(new i; i < sizeof(Dealership); i++) 
    {
        distance2 = VectorSize(x - Dealership[i][dship_pos][0], y - Dealership[i][dship_pos][1], z - Dealership[i][dship_pos][2]);
        if (distance2 < distance && distance2 <= range)
        {
            distance = distance2;
            closestid = i;
        }
    }

    return closestid;
}

hook OnPlayerDisconnect(playerid, reason) {
    for(new i; i < sizeof(Dealership); i++) {
        if(Dealership[i][dship_player_id] == playerid) {
            Dealership[i][dship_player_id] = -1;
        }
    }
    ToggleDealershipUI(playerid, false);
    ToggleContractUI(playerid, false);
}

hook OnPlayerDeath(playerid, killerid, reason) {
    for(new i; i < sizeof(Dealership); i++) {
        if(Dealership[i][dship_player_id] == playerid) {
            Dealership[i][dship_player_id] = -1;
        }
    }
    ToggleDealershipUI(playerid, false);
    ToggleContractUI(playerid, false);
}

stock HexToInt(value[]) // By DracoBlue
{
    if (value[0]==0) return 0;
    new i;
    new cur=1;
    new res=0;
    for (i=strlen(value);i>0;i--) {
        if (value[i-1]<58) res=res+cur*(value[i-1]-48); else res=res+cur*(value[i-1]-65+10);
        cur=cur*16;
    }
    return res;
}

stock ToggleDealershipUI(playerid, bool:toggle = true) {
    if (toggle) {
        Dealership_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 124.000000, 140.000000, "OTTOS CARS");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][0], 2);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][0], 0.283333, 1.200001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][0], 400.000000, 137.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][0], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][0], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][0], 2);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][0], 1687547391);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][0], 255);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][0], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][0], 1);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][0], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][0], 0);

        Dealership_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 111.000000, 172.000000, "Infernus");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][1], 2);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][1], 0.283333, 1.050001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][1], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][1], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][1], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][1], 1);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][1], -1);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][1], 255);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][1], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][1], 1);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][1], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][1], 0);

        Dealership_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 111.000000, 191.000000, "BENZIN");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][2], 2);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][2], 0.283333, 1.050001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][2], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][2], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][2], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][2], 1);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][2], -1);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][2], 255);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][2], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][2], 1);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][2], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][2], 0);

        Dealership_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 54.000000, 228.000000, "ld_beat:chit");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][3], 4);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][3], 0.600000, 2.000000);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][3], 30.000000, 30.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][3], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][3], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][3], 1);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][3], 852308735);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][3], 255);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][3], 50);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][3], 1);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][3], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][3], 0);

        Dealership_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 153.000000, 229.000000, "Preview_Model");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][4], 5);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][4], 0.600000, 2.000000);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][4], 28.500000, 28.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][4], 1);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][4], -1);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][4], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][4], 0);
        PlayerTextDrawSetPreviewModel(playerid, Dealership_PTD[playerid][4], 1080);
        PlayerTextDrawSetPreviewRot(playerid, Dealership_PTD[playerid][4], -10.000000, 0.000000, 90.000000, 1.000000);
        PlayerTextDrawSetPreviewVehCol(playerid, Dealership_PTD[playerid][4], 1, 1);

        Dealership_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 69.000000, 258.000000, "Svijetlo Zelena");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][5], 3);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][5], 0.191666, 0.750001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][5], 400.000000, 152.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][5], 0);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][5], 1);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][5], 2);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][5], 852308735);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][5], 255);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][5], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][5], 0);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][5], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][5], 0);

        Dealership_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 168.000000, 258.000000, "Switch");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][6], 3);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][6], 0.191666, 0.750001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][6], 400.000000, 152.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][6], 0);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][6], 1);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][6], 2);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][6], -741092353);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][6], 255);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][6], 0);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][6], 0);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][6], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][6], 0);

        Dealership_PTD[playerid][7] = CreatePlayerTextDraw(playerid, 29.000000, 277.000000, "Nakon sto odaberete model i odgovarajuce specifikacije, mozete preci na pregled ugovora za vozilo. Cijena ovog vozila je: ~g~$1");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][7], 1);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][7], 0.191666, 0.750001);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][7], 218.000000, 242.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][7], 0);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][7], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][7], 1);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][7], -741092353);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][7], 255);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][7], 74);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][7], 1);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][7], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][7], 0);

        Dealership_PTD[playerid][8] = CreatePlayerTextDraw(playerid, 123.000000, 318.000000, "Pregled ugovora: ~g~$1");
        PlayerTextDrawFont(playerid, Dealership_PTD[playerid][8], 1);
        PlayerTextDrawLetterSize(playerid, Dealership_PTD[playerid][8], 0.187499, 0.850000);
        PlayerTextDrawTextSize(playerid, Dealership_PTD[playerid][8], 18.000000, 188.000000);
        PlayerTextDrawSetOutline(playerid, Dealership_PTD[playerid][8], 1);
        PlayerTextDrawSetShadow(playerid, Dealership_PTD[playerid][8], 0);
        PlayerTextDrawAlignment(playerid, Dealership_PTD[playerid][8], 2);
        PlayerTextDrawColor(playerid, Dealership_PTD[playerid][8], -1);
        PlayerTextDrawBackgroundColor(playerid, Dealership_PTD[playerid][8], 255);
        PlayerTextDrawBoxColor(playerid, Dealership_PTD[playerid][8], 200);
        PlayerTextDrawUseBox(playerid, Dealership_PTD[playerid][8], 1);
        PlayerTextDrawSetProportional(playerid, Dealership_PTD[playerid][8], 1);
        PlayerTextDrawSetSelectable(playerid, Dealership_PTD[playerid][8], 1);

        for(new i; i < sizeof(Dealership_GlobalTD); i++) {
            TextDrawShowForPlayer(playerid, Dealership_GlobalTD[i]);
        }

        for(new i; i < 9; i++) {
            PlayerTextDrawShow(playerid, Dealership_PTD[playerid][i]);
        }

        SelectTextDraw( playerid, 0x12C706FF );
    }
    else {
        for(new i = 0; i < 9; i++) {
            if(Dealership_PTD[playerid][i] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, Dealership_PTD[playerid][i]);
            Dealership_PTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new i; i < sizeof(Dealership_GlobalTD); i++) {
            TextDrawHideForPlayer(playerid, Dealership_GlobalTD[i]);
        }
        CancelSelectTextDraw(playerid);
    }
}

stock ToggleContractUI(playerid, bool:toggle = true) {
    if (toggle) {

        Contract_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 316.000000, 104.000000, "Ottos Autos");
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][0], 2);
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][0], 0.266666, 1.250000);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][0], 400.000000, 197.000000);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][0], 1);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][0], 0);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][0], 2);
        PlayerTextDrawColor(playerid, Contract_PTD[playerid][0], -1);
        PlayerTextDrawBackgroundColor(playerid, Contract_PTD[playerid][0], 255);
        PlayerTextDrawBoxColor(playerid, Contract_PTD[playerid][0], 50);
        PlayerTextDrawUseBox(playerid, Contract_PTD[playerid][0], 0);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][0], 1);
        PlayerTextDrawSetSelectable(playerid, Contract_PTD[playerid][0], 0);

        Contract_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 314.000000, 128.000000, "Ugovor o kupovini: Infernus");
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][1], 1);
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][1], 0.170833, 0.750000);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][1], 400.000000, 197.000000);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][1], 0);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][1], 0);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][1], 2);
        PlayerTextDrawColor(playerid, Contract_PTD[playerid][1], 1296911871);
        PlayerTextDrawBackgroundColor(playerid, Contract_PTD[playerid][1], 255);
        PlayerTextDrawBoxColor(playerid, Contract_PTD[playerid][1], 50);
        PlayerTextDrawUseBox(playerid, Contract_PTD[playerid][1], 0);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][1], 1);
        PlayerTextDrawSetSelectable(playerid, Contract_PTD[playerid][1], 0);

        Contract_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 211.000000, 159.000000, "Vozilo: Infernus~n~Boja: Svijetlo Zelena~n~Felge: Switch~n~Cijena: $1");
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][2], 1);
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][2], 0.170833, 0.750000);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][2], 400.000000, 197.000000);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][2], 0);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][2], 0);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][2], 1);
        PlayerTextDrawColor(playerid, Contract_PTD[playerid][2], 1296911871);
        PlayerTextDrawBackgroundColor(playerid, Contract_PTD[playerid][2], 255);
        PlayerTextDrawBoxColor(playerid, Contract_PTD[playerid][2], 50);
        PlayerTextDrawUseBox(playerid, Contract_PTD[playerid][2], 0);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][2], 1);
        PlayerTextDrawSetSelectable(playerid, Contract_PTD[playerid][2], 0);

        Contract_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 243.000000, 215.000000, "BANKOVNI TRANSFER");
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][3], 2);
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][3], 0.170833, 0.750000);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][3], 400.000000, 197.000000);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][3], 0);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][3], 0);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][3], 1);
        PlayerTextDrawColor(playerid, Contract_PTD[playerid][3], 1296911871);
        PlayerTextDrawBackgroundColor(playerid, Contract_PTD[playerid][3], 255);
        PlayerTextDrawBoxColor(playerid, Contract_PTD[playerid][3], 50);
        PlayerTextDrawUseBox(playerid, Contract_PTD[playerid][3], 0);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][3], 1);
        PlayerTextDrawSetSelectable(playerid, Contract_PTD[playerid][3], 0);

        Contract_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 238.000000, 313.000000, "Ottos Autos Dealership");
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][4], 1);
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][4], 0.170833, 0.750000);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][4], 400.000000, 197.000000);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][4], 0);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][4], 0);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][4], 2);
        PlayerTextDrawColor(playerid, Contract_PTD[playerid][4], 1296911871);
        PlayerTextDrawBackgroundColor(playerid, Contract_PTD[playerid][4], 255);
        PlayerTextDrawBoxColor(playerid, Contract_PTD[playerid][4], 50);
        PlayerTextDrawUseBox(playerid, Contract_PTD[playerid][4], 0);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][4], 1);
        PlayerTextDrawSetSelectable(playerid, Contract_PTD[playerid][4], 0);

        Contract_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 385.000000, 313.000000, ReturnPlayerName(playerid));
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][5], 1);
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][5], 0.170833, 0.750000);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][5], 400.000000, 197.000000);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][5], 0);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][5], 0);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][5], 2);
        PlayerTextDrawColor(playerid, Contract_PTD[playerid][5], 1296911871);
        PlayerTextDrawBackgroundColor(playerid, Contract_PTD[playerid][5], 255);
        PlayerTextDrawBoxColor(playerid, Contract_PTD[playerid][5], 50);
        PlayerTextDrawUseBox(playerid, Contract_PTD[playerid][5], 0);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][5], 1);
        PlayerTextDrawSetSelectable(playerid, Contract_PTD[playerid][5], 0);

        Contract_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 314.000000, 338.000000, "POTVRDI: ~g~$1");
        PlayerTextDrawFont(playerid, Contract_PTD[playerid][6], 1);
        PlayerTextDrawLetterSize(playerid, Contract_PTD[playerid][6], 0.258332, 1.100000);
        PlayerTextDrawTextSize(playerid, Contract_PTD[playerid][6], 19.500000, 200.000000);
        PlayerTextDrawSetOutline(playerid, Contract_PTD[playerid][6], 1);
        PlayerTextDrawSetShadow(playerid, Contract_PTD[playerid][6], 0);
        PlayerTextDrawAlignment(playerid, Contract_PTD[playerid][6], 2);
        PlayerTextDrawColor(playerid, Contract_PTD[playerid][6], -1);
        PlayerTextDrawBackgroundColor(playerid, Contract_PTD[playerid][6], 255);
        PlayerTextDrawBoxColor(playerid, Contract_PTD[playerid][6], 1296911816);
        PlayerTextDrawUseBox(playerid, Contract_PTD[playerid][6], 1);
        PlayerTextDrawSetProportional(playerid, Contract_PTD[playerid][6], 1);
        PlayerTextDrawSetSelectable(playerid, Contract_PTD[playerid][6], 1);

        for(new i; i < sizeof(Contract_GlobalTD); i++) {
            TextDrawShowForPlayer(playerid, Contract_GlobalTD[i]);
        }

        for(new i; i < 7; i++) {
            PlayerTextDrawShow(playerid, Contract_PTD[playerid][i]);
        }

        SelectTextDraw( playerid, 0x12C706FF );
    }
    else {
        for(new i = 0; i < 7; i++) {
            if(Contract_PTD[playerid][i] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, Contract_PTD[playerid][i]);
            Contract_PTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
        for(new i; i < sizeof(Contract_GlobalTD); i++) {
            TextDrawHideForPlayer(playerid, Contract_GlobalTD[i]);
        }
        CancelSelectTextDraw(playerid);
    }
}

hook OnGameModeInit() {
    DS_LoadDealershipsData();
    DS_LoadGlobalTextDraws();
}

DS_LoadDealershipsData() {
    new format_string[220];
    for(new i; i < sizeof(Dealership); i++) {
        form:format_string(""c_blue"°°°°°°°°°°°°°°°°°°°°\nDealership\n{FFFFFF}%s\n\n"c_blue"Katalog salona: {FFFFFF}/katalog\n"c_blue"Brza tipka: {FFFFFF}F\n"c_blue"°°°°°°°°°°°°°°°°°°°°", Dealership[i][dship_name]);
        Dealership[i][dship_label] = CreateDynamic3DTextLabel(format_string, 0xFFFFFFFF, Dealership[i][dship_pos][0], Dealership[i][dship_pos][1], Dealership[i][dship_pos][2] + 1, 15.0, .interiorid = Dealership[i][dship_int], .worldid = Dealership[i][dship_vw], .testlos = 1);
        Dealership[i][dship_pickup] = CreateDynamicPickup(1272, 1, Dealership[i][dship_pos][0], Dealership[i][dship_pos][1], Dealership[i][dship_pos][2], .interiorid = Dealership[i][dship_int], .worldid = Dealership[i][dship_vw]);
        Dealership[i][dship_vehicle_id] = CreateVehicle(
                Dealership[i][dship_veh_models][0], 
                Dealership[i][dship_vehicle_pos][0], Dealership[i][dship_vehicle_pos][1], Dealership[i][dship_vehicle_pos][2], 
                Dealership[i][dship_vehicle_pos][3], 
                1, 1, -1
            );
        LinkVehicleToInterior(Dealership[i][dship_vehicle_id], Dealership[i][dship_int]);
        SetVehicleVirtualWorld(Dealership[i][dship_vehicle_id], Dealership[i][dship_vw]);
        Dealership[i][dship_player_id] = -1;
    }
}

DS_LoadGlobalTextDraws() {
    // Dealership
    Dealership_GlobalTD[0] = TextDrawCreate(124.000000, 137.000000, "_");
    TextDrawFont(Dealership_GlobalTD[0], 1);
    TextDrawLetterSize(Dealership_GlobalTD[0], 0.625000, 21.650001);
    TextDrawTextSize(Dealership_GlobalTD[0], 298.500000, 200.000000);
    TextDrawSetOutline(Dealership_GlobalTD[0], 1);
    TextDrawSetShadow(Dealership_GlobalTD[0], 0);
    TextDrawAlignment(Dealership_GlobalTD[0], 2);
    TextDrawColor(Dealership_GlobalTD[0], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[0], 255);
    TextDrawBoxColor(Dealership_GlobalTD[0], 1097458055);
    TextDrawUseBox(Dealership_GlobalTD[0], 1);
    TextDrawSetProportional(Dealership_GlobalTD[0], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[0], 0);

    Dealership_GlobalTD[1] = TextDrawCreate(124.000000, 141.000000, "_");
    TextDrawFont(Dealership_GlobalTD[1], 1);
    TextDrawLetterSize(Dealership_GlobalTD[1], 0.625000, 20.650016);
    TextDrawTextSize(Dealership_GlobalTD[1], 298.500000, 193.500000);
    TextDrawSetOutline(Dealership_GlobalTD[1], 1);
    TextDrawSetShadow(Dealership_GlobalTD[1], 0);
    TextDrawAlignment(Dealership_GlobalTD[1], 2);
    TextDrawColor(Dealership_GlobalTD[1], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[1], 255);
    TextDrawBoxColor(Dealership_GlobalTD[1], 135);
    TextDrawUseBox(Dealership_GlobalTD[1], 1);
    TextDrawSetProportional(Dealership_GlobalTD[1], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[1], 0);

    Dealership_GlobalTD[2] = TextDrawCreate(98.000000, 150.000000, "dealership");
    TextDrawFont(Dealership_GlobalTD[2], 3);
    TextDrawLetterSize(Dealership_GlobalTD[2], 0.283333, 1.050001);
    TextDrawTextSize(Dealership_GlobalTD[2], 400.000000, 17.000000);
    TextDrawSetOutline(Dealership_GlobalTD[2], 1);
    TextDrawSetShadow(Dealership_GlobalTD[2], 0);
    TextDrawAlignment(Dealership_GlobalTD[2], 1);
    TextDrawColor(Dealership_GlobalTD[2], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[2], 255);
    TextDrawBoxColor(Dealership_GlobalTD[2], 0);
    TextDrawUseBox(Dealership_GlobalTD[2], 1);
    TextDrawSetProportional(Dealership_GlobalTD[2], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[2], 0);

    Dealership_GlobalTD[3] = TextDrawCreate(124.000000, 163.000000, "_");
    TextDrawFont(Dealership_GlobalTD[3], 1);
    TextDrawLetterSize(Dealership_GlobalTD[3], 0.625000, 0.049996);
    TextDrawTextSize(Dealership_GlobalTD[3], 298.500000, 194.000000);
    TextDrawSetOutline(Dealership_GlobalTD[3], 1);
    TextDrawSetShadow(Dealership_GlobalTD[3], 0);
    TextDrawAlignment(Dealership_GlobalTD[3], 2);
    TextDrawColor(Dealership_GlobalTD[3], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[3], 255);
    TextDrawBoxColor(Dealership_GlobalTD[3], 1097458055);
    TextDrawUseBox(Dealership_GlobalTD[3], 1);
    TextDrawSetProportional(Dealership_GlobalTD[3], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[3], 0);

    Dealership_GlobalTD[4] = TextDrawCreate(34.000000, 172.000000, "MODEL:");
    TextDrawFont(Dealership_GlobalTD[4], 3);
    TextDrawLetterSize(Dealership_GlobalTD[4], 0.283333, 1.050001);
    TextDrawTextSize(Dealership_GlobalTD[4], 400.000000, 17.000000);
    TextDrawSetOutline(Dealership_GlobalTD[4], 1);
    TextDrawSetShadow(Dealership_GlobalTD[4], 0);
    TextDrawAlignment(Dealership_GlobalTD[4], 1);
    TextDrawColor(Dealership_GlobalTD[4], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[4], 255);
    TextDrawBoxColor(Dealership_GlobalTD[4], 0);
    TextDrawUseBox(Dealership_GlobalTD[4], 1);
    TextDrawSetProportional(Dealership_GlobalTD[4], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[4], 0);

    Dealership_GlobalTD[5] = TextDrawCreate(73.000000, 171.000000, "ld_beat:left");
    TextDrawFont(Dealership_GlobalTD[5], 4);
    TextDrawLetterSize(Dealership_GlobalTD[5], 0.600000, 2.000000);
    TextDrawTextSize(Dealership_GlobalTD[5], 13.000000, 12.500000);
    TextDrawSetOutline(Dealership_GlobalTD[5], 1);
    TextDrawSetShadow(Dealership_GlobalTD[5], 0);
    TextDrawAlignment(Dealership_GlobalTD[5], 1);
    TextDrawColor(Dealership_GlobalTD[5], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[5], 255);
    TextDrawBoxColor(Dealership_GlobalTD[5], 50);
    TextDrawUseBox(Dealership_GlobalTD[5], 1);
    TextDrawSetProportional(Dealership_GlobalTD[5], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[5], 1);

    Dealership_GlobalTD[6] = TextDrawCreate(92.000000, 171.000000, "LD_BEAT:right");
    TextDrawFont(Dealership_GlobalTD[6], 4);
    TextDrawLetterSize(Dealership_GlobalTD[6], 0.600000, 2.000000);
    TextDrawTextSize(Dealership_GlobalTD[6], 13.000000, 12.500000);
    TextDrawSetOutline(Dealership_GlobalTD[6], 1);
    TextDrawSetShadow(Dealership_GlobalTD[6], 0);
    TextDrawAlignment(Dealership_GlobalTD[6], 1);
    TextDrawColor(Dealership_GlobalTD[6], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[6], 255);
    TextDrawBoxColor(Dealership_GlobalTD[6], 50);
    TextDrawUseBox(Dealership_GlobalTD[6], 1);
    TextDrawSetProportional(Dealership_GlobalTD[6], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[6], 1);

    Dealership_GlobalTD[7] = TextDrawCreate(34.000000, 191.000000, "GORIVO:");
    TextDrawFont(Dealership_GlobalTD[7], 3);
    TextDrawLetterSize(Dealership_GlobalTD[7], 0.283333, 1.050001);
    TextDrawTextSize(Dealership_GlobalTD[7], 400.000000, 17.000000);
    TextDrawSetOutline(Dealership_GlobalTD[7], 1);
    TextDrawSetShadow(Dealership_GlobalTD[7], 0);
    TextDrawAlignment(Dealership_GlobalTD[7], 1);
    TextDrawColor(Dealership_GlobalTD[7], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[7], 255);
    TextDrawBoxColor(Dealership_GlobalTD[7], 0);
    TextDrawUseBox(Dealership_GlobalTD[7], 1);
    TextDrawSetProportional(Dealership_GlobalTD[7], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[7], 0);

    Dealership_GlobalTD[8] = TextDrawCreate(73.000000, 190.000000, "ld_beat:left");
    TextDrawFont(Dealership_GlobalTD[8], 4);
    TextDrawLetterSize(Dealership_GlobalTD[8], 0.600000, 2.000000);
    TextDrawTextSize(Dealership_GlobalTD[8], 13.000000, 12.500000);
    TextDrawSetOutline(Dealership_GlobalTD[8], 1);
    TextDrawSetShadow(Dealership_GlobalTD[8], 0);
    TextDrawAlignment(Dealership_GlobalTD[8], 1);
    TextDrawColor(Dealership_GlobalTD[8], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[8], 255);
    TextDrawBoxColor(Dealership_GlobalTD[8], 50);
    TextDrawUseBox(Dealership_GlobalTD[8], 1);
    TextDrawSetProportional(Dealership_GlobalTD[8], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[8], 1);

    Dealership_GlobalTD[9] = TextDrawCreate(92.000000, 190.000000, "LD_BEAT:right");
    TextDrawFont(Dealership_GlobalTD[9], 4);
    TextDrawLetterSize(Dealership_GlobalTD[9], 0.600000, 2.000000);
    TextDrawTextSize(Dealership_GlobalTD[9], 13.000000, 12.500000);
    TextDrawSetOutline(Dealership_GlobalTD[9], 1);
    TextDrawSetShadow(Dealership_GlobalTD[9], 0);
    TextDrawAlignment(Dealership_GlobalTD[9], 1);
    TextDrawColor(Dealership_GlobalTD[9], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[9], 255);
    TextDrawBoxColor(Dealership_GlobalTD[9], 50);
    TextDrawUseBox(Dealership_GlobalTD[9], 1);
    TextDrawSetProportional(Dealership_GlobalTD[9], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[9], 1);

    Dealership_GlobalTD[10] = TextDrawCreate(124.000000, 209.000000, "_");
    TextDrawFont(Dealership_GlobalTD[10], 1);
    TextDrawLetterSize(Dealership_GlobalTD[10], 0.625000, 0.049996);
    TextDrawTextSize(Dealership_GlobalTD[10], 298.500000, 194.000000);
    TextDrawSetOutline(Dealership_GlobalTD[10], 1);
    TextDrawSetShadow(Dealership_GlobalTD[10], 0);
    TextDrawAlignment(Dealership_GlobalTD[10], 2);
    TextDrawColor(Dealership_GlobalTD[10], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[10], 255);
    TextDrawBoxColor(Dealership_GlobalTD[10], 1097458055);
    TextDrawUseBox(Dealership_GlobalTD[10], 1);
    TextDrawSetProportional(Dealership_GlobalTD[10], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[10], 0);

    Dealership_GlobalTD[11] = TextDrawCreate(34.000000, 214.000000, "Zeljene specifikacije:");
    TextDrawFont(Dealership_GlobalTD[11], 3);
    TextDrawLetterSize(Dealership_GlobalTD[11], 0.283333, 1.050001);
    TextDrawTextSize(Dealership_GlobalTD[11], 400.000000, 17.000000);
    TextDrawSetOutline(Dealership_GlobalTD[11], 1);
    TextDrawSetShadow(Dealership_GlobalTD[11], 0);
    TextDrawAlignment(Dealership_GlobalTD[11], 1);
    TextDrawColor(Dealership_GlobalTD[11], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[11], 255);
    TextDrawBoxColor(Dealership_GlobalTD[11], 0);
    TextDrawUseBox(Dealership_GlobalTD[11], 1);
    TextDrawSetProportional(Dealership_GlobalTD[11], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[11], 0);

    Dealership_GlobalTD[12] = TextDrawCreate(43.000000, 237.000000, "ld_beat:left");
    TextDrawFont(Dealership_GlobalTD[12], 4);
    TextDrawLetterSize(Dealership_GlobalTD[12], 0.600000, 2.000000);
    TextDrawTextSize(Dealership_GlobalTD[12], 13.000000, 12.500000);
    TextDrawSetOutline(Dealership_GlobalTD[12], 1);
    TextDrawSetShadow(Dealership_GlobalTD[12], 0);
    TextDrawAlignment(Dealership_GlobalTD[12], 1);
    TextDrawColor(Dealership_GlobalTD[12], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[12], 255);
    TextDrawBoxColor(Dealership_GlobalTD[12], 50);
    TextDrawUseBox(Dealership_GlobalTD[12], 1);
    TextDrawSetProportional(Dealership_GlobalTD[12], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[12], 1);

    Dealership_GlobalTD[13] = TextDrawCreate(82.000000, 237.000000, "LD_BEAT:right");
    TextDrawFont(Dealership_GlobalTD[13], 4);
    TextDrawLetterSize(Dealership_GlobalTD[13], 0.600000, 2.000000);
    TextDrawTextSize(Dealership_GlobalTD[13], 13.000000, 12.500000);
    TextDrawSetOutline(Dealership_GlobalTD[13], 1);
    TextDrawSetShadow(Dealership_GlobalTD[13], 0);
    TextDrawAlignment(Dealership_GlobalTD[13], 1);
    TextDrawColor(Dealership_GlobalTD[13], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[13], 255);
    TextDrawBoxColor(Dealership_GlobalTD[13], 50);
    TextDrawUseBox(Dealership_GlobalTD[13], 1);
    TextDrawSetProportional(Dealership_GlobalTD[13], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[13], 1);

    Dealership_GlobalTD[14] = TextDrawCreate(139.000000, 237.000000, "ld_beat:left");
    TextDrawFont(Dealership_GlobalTD[14], 4);
    TextDrawLetterSize(Dealership_GlobalTD[14], 0.600000, 2.000000);
    TextDrawTextSize(Dealership_GlobalTD[14], 13.000000, 12.500000);
    TextDrawSetOutline(Dealership_GlobalTD[14], 1);
    TextDrawSetShadow(Dealership_GlobalTD[14], 0);
    TextDrawAlignment(Dealership_GlobalTD[14], 1);
    TextDrawColor(Dealership_GlobalTD[14], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[14], 255);
    TextDrawBoxColor(Dealership_GlobalTD[14], 50);
    TextDrawUseBox(Dealership_GlobalTD[14], 1);
    TextDrawSetProportional(Dealership_GlobalTD[14], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[14], 1);

    Dealership_GlobalTD[15] = TextDrawCreate(184.000000, 237.000000, "LD_BEAT:right");
    TextDrawFont(Dealership_GlobalTD[15], 4);
    TextDrawLetterSize(Dealership_GlobalTD[15], 0.600000, 2.000000);
    TextDrawTextSize(Dealership_GlobalTD[15], 13.000000, 12.500000);
    TextDrawSetOutline(Dealership_GlobalTD[15], 1);
    TextDrawSetShadow(Dealership_GlobalTD[15], 0);
    TextDrawAlignment(Dealership_GlobalTD[15], 1);
    TextDrawColor(Dealership_GlobalTD[15], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[15], 255);
    TextDrawBoxColor(Dealership_GlobalTD[15], 50);
    TextDrawUseBox(Dealership_GlobalTD[15], 1);
    TextDrawSetProportional(Dealership_GlobalTD[15], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[15], 1);

    Dealership_GlobalTD[16] = TextDrawCreate(124.000000, 271.000000, "_");
    TextDrawFont(Dealership_GlobalTD[16], 1);
    TextDrawLetterSize(Dealership_GlobalTD[16], 0.625000, 0.049996);
    TextDrawTextSize(Dealership_GlobalTD[16], 298.500000, 194.000000);
    TextDrawSetOutline(Dealership_GlobalTD[16], 1);
    TextDrawSetShadow(Dealership_GlobalTD[16], 0);
    TextDrawAlignment(Dealership_GlobalTD[16], 2);
    TextDrawColor(Dealership_GlobalTD[16], -1);
    TextDrawBackgroundColor(Dealership_GlobalTD[16], 255);
    TextDrawBoxColor(Dealership_GlobalTD[16], 1097458055);
    TextDrawUseBox(Dealership_GlobalTD[16], 1);
    TextDrawSetProportional(Dealership_GlobalTD[16], 1);
    TextDrawSetSelectable(Dealership_GlobalTD[16], 0);

    // Contract
    Contract_GlobalTD[0] = TextDrawCreate(315.000000, 98.000000, "_");
    TextDrawFont(Contract_GlobalTD[0], 1);
    TextDrawLetterSize(Contract_GlobalTD[0], 0.600000, 26.300003);
    TextDrawTextSize(Contract_GlobalTD[0], 298.500000, 239.500000);
    TextDrawSetOutline(Contract_GlobalTD[0], 1);
    TextDrawSetShadow(Contract_GlobalTD[0], 0);
    TextDrawAlignment(Contract_GlobalTD[0], 2);
    TextDrawColor(Contract_GlobalTD[0], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[0], 255);
    TextDrawBoxColor(Contract_GlobalTD[0], -1094795521);
    TextDrawUseBox(Contract_GlobalTD[0], 1);
    TextDrawSetProportional(Contract_GlobalTD[0], 1);
    TextDrawSetSelectable(Contract_GlobalTD[0], 0);

    Contract_GlobalTD[1] = TextDrawCreate(315.000000, 104.000000, "_");
    TextDrawFont(Contract_GlobalTD[1], 1);
    TextDrawLetterSize(Contract_GlobalTD[1], 0.600000, 24.650005);
    TextDrawTextSize(Contract_GlobalTD[1], 298.500000, 227.500000);
    TextDrawSetOutline(Contract_GlobalTD[1], 2);
    TextDrawSetShadow(Contract_GlobalTD[1], 0);
    TextDrawAlignment(Contract_GlobalTD[1], 2);
    TextDrawColor(Contract_GlobalTD[1], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[1], 255);
    TextDrawBoxColor(Contract_GlobalTD[1], -161);
    TextDrawUseBox(Contract_GlobalTD[1], 1);
    TextDrawSetProportional(Contract_GlobalTD[1], 1);
    TextDrawSetSelectable(Contract_GlobalTD[1], 0);

    Contract_GlobalTD[2] = TextDrawCreate(316.000000, 115.000000, "deal contract");
    TextDrawFont(Contract_GlobalTD[2], 3);
    TextDrawLetterSize(Contract_GlobalTD[2], 0.266666, 0.950000);
    TextDrawTextSize(Contract_GlobalTD[2], 400.000000, 197.000000);
    TextDrawSetOutline(Contract_GlobalTD[2], 1);
    TextDrawSetShadow(Contract_GlobalTD[2], 0);
    TextDrawAlignment(Contract_GlobalTD[2], 2);
    TextDrawColor(Contract_GlobalTD[2], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[2], 255);
    TextDrawBoxColor(Contract_GlobalTD[2], 50);
    TextDrawUseBox(Contract_GlobalTD[2], 0);
    TextDrawSetProportional(Contract_GlobalTD[2], 1);
    TextDrawSetSelectable(Contract_GlobalTD[2], 0);

    Contract_GlobalTD[3] = TextDrawCreate(264.000000, 147.000000, "Odabrane postavke kupovine:");
    TextDrawFont(Contract_GlobalTD[3], 3);
    TextDrawLetterSize(Contract_GlobalTD[3], 0.220833, 0.850000);
    TextDrawTextSize(Contract_GlobalTD[3], 400.000000, 197.000000);
    TextDrawSetOutline(Contract_GlobalTD[3], 1);
    TextDrawSetShadow(Contract_GlobalTD[3], 0);
    TextDrawAlignment(Contract_GlobalTD[3], 2);
    TextDrawColor(Contract_GlobalTD[3], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[3], 255);
    TextDrawBoxColor(Contract_GlobalTD[3], 50);
    TextDrawUseBox(Contract_GlobalTD[3], 0);
    TextDrawSetProportional(Contract_GlobalTD[3], 1);
    TextDrawSetSelectable(Contract_GlobalTD[3], 0);

    Contract_GlobalTD[4] = TextDrawCreate(258.000000, 200.000000, "odaberite nacin placanja:");
    TextDrawFont(Contract_GlobalTD[4], 3);
    TextDrawLetterSize(Contract_GlobalTD[4], 0.220833, 0.850000);
    TextDrawTextSize(Contract_GlobalTD[4], 400.000000, 197.000000);
    TextDrawSetOutline(Contract_GlobalTD[4], 1);
    TextDrawSetShadow(Contract_GlobalTD[4], 0);
    TextDrawAlignment(Contract_GlobalTD[4], 2);
    TextDrawColor(Contract_GlobalTD[4], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[4], 255);
    TextDrawBoxColor(Contract_GlobalTD[4], 50);
    TextDrawUseBox(Contract_GlobalTD[4], 0);
    TextDrawSetProportional(Contract_GlobalTD[4], 1);
    TextDrawSetSelectable(Contract_GlobalTD[4], 0);

    Contract_GlobalTD[5] = TextDrawCreate(210.000000, 213.000000, "ld_beat:left");
    TextDrawFont(Contract_GlobalTD[5], 4);
    TextDrawLetterSize(Contract_GlobalTD[5], 0.600000, 2.000000);
    TextDrawTextSize(Contract_GlobalTD[5], 11.500000, 12.000000);
    TextDrawSetOutline(Contract_GlobalTD[5], 1);
    TextDrawSetShadow(Contract_GlobalTD[5], 0);
    TextDrawAlignment(Contract_GlobalTD[5], 1);
    TextDrawColor(Contract_GlobalTD[5], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[5], 255);
    TextDrawBoxColor(Contract_GlobalTD[5], 50);
    TextDrawUseBox(Contract_GlobalTD[5], 1);
    TextDrawSetProportional(Contract_GlobalTD[5], 1);
    TextDrawSetSelectable(Contract_GlobalTD[5], 1);

    Contract_GlobalTD[6] = TextDrawCreate(228.000000, 213.000000, "LD_BEAT:right");
    TextDrawFont(Contract_GlobalTD[6], 4);
    TextDrawLetterSize(Contract_GlobalTD[6], 0.600000, 2.000000);
    TextDrawTextSize(Contract_GlobalTD[6], 11.500000, 12.000000);
    TextDrawSetOutline(Contract_GlobalTD[6], 1);
    TextDrawSetShadow(Contract_GlobalTD[6], 0);
    TextDrawAlignment(Contract_GlobalTD[6], 1);
    TextDrawColor(Contract_GlobalTD[6], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[6], 255);
    TextDrawBoxColor(Contract_GlobalTD[6], 50);
    TextDrawUseBox(Contract_GlobalTD[6], 1);
    TextDrawSetProportional(Contract_GlobalTD[6], 1);
    TextDrawSetSelectable(Contract_GlobalTD[6], 1);

    Contract_GlobalTD[7] = TextDrawCreate(207.000000, 286.000000, "Prodaje:");
    TextDrawFont(Contract_GlobalTD[7], 3);
    TextDrawLetterSize(Contract_GlobalTD[7], 0.220833, 0.850000);
    TextDrawTextSize(Contract_GlobalTD[7], 400.000000, 197.000000);
    TextDrawSetOutline(Contract_GlobalTD[7], 1);
    TextDrawSetShadow(Contract_GlobalTD[7], 0);
    TextDrawAlignment(Contract_GlobalTD[7], 1);
    TextDrawColor(Contract_GlobalTD[7], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[7], 255);
    TextDrawBoxColor(Contract_GlobalTD[7], 50);
    TextDrawUseBox(Contract_GlobalTD[7], 0);
    TextDrawSetProportional(Contract_GlobalTD[7], 1);
    TextDrawSetSelectable(Contract_GlobalTD[7], 0);

    Contract_GlobalTD[8] = TextDrawCreate(354.000000, 286.000000, "Kupuje:");
    TextDrawFont(Contract_GlobalTD[8], 3);
    TextDrawLetterSize(Contract_GlobalTD[8], 0.220833, 0.850000);
    TextDrawTextSize(Contract_GlobalTD[8], 400.000000, 197.000000);
    TextDrawSetOutline(Contract_GlobalTD[8], 1);
    TextDrawSetShadow(Contract_GlobalTD[8], 0);
    TextDrawAlignment(Contract_GlobalTD[8], 1);
    TextDrawColor(Contract_GlobalTD[8], -1);
    TextDrawBackgroundColor(Contract_GlobalTD[8], 255);
    TextDrawBoxColor(Contract_GlobalTD[8], 50);
    TextDrawUseBox(Contract_GlobalTD[8], 0);
    TextDrawSetProportional(Contract_GlobalTD[8], 1);
    TextDrawSetSelectable(Contract_GlobalTD[8], 0);

    Contract_GlobalTD[9] = TextDrawCreate(206.000000, 303.000000, "-------------------");
    TextDrawFont(Contract_GlobalTD[9], 3);
    TextDrawLetterSize(Contract_GlobalTD[9], 0.220833, 0.850000);
    TextDrawTextSize(Contract_GlobalTD[9], 400.000000, 197.000000);
    TextDrawSetOutline(Contract_GlobalTD[9], 1);
    TextDrawSetShadow(Contract_GlobalTD[9], 0);
    TextDrawAlignment(Contract_GlobalTD[9], 1);
    TextDrawColor(Contract_GlobalTD[9], 255);
    TextDrawBackgroundColor(Contract_GlobalTD[9], 255);
    TextDrawBoxColor(Contract_GlobalTD[9], 50);
    TextDrawUseBox(Contract_GlobalTD[9], 0);
    TextDrawSetProportional(Contract_GlobalTD[9], 1);
    TextDrawSetSelectable(Contract_GlobalTD[9], 0);

    Contract_GlobalTD[10] = TextDrawCreate(353.000000, 303.000000, "-------------------");
    TextDrawFont(Contract_GlobalTD[10], 3);
    TextDrawLetterSize(Contract_GlobalTD[10], 0.220833, 0.850000);
    TextDrawTextSize(Contract_GlobalTD[10], 400.000000, 197.000000);
    TextDrawSetOutline(Contract_GlobalTD[10], 1);
    TextDrawSetShadow(Contract_GlobalTD[10], 0);
    TextDrawAlignment(Contract_GlobalTD[10], 1);
    TextDrawColor(Contract_GlobalTD[10], 255);
    TextDrawBackgroundColor(Contract_GlobalTD[10], 255);
    TextDrawBoxColor(Contract_GlobalTD[10], 50);
    TextDrawUseBox(Contract_GlobalTD[10], 0);
    TextDrawSetProportional(Contract_GlobalTD[10], 1);
    TextDrawSetSelectable(Contract_GlobalTD[10], 0);

    Contract_GlobalTD[11] = TextDrawCreate(197.000000, 292.000000, "Preview_Model");
    TextDrawFont(Contract_GlobalTD[11], 5);
    TextDrawLetterSize(Contract_GlobalTD[11], 0.600000, 2.000000);
    TextDrawTextSize(Contract_GlobalTD[11], 84.000000, 25.000000);
    TextDrawSetOutline(Contract_GlobalTD[11], 0);
    TextDrawSetShadow(Contract_GlobalTD[11], 0);
    TextDrawAlignment(Contract_GlobalTD[11], 1);
    TextDrawColor(Contract_GlobalTD[11], 255);
    TextDrawBackgroundColor(Contract_GlobalTD[11], 0);
    TextDrawBoxColor(Contract_GlobalTD[11], 255);
    TextDrawUseBox(Contract_GlobalTD[11], 0);
    TextDrawSetProportional(Contract_GlobalTD[11], 1);
    TextDrawSetSelectable(Contract_GlobalTD[11], 0);
    TextDrawSetPreviewModel(Contract_GlobalTD[11], 1490);
    TextDrawSetPreviewRot(Contract_GlobalTD[11], 6.000000, 0.000000, -61.000000, 1.000000);
    TextDrawSetPreviewVehCol(Contract_GlobalTD[11], 1, 1);

    Contract_GlobalTD[12] = TextDrawCreate(343.000000, 316.000000, "Preview_Model");
    TextDrawFont(Contract_GlobalTD[12], 5);
    TextDrawLetterSize(Contract_GlobalTD[12], 0.600000, 2.000000);
    TextDrawTextSize(Contract_GlobalTD[12], 89.000000, -25.500000);
    TextDrawSetOutline(Contract_GlobalTD[12], 0);
    TextDrawSetShadow(Contract_GlobalTD[12], 0);
    TextDrawAlignment(Contract_GlobalTD[12], 1);
    TextDrawColor(Contract_GlobalTD[12], 255);
    TextDrawBackgroundColor(Contract_GlobalTD[12], 0);
    TextDrawBoxColor(Contract_GlobalTD[12], 255);
    TextDrawUseBox(Contract_GlobalTD[12], 0);
    TextDrawSetProportional(Contract_GlobalTD[12], 1);
    TextDrawSetSelectable(Contract_GlobalTD[12], 0);
    TextDrawSetPreviewModel(Contract_GlobalTD[12], 1531);
    TextDrawSetPreviewRot(Contract_GlobalTD[12], 6.000000, 0.000000, -61.000000, 1.000000);
    TextDrawSetPreviewVehCol(Contract_GlobalTD[12], 1, 1);
}