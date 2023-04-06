#include <ysilib\YSI_Coding\y_hooks>

#define     server_name                 "Monaco"
#define     server_version              "v0.1"

#define     c_server                    "{0099ff}"
#define     c_red                       "{FC3737}"
#define     c_blue                      "{68DAFF}"
#define     c_white                     "{ffffff}"
#define     c_yellow                    "{EFE4BD}"
#define     c_green                     "{009933}"
#define     c_pink                      "{ff00bb}"
#define     c_ltblue                    "{00f2ff}"
#define     c_orange                    "{ffa200}"
#define     c_greey                     "{787878}"
#define     c_torq                      "{86c3ac}"

#define     x_server                    0x0099FFAA
#define     x_red                       0xFF1100AA
#define     x_blue                      0x0099CCAA
#define     x_white                     0xffffffAA
#define     x_yellow                    0xf2ff00AA
#define     x_green                     0x009933AA
#define     x_pink                      0xff00bbAA
#define     x_ltblue                    0x00f2ffAA
#define     x_orange                    0xffa200AA
#define     x_greey                     0x787878AA
#define     x_purple                    0xC2A2DAAA
#define     x_torq                      0x86c3acFF

#define     Error(%0,%1) 	            SendClientMessageEx(%0, x_torq, "(greska) "%1)

hook OnGameModeInit()
{
    SetGameModeText(""server_name" "server_version"");
    
    return Y_HOOKS_CONTINUE_RETURN_1;
}