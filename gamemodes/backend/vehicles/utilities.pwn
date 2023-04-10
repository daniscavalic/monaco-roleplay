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

new VehPrice[ 212 ][ 3 ] = {
    { 400, 1500000, 7500 }, // Landstalker
    { 401, 1200000, 6000 }, // Bravura
    { 402, 2800000, 14000 }, // Buffalo
    { 403, 0, 0 }, // Linerunner
    { 404, 1000000, 5000 }, // Perenniel
    { 405, 1000000, 5000 }, // Sentinel
    { 406, 0, 0 }, // Dumper edit
    { 407, 0, 0 }, // Firetruck edit
    { 408, 0, 0 }, // Trashmaster edit
    { 409, 10000000, 50000 }, // Stretch
    { 410, 1500000, 7500 }, // Manana
    { 411, 20000000, 100000 }, // Infernus
    { 412, 900000, 4500 }, // Voodoo
    { 413, 920000, 4600 }, // Pony
    { 414, 0, 0 }, // Mule
    { 415, 11000000, 55000 }, // Cheetah
    { 416, 0, 0 }, // Ambulance
    { 417, 10000000, 50000 }, // Leviathan
    { 418, 950000, 4750 }, // Moonbeam
    { 419, 800000, 4000 }, // Esperanto
    { 420, 0, 0 }, // Taxi
    { 421, 900000, 4500 }, // Washington
    { 422, 500000, 2500 }, // Bobcat
    { 423, 0, 0 }, // Mr Whoopee edit
    { 424, 1120000, 5600 }, // BF Injection edit
    { 425, 0, 0 }, // Hunter edit
    { 426, 1400000, 7000 }, // Premier
    { 427, 0, 0 }, // Enforcer edit
    { 428, 0, 0 }, // Securicar edit
    { 429, 10900000, 54500 }, // Banshee
    { 430, 0, 0 }, // Predator edit
    { 431, 0, 0 }, // Bus edit
    { 432, 0, 0 }, // Rhino edit
    { 433, 0, 0 }, // Barracks
    { 434, 0, 0 }, // Hotknife
    { 435, 0, 0 }, // Article Trailer edit
    { 436, 1120000, 5600 }, // Previon edit
    { 437, 0, 0 }, // Coach edit
    { 438, 0, 0 }, // Cabbie
    { 439, 2000000, 10000 }, // Stallion
    { 440, 0, 0 }, // Rumpo
    { 441, 0, 0 }, // RC Bandit edit
    { 442, 0, 0 }, // Romero
    { 443, 0, 0 }, // Packer
    { 444, 10000000, 0 }, // Monster edit
    { 445, 4700000, 23500 }, // Admiral
    { 446, 10000000, 50000 }, // Squallo edit
    { 447, 800000, 4000 }, // Seasparrow edit
    { 448, 0, 0 }, // Pizzaboy
    { 449, 0, 0 }, // Tram edit
    { 450, 0, 0 }, // Article Trailer 2 edit
    { 451, 16000000, 80000 }, // Turismo
    { 452, 4500000, 22500 }, // Speeder edit
    { 453, 2200000, 11000 }, // Reefer edit
    { 454, 8000000, 40000 }, // Tropic edit
    { 455, 0, 0 }, // Flatbed
    { 456, 0, 0 }, // Yankee
    { 457, 1800000, 7000 }, // Caddy edit
    { 458, 1900000, 7500 }, // Solair edit
    { 459, 0, 0 }, // Topfun Van (Berkley's RC)
    { 460, 11000000, 60000 }, // Skimmer edit
    { 461, 7000000, 35000 }, // PCJ-600
    { 462, 1100000, 5500 }, // Faggio
    { 463, 1000000, 5000 }, // Freeway
    { 464, 0, 0 }, // RC Baron edit
    { 465, 0, 0 }, // RC Raider edit
    { 466, 1200000, 6000 }, // Glendale
    { 467, 1200000, 6000 }, // Oceanic
    { 468, 2500000, 12500 }, // Sanchez
    { 469, 8000000, 40000 }, // Sparrow edit
    { 470, 12000000, 60000 }, // Patriot
    { 471, 1100000, 5500 }, // Quad
    { 472, 0, 0 }, // Coastguard edit
    { 473, 770000, 3850 }, // Dinghy edit
    { 474, 1000000, 5000 }, // Hermes
    { 475, 1300000, 6500 }, // Sabre
    { 476, 2000000, 10000 }, // Rustler edit
    { 477, 4800000, 24000 }, // ZR-350
    { 478, 0, 0 }, // Walton
    { 479, 1000000, 5000 }, // Regina
    { 480, 7000000, 35000 }, // Comet
    { 481, 1000000, 5000 }, // BMX edit
    { 482, 9000000, 45000 }, // Burrito
    { 483, 1200000, 6000 }, // Camper
    { 484, 1000000, 5000 }, // Marquis edit
    { 485, 0, 0 }, // Baggage edit
    { 486, 0, 0 }, // Dozer
    { 487, 45000000, 225000 }, // Maverick edit
    { 488, 0, 0 }, // SAN News Maverick edit
    { 489, 1700000, 8500 }, // Rancher
    { 490, 0, 0 }, // FBI Rancher edit
    { 491, 1100000, 5500 }, // Virgo
    { 492, 2100000, 10500 }, // Greenwood
    { 493, 8000000, 40000 }, // Jetmax edit
    { 494, 10000000, 50000 }, // Hotring Racer edit
    { 495, 19000000, 90000 }, // Sandking edit
    { 496, 2600000, 13000 }, // Blista Compact
    { 497, 0, 0 }, // Police Maverick edit
    { 498, 0, 0 }, // Boxville
    { 499, 0, 0 }, // Benson
    { 500, 900000, 4500 }, // Mesa
    { 501, 0, 0 }, // RC Goblin edit
    { 502, 1530000, 4650 }, // Hotring Racer edit
    { 503, 1530000, 4650 }, // Hotring Racer edit
    { 504, 0, 0 }, // Bloodring Banger edit
    { 505, 0, 0 }, // Rancher
    { 506, 16000000, 80000 }, // Super GT
    { 507, 1200000, 6000 }, // Elegant
    { 508, 0, 0 }, // Journey
    { 509, 900000, 4500 }, // Bike edit
    { 510, 900000, 4500 }, // Mountain Bike edit
    { 511, 0, 0 }, // Beagle edit
    { 512, 5000000, 25000 }, // Cropduster edit
    { 513, 5000000, 25000 }, // Stuntplane edit
    { 514, 0, 0 }, // Tanker
    { 515, 0, 0 }, // Roadtrain
    { 516, 1950000, 9750 }, // Nebula
    { 517, 1300000, 6500 }, // Majestic
    { 518, 1350000, 6700 }, // Buccaneer
    { 519, 60000000, 300000 }, // Shamal edit
    { 520, 0, 0 }, // Hydra edit
    { 521, 13000000, 65000 }, // FCR-900
    { 522, 17000000, 85000 }, // NRG-500
    { 523, 0, 0 }, // HPV1000 edit
    { 524, 0, 0 }, // Cement Truck
    { 525, 0, 0 }, // Towtruck
    { 526, 4500000, 22500 }, // Fortune
    { 527, 1500000, 7500 }, // Cadrona edit
    { 528, 0, 0 }, // FBI Truck edit
    { 529, 1780000, 8900 }, // Willard
    { 530, 0, 0 }, // Forklift edit 0
    { 531, 10000000, 50000 }, // Tractor
    { 532, 0, 0 }, // Combine Harvester
    { 533, 2350000, 11750 }, // Feltzer
    { 534, 3000000, 15000 }, // Remington
    { 535, 3000000, 15000 }, // Slamvan
    { 536, 2300000, 11500 }, // Blade
    { 537, 0, 0 }, // Freight edit
    { 538, 0, 0 }, // Brownstreak edit
    { 539, 0, 0 }, // Vortex edit
    { 540, 1100000, 5500 }, // Vincent edit
    { 541, 18000000, 90000 }, // Bullet
    { 542, 1000000, 5000 }, // Clover
    { 543, 1000000, 5000 }, // Sadler
    { 544, 0, 0 }, // Firetruck LA edit
    { 545, 4000000, 20000 }, // Hustler
    { 546, 1000000, 5000 }, // Intruder
    { 547, 1200000, 6000 }, // Primo
    { 548, 0, 0 }, // Cargobob edit
    { 549, 1000000, 5000 }, // Tampa
    { 550, 1400000, 7000 }, // Sunrise
    { 551, 1500000, 7500 }, // Merit
    { 552, 0, 0 }, // Utility Van edit
    { 553, 0, 0 }, // Nevada edit
    { 554, 3400000, 17000 }, // Yosemite
    { 555, 1400000, 7000 }, // Windsor
    { 556, 10000000, 0 }, // Monster "A" edit
    { 557, 10000000, 0 }, // Monster "B" edit
    { 558, 3000000, 15000 }, // Uranus
    { 559, 5000000, 25000 }, // Jester
    { 560, 19500000, 97500 }, // Sultan
    { 561, 2300000, 11500 }, // Stratum
    { 562, 16000000, 80000 }, // Elegy
    { 563, 0, 0 }, // Raindance edit
    { 564, 0, 0 }, // RC Tiger edit
    { 565, 7000000, 35000 }, // Flash
    { 566, 1500000, 7500 }, // Tahoma
    { 567, 4500000, 22500  }, // Savanna
    { 568, 1300000, 2000 }, // Bandito
    { 569, 0, 0 }, // Freight Flat Trailer edit
    { 570, 0, 0 }, // Streak Trailer edit
    { 571, 0, 0 }, // Kart
    { 572, 0, 0 }, // Mower
    { 573, 12000000, 60000 }, // Dune
    { 574, 0, 0 }, // Sweeper
    { 575, 1250000, 6250 }, // Broadway
    { 576, 1250000, 6250 }, // Tornado
    { 577, 0, 0 }, // AT400 edit
    { 578, 0, 0 }, // DFT-30
    { 579, 15900000, 79500 }, // Huntley
    { 580, 4700000, 23500 }, // Stafford
    { 581, 12000000, 60000 }, // BF-400
    { 582, 0, 0 }, // Newsvan edit
    { 583, 0, 0 }, // Tug edit
    { 584, 0, 0 }, // Petrol Trailer edit
    { 585, 1100000, 5500 }, // Emperor
    { 586, 1300000, 6500 }, // Wayfarer
    { 587, 6500000, 32500 }, // Euros
    { 588, 0, 0 }, // Hotdog edit
    { 589, 4700000, 23500 }, // Club
    { 590, 0, 0 }, // Freight Box Trailer edit
    { 591, 0, 0 }, // Article Trailer 3 edit
    { 592, 0, 0 }, // Andromada edit
    { 593, 25000000, 125000 }, // Dodo edit
    { 594, 0, 0 }, // RC Cam edit
    { 595, 0, 0 }, // Launch edit
    { 596, 0, 0 }, // Police Car (LSPD) edit
    { 597, 0, 0 }, // Police Car (SFPD) edit
    { 598, 0, 0 }, // Police Car (LVPD) edit
    { 599, 0, 0 }, // Police Ranger edit
    { 600, 1100000, 5500 }, // Picador
    { 601, 0, 0 }, // S.W.A.T. edit
    { 602, 5500000, 27500 }, // Alpha
    { 603, 8500000, 42500 }, // Phoenix
    { 604, 0, 0 }, // Glendale Shit edit
    { 605, 0, 0 }, // Sadler Shit edit
    { 606, 0, 0 }, // Baggage Trailer "A" edit
    { 607, 0, 0 }, // Baggage Trailer "B" edit
    { 608, 0, 0 }, // Tug Stairs Trailer edit
    { 609, 0, 0 }, // Boxville
    { 610, 0, 0 }, // Farm Trailer edit
    { 611, 0, 0 } // Utility Trailer edit xx
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