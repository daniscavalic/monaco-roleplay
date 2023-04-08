/*
 _    __     __    _      __             __  __                ____         
| |  / /__  / /_  (_)____/ /__  _____   / / / /___ _____  ____/ / /__  _____
| | / / _ \/ __ \/ / ___/ / _ \/ ___/  / /_/ / __ `/ __ \/ __  / / _ \/ ___/
| |/ /  __/ / / / / /__/ /  __(__  )  / __  / /_/ / / / / /_/ / /  __/ /    
|___/\___/_/ /_/_/\___/_/\___/____/  /_/ /_/\__,_/_/ /_/\__,_/_/\___/_/     
                                                                            
    Developed by Danis Čavalić.
*/

#include    <ysilib\YSI_Coding\y_hooks>
//          Utilities - Vehicle Functions
#include 	"backend/vehicles/utilities.pwn"
//          Admin Vehicles
#include 	"backend/vehicles/admin_vehicles.pwn"

enum {
	E_VEHICLE_TYPE_PRIVATE,
	E_VEHICLE_TYPE_ADMIN,
	E_VEHICLE_TYPE_JOB,
	E_VEHICLE_TYPE_FACTION,
	E_VEHICLE_TYPE_UNDEFINED
}

enum E_VEHICLE_DATA {
	ORM: v_ORM_ID,

	v_ID,
	v_Model,
	Float:v_Position[4],
	v_Color[2],
	v_Usage,
	v_OwnerID,
	v_Owner[30],

	v_VehicleID
}

new 
	VehicleData[MAX_VEHICLES][E_VEHICLE_DATA],
	Iterator: ServerVehicles<MAX_VEHICLES>;

stock RemoveVehicle(vehicleid) {
	if (Iter_Contains(ServerVehicles, vehicleid)) 
    {
        Iter_Remove(ServerVehicles, vehicleid);
    
        DestroyVehicle(VehicleData[vehicleid][v_VehicleID]);
        orm_delete(VehicleData[vehicleid][v_ORM_ID]);

        static const empty_vehicle[E_VEHICLE_DATA];
        VehicleData[vehicleid] = empty_vehicle;
    }
}

stock CreateNewVehicle(model, color, usage, Float:posX, Float:posY, Float:posZ, Float:posA, owner_id, owner_name[]) 
{
	new vehicleid = Iter_Free(ServerVehicles);
	if (vehicleid != -1) 
	{
		new ORM:ormid = VehicleData[vehicleid][v_ORM_ID] = orm_create("vehicles", Database);

		orm_addvar_int(ormid, VehicleData[vehicleid][v_ID], "id");
		orm_setkey(ormid, "id");
		orm_addvar_int(ormid, VehicleData[vehicleid][v_Model], "model");
		orm_addvar_float(ormid, VehicleData[vehicleid][v_Position][0], "positionX");
		orm_addvar_float(ormid, VehicleData[vehicleid][v_Position][1], "positionY");
		orm_addvar_float(ormid, VehicleData[vehicleid][v_Position][2], "positionZ");
		orm_addvar_float(ormid, VehicleData[vehicleid][v_Position][3], "positionA");
		orm_addvar_int(ormid, VehicleData[vehicleid][v_Color][0], "color1");
		orm_addvar_int(ormid, VehicleData[vehicleid][v_Color][1], "color2");
		orm_addvar_int(ormid, VehicleData[vehicleid][v_Usage], "veh_usage");
		orm_addvar_int(ormid, VehicleData[vehicleid][v_OwnerID], "veh_owner_id");
		orm_addvar_string(ormid, VehicleData[vehicleid][v_Owner], 30, "veh_owner");

		VehicleData[vehicleid][v_Model] = model;
		VehicleData[vehicleid][v_Color][0] = color;
		VehicleData[vehicleid][v_Color][1] = color;
		VehicleData[vehicleid][v_Usage] = usage;
		VehicleData[vehicleid][v_Position][0] = posX;
		VehicleData[vehicleid][v_Position][1] = posY;
		VehicleData[vehicleid][v_Position][2] = posZ;
		VehicleData[vehicleid][v_Position][3] = posA;
		VehicleData[vehicleid][v_OwnerID] = owner_id;
		format(VehicleData[vehicleid][v_Owner], _, "%s", owner_name);

        //
        VehicleData[vehicleid][v_VehicleID] = CreateVehicle(
							VehicleData[vehicleid][v_Model], 
							VehicleData[vehicleid][v_Position][0], VehicleData[vehicleid][v_Position][1], VehicleData[vehicleid][v_Position][2], 
							VehicleData[vehicleid][v_Position][3], 
							VehicleData[vehicleid][v_Color][0], VehicleData[vehicleid][v_Color][1], 
							-1
					);

		//
		orm_insert(VehicleData[vehicleid][v_ORM_ID]);
		Iter_Add(ServerVehicles, vehicleid);
	}
}

