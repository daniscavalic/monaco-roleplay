/*
	; Created by Emmet on Friday, January 24, 2014.
	; Updated by Southclaws 2017-10-13 to add include guard.
	; Updated by TonY 2020-02-10 to speed up the code execution
	; Updated by Emmett (deksy) 2021-04-29 - code cleanup
	; Updated by Emmett (deksy) 2022-02-08 - code cleanup; used y_va instead of normal string formatting
	; Updated by Emmett (deksy) 2022-02-12 - now using y_hooks instead of als and new macro added
*/

#if defined _INC_easy_dialog_inc
	#endinput
#endif
#define _INC_easy_dialog_inc

#include <ysilib\YSI_Coding\y_hooks>
#include <ysilib\YSI_Coding\y_va>

// Macros
#define dialog_%0\32; dialog_
#define Dialog:%0(%1) dialog_%0(%1); public dialog_%0(%1)
#define Dialog_Show(%0,%1, Dialog_Open(%0, #%1,

// Variables
static dialog_Name[MAX_PLAYERS][32 char];

// API
forward OnDialogPerformed(playerid, const dialog[], response, success);

// Functions
stock Dialog_Close(const playerid)
{
	dialog_Name[playerid]{0} = 0;
	return ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", "");
}

stock Dialog_Open(const playerid, const function[], style, const caption[], const info[], const button1[], const button2[] = "", va_args<>)
{
	static fmt_string[4096]; // UwU

	if (info[0] == EOS)
		return 0;

	if (numargs() < 7)
		return ShowPlayerDialog(playerid, 32700, style, caption, info, button1, button2);
	
	va_format(fmt_string, sizeof(fmt_string), info, va_start<7>);

	ShowPlayerDialog(playerid, 32700, style, caption, fmt_string, button1, button2);
	strpack(dialog_Name[playerid], function, 32 char);

	return 1;
}

// Hooks
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	static s_Public;
	s_Public = funcidx("OnDialogPerformed");

	if (dialogid == 32700)
	{
		new string[40]; // 7 + 32 + \0

		strcat(string, "dialog_");
		strcat(string, dialog_Name[playerid]);

		Dialog_Close(playerid);

		if ((s_Public == -1) || (CallLocalFunction("OnDialogPerformed", "dsdd", playerid, string[7], response, funcidx(string)) != -1))
	 		CallLocalFunction(string, "ddds", playerid, response, listitem, (!inputtext[0]) ? ("\1") : (inputtext));
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}
