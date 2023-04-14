#include <ysilib\YSI_Coding\y_hooks>
#include <a_mysql>

#define SQL_CONNECTION_TYPE (1) // (Default: 0)

#if SQL_CONNECTION_TYPE == (0)	// Local host
	#define 				MYSQL_HOST        						 "localhost"
	#define 				MYSQL_USER        							  "root"
	#define 				MYSQL_PASS        						  		  ""
	#define 				MYSQL_DATABASE    						 	"monaco"
#endif

#if SQL_CONNECTION_TYPE == (1)	// Remote panel
	#define 				MYSQL_HOST        						 "localhost"
	#define 				MYSQL_USER        							  "root"
	#define 				MYSQL_PASS        						  		  ""
	#define 				MYSQL_DATABASE    						 	"monaco"
#endif

new MySQL: Database;

hook OnGameModeInit()
{
    new MySQLOpt: option_id = mysql_init_options();
    mysql_set_option(option_id, AUTO_RECONNECT, true);
    Database = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DATABASE, option_id);
    if(Database == MYSQL_INVALID_HANDLE || mysql_errno(Database) != 0) {
        SendRconCommand("exit");
        return 1;
    }
    
    return Y_HOOKS_CONTINUE_RETURN_1;
}