forward OnVehiclesLoad();
public OnVehiclesLoad()
{
    for(new r=0; r < cache_num_rows(); ++r) 
	{
		new vehicleid = Iter_Free(ServerVehicles);
		if(vehicleid != -1) 
		{
			static const empty_vehicle[E_VEHICLE_DATA];
			VehicleData[vehicleid] = empty_vehicle;

			new ORM: ormid = VehicleData[vehicleid][v_ORM_ID] = orm_create("vehicles", Database);

			orm_addvar_int(ormid, VehicleData[vehicleid][v_ID], "id");
			orm_setkey(ormid, "id");

			orm_addvar_int(ormid, VehicleData[vehicleid][v_Model], "model");
			orm_addvar_float(ormid, VehicleData[vehicleid][v_Position][0], "positionX");
			orm_addvar_float(ormid, VehicleData[vehicleid][v_Position][1], "positionY");
			orm_addvar_float(ormid, VehicleData[vehicleid][v_Position][2], "positionZ");
			orm_addvar_float(ormid, VehicleData[vehicleid][v_Position][3], "positionA");
			orm_addvar_int(ormid, VehicleData[vehicleid][v_Color][0], "color1");
			orm_addvar_int(ormid, VehicleData[vehicleid][v_Color][1], "color2");
			orm_addvar_int(ormid, VehicleData[vehicleid][v_Usage], "veh_usage");
			orm_addvar_int(ormid, VehicleData[vehicleid][v_OwnerID], "veh_owner_id");
			orm_addvar_string(ormid, VehicleData[vehicleid][v_Owner], 30, "veh_owner");

			orm_apply_cache(ormid, r);

			Iter_Add(ServerVehicles, vehicleid);

			VehicleData[vehicleid][v_VehicleID] = CreateVehicle(
							VehicleData[vehicleid][v_Model], 
							VehicleData[vehicleid][v_Position][0], VehicleData[vehicleid][v_Position][1], VehicleData[vehicleid][v_Position][2], 
							VehicleData[vehicleid][v_Position][3], 
							VehicleData[vehicleid][v_Color][0], VehicleData[vehicleid][v_Color][1], 
							-1
					);
		}
	}

    return 1;
}

hook OnGameModeInit() {
	mysql_tquery(Database, "SELECT * FROM `vehicles`", "OnVehiclesLoad", "");
}

hook OnVehicleSpawn(vehicleid)
{
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

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
    foreach(new veh_id : ServerVehicles) 
    {
        if(VehicleData[veh_id][v_VehicleID] == vehicleid) 
        {
            // undefined (global) type
            if(VehicleData[veh_id][v_Usage] == E_VEHICLE_TYPE_UNDEFINED) {
                Torq(playerid, "(vozilo) Ulazis u %s vlasnika %s.", GetVehicleNameEx(VehicleData[veh_id][v_Model]), VehicleData[veh_id][v_Owner]);
            }
            break;
        }
    }
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER) 
    {
        if(!IsVehicleBicycle(GetVehicleModel(GetPlayerVehicleID(playerid)))) {
            Blue(playerid, "(vozilo) Usli ste u vozilo %s. Koristite tipku 'N' ili komandu '/engine' za kontrolu motora vozila.", GetVehicleNameEx(GetVehicleModel(GetPlayerVehicleID(playerid))));
            Blue(playerid, "(vozilo) Koristeci tipku 'Y' ili komandu '/lights' mozete kontrolisati svijetla na vozilu.");
        }
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        if(newkeys & KEY_NO)
        {   
            if(!IsVehicleBicycle(GetVehicleModel(GetPlayerVehicleID(playerid)))) {
                
                new veh = GetPlayerVehicleID(playerid),
                    engine,
                    lights,
                    alarm,
                    doors,
                    bonnet,
                    boot,
                    objective;

                GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

                if(engine == VEHICLE_PARAMS_OFF)
                {
                    SetVehicleParamsEx(veh, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
                }
                else
                {
                    SetVehicleParamsEx(veh, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
                }

                Torq(playerid, "(motor) %s ste motor vozila.", (engine == VEHICLE_PARAMS_OFF) ? "Upalili" : "Ugasili");

                return true;
            }
        }
        if(newkeys & KEY_YES)
        {  
            if(!IsVehicleBicycle(GetVehicleModel(GetPlayerVehicleID(playerid))))
            {
                new veh = GetPlayerVehicleID(playerid),
                    engine,
                    lights,
                    alarm,
                    doors,
                    bonnet,
                    boot,
                    objective;

                GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

                if(lights == VEHICLE_PARAMS_OFF)
                {
                    SetVehicleParamsEx(veh, engine, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
                }
                else
                {
                    SetVehicleParamsEx(veh, engine, VEHICLE_PARAMS_OFF, alarm, doors, bonnet, boot, objective);
                }

                Torq(playerid, "(svijetla) %s ste svijetla na vozilu.", (lights == VEHICLE_PARAMS_OFF) ? "Upalili" : "Ugasili");
                
                return true;
            }
        }
    }
	return 1;
}