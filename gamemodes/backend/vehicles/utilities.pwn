/*
 _    __     __    _      __             __  ____  _ ___ __  _          
| |  / /__  / /_  (_)____/ /__  _____   / / / / /_(_) (_) /_(_)__  _____
| | / / _ \/ __ \/ / ___/ / _ \/ ___/  / / / / __/ / / / __/ / _ \/ ___/
| |/ /  __/ / / / / /__/ /  __(__  )  / /_/ / /_/ / / / /_/ /  __(__  ) 
|___/\___/_/ /_/_/\___/_/\___/____/   \____/\__/_/_/_/\__/_/\___/____/  
                                                                        
	Developed by Danis Čavalić.

*/

#include    <ysilib\YSI_Coding\y_hooks>

#define     GetVehicleNameEx(%0)      						   VehicleNames[(%0) - 400]

new VehicleNames[212][20] = {
    	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
        "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
        "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    	"Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
        "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
        "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
        "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
        "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
        "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
        "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
        "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
        "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
        "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
        "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
        "Blista Compact", "Police Maverick", "Boxvillde", "Benson", "Mesa", "RC Goblin",
        "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
        "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
        "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
        "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
        "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
        "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
		"Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
        "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
        "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum",
        "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    	"Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
        "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
        "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
        "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
        "Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
        "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
        "Tiller", "Utility Trailer"
};

stock IsVehicleBicycle(m)
{
    if (m == 481 || m == 509 || m == 510) return true;
    
    return false;
}

stock GetVehicleSpeed(vehicleid)
{
	new Float:xPos[3];

	GetVehicleVelocity(vehicleid, xPos[0], xPos[1], xPos[2]);

	return floatround(floatsqroot(xPos[0] * xPos[0] + xPos[1] * xPos[1] + xPos[2] * xPos[2]) * 170.00);
}