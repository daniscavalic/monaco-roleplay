/*
    ___       __          _          _    __     __    _      __         
   /   | ____/ /___ ___  (_)___     | |  / /__  / /_  (_)____/ /__  _____
  / /| |/ __  / __ `__ \/ / __ \    | | / / _ \/ __ \/ / ___/ / _ \/ ___/
 / ___ / /_/ / / / / / / / / / /    | |/ /  __/ / / / / /__/ /  __(__  ) 
/_/  |_\__,_/_/ /_/ /_/_/_/ /_/     |___/\___/_/ /_/_/\___/_/\___/____/  
                                                                         
    Developed by Danis Čavalić.
*/
#include    <ysilib\YSI_Coding\y_hooks>
#include 	"backend/vehicles/vehicles_data/utilities.pwn"

new 
	AdminVozilo[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
    AdminVozilo[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerDisconnect(playerid, reason) {
    if(AdminVozilo[playerid] != INVALID_VEHICLE_ID) {
        DestroyVehicle(AdminVozilo[playerid]);
        AdminVozilo[playerid] = INVALID_VEHICLE_ID;
    }
}

YCMD:avozilo(playerid, params[], help) 
{
    if (!Auth(playerid, 1)) return Error(playerid, NO_AUTH);
	if (help) Usage(playerid, "Kreira administratorsko vozilo");
	if(AdminVozilo[playerid] != INVALID_VEHICLE_ID) {
        DestroyVehicle(AdminVozilo[playerid]);
        AdminVozilo[playerid] = INVALID_VEHICLE_ID;
    }
    else {
        new modelid, boja;
        if (sscanf(params, "ii", modelid, boja)) Usage(playerid, "/avozilo [Model (ID)] [Boja]");
        else {
            if (400 > modelid > 611) return Error(playerid, "Validni modeli su od 400 do 611.");

            new Float:x, Float:y, Float:z;
	        GetPlayerPos(playerid, x, y, z);
            new vehicleid = AdminVozilo[playerid] = CreateVehicle(modelid, x, y, z, 0.0, boja, boja, -1);

            SetVehicleNumberPlate(vehicleid, "STAFF");
            PutPlayerInVehicle(playerid, vehicleid, 0);
            
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

            if (IsVehicleBicycle(GetVehicleModel(vehicleid))) SetVehicleParamsEx(vehicleid, 1, 0, 0, doors, bonnet, boot, objective);
            else SetVehicleParamsEx(vehicleid, 0, 0, 0, doors, bonnet, boot, objective);
            Server(playerid, "Uspjesno ste stvorili vozilo jednokratne upotrebe, model: %d, boja %d.", modelid, boja);
        }
    }
    return 1;
}
