/*----------------------------------------------------------------------------*-
					==============================
					Flyway-like Database migration
					==============================
Description:
	Provides an implementation of the Flyway like SQL database migration,
	by providing your .sql migration files into schemas folder.
Legal:
	This code has no direct connection with code written by flyway's team,
	it has its own logic suitable for SA-MP scripting infrastructure, allowing
	scripters to create their own migrations by using SQL plugin developed for 
	SA-MP framework.
    Library requires BlueG's MySQL Plugin and G-sTyLeZzZ's File Manager Plugin.
	
	Created for PAWN by Danis Cavalic.
Version:
	0.1
Credits:
    G-sTyLeZzZ - File Manager Plugin
    Y_Less - File Manager Plugin (bug finding)
    BlueG - MySQL Plugin
Functions:
	Stock:
		MigrateSchemas(MySQL:serverDatabase) - Migrate schema by using parsed database. Should be parsed immediately after connection.
        CalculateFileContentChecksum(input_string[]) - Calculates checksum for given string. Used to calculate checksum of file.
Definitions:
    - SCHEMAS_TABLE -> Name of the table that will contain data about successful migrations.
    - SCHEMAS_FOLDER -> Name of the folder in scriptfiles that contains migrations.
    - SCHEMAS_PATH -> In order to execute by file, not string of query, schemas are in script files. This contains full path including scriptfiles.
    - LOG_PREFIX -> Prefix in server_log for logged actions.
    - CREATE_SCHEMA_NAME -> Name of the initial schema, first one to create migrations table, and insert itself as first migration.
    - CREATE_SCHEMA_SQL -> Basically a query for above schema.
Variables
    - bool:migrationInit -> Will be true if server is started first time with the migration library, which will skip migration verifications.
How to install and use:
    - Install required plugins and database_migration include.
    - Put MigrateSchemas(MySQL:Database) function right after connection is established.
    - Start server once after installing library in order to init migration schema.
    - Create .sql files with format: "V{version}_{migrationName}.sql" (example: V2_Create_Users_Table.sql)
    - Insert migration query into the migration file.
    - Start the server.
NOTES:
    - {version}: Version in migration file name must be unique! New migrations should always have new, incremented number.
    - {checksum}: Migration files cannot be changed after executed: If you change file after executed, migrations won't work.
-*----------------------------------------------------------------------------*/
#if defined _databasemigration_included
	#endinput
#endif
#define 	_databasemigration_included

#include    < filemanager >
#include    < a_mysql >

#define     SCHEMAS_TABLE               "migration_schema"
#define     SCHEMAS_FOLDER              "schemas"
#define     SCHEMAS_PATH                "scriptfiles/"SCHEMAS_FOLDER""
#define     LOG_PREFIX                  "DbMigrate"
#define     CREATE_SCHEMA_NAME          ""SCHEMAS_PATH"/V1_Schema_Init.sql"
#define     CREATE_SCHEMA_SQL \
            "CREATE TABLE IF NOT EXISTS `"SCHEMAS_TABLE"` (\
            `version` varchar(10) NOT NULL,\
            `description` varchar(128) NOT NULL,\
            `type` varchar(20) NOT NULL DEFAULT 'SQL',\
            `execution_time` varchar(12) NOT NULL,\
            `checksum` varchar(64) NOT NULL,\
            `installed_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,\
            PRIMARY KEY (`version`)\
            );"
static bool:migrationInit, migrationsExecuted = 0;

// Calculates checksum of migration .sql file by parsing its content.
// After migration is executed for a file, it should not be changed anymore,
// purpose of migration is to be used repeadetly in case of database changes.
// Changing previously migrated file will cause error and migration process will be stopped.
stock CalculateFileContentChecksum(const input_string[])
{
    new checksum = 0;

    for (new i = 0, len = strlen(input_string); i < len; i++)
    {
        checksum += (input_string[i] & 0xFF);
    }

    return checksum;
}

stock GetMigrationFileChecksum(const fileName[])
{
    new fullFilePath[128], fileContents[2048];
    format(fullFilePath, sizeof(fullFilePath), "%s/%s", SCHEMAS_PATH, fileName);
    new File:handle = f_open(fullFilePath, "r");
    f_read(handle, fileContents, sizeof(fileContents));
    f_close(handle);

    return CalculateFileContentChecksum(fileContents);
}

// Validate file is valid migration file. 
// If file contains SQL language, or has .sql extension, it is valid migration file.
stock bool:isMigrationFile(const fileName[])
{
    if (strfind(fileName, ".sql") != -1)
    {
        return true;
    }

    return false;
}

// Get migration description.
// For example, in: V1_DatabaseInit.sql, version is after ''_'' until the extension .sql,
// extracted, we get: ''DatabaseInit'' as a migration description.
stock getMigrationDescription(const fileName[]) {
    new migrationDescription[64];
    strmid(migrationDescription, fileName, strfind(fileName, "_")+1, strlen(fileName));
    strdel(migrationDescription, strfind(migrationDescription, "."), strlen(migrationDescription));
    for(new x = 0; x < sizeof(migrationDescription); x++)
    {
        if(migrationDescription[x] == '_') migrationDescription[x] = ' ';
    }
    return migrationDescription;
}

/*  Get migration version number.
    For example, in: V1_DatabaseInit.sql, version is in V1, extracted, we get number 1
*/
stock getMigrationVersion(const fileName[]) {
    new migrationVersion[6];
    strmid(migrationVersion, fileName, 1, strfind(fileName, "_"));
    strdel(migrationVersion, 0, 0);
    return migrationVersion;
}

/*  Validates is file already migrated by checking schema.
    Returns:
    - {-1} In case migration is not applied to database.
    - {checksum} - Checksum from the database in case migration is applied, to validate migration has not changed.
 */
stock CheckMigration(MySQL:serverDatabase, const fileName[]) {

    new dbQueryBuffer[256], migrationRowCount, migrationCheckSum[64], migrationIntCheckSum = -1;

    if (!migrationInit) {

        mysql_format(serverDatabase, dbQueryBuffer, sizeof(dbQueryBuffer), 
                    "SELECT checksum FROM `"SCHEMAS_TABLE"` WHERE version = '%s' LIMIT 1", 
                    getMigrationVersion(fileName));
        new Cache:queryExecutionResult = mysql_query(serverDatabase, dbQueryBuffer);
        if(queryExecutionResult == MYSQL_INVALID_CACHE) return migrationIntCheckSum;
        cache_get_row_count(migrationRowCount);

        if (migrationRowCount > 0) {
            cache_get_value(0, "checksum", migrationCheckSum, 64);
            migrationIntCheckSum = strval(migrationCheckSum);
        }

        cache_delete(queryExecutionResult);
    }

    return migrationIntCheckSum;
}

// Executes migration from the .sql file, and loads it into database.
stock bool:MigrateSQLFile(MySQL:serverDatabase, const fileName[]) {

    new fullFilePath[128];
    format(fullFilePath, sizeof(fullFilePath), "%s/%s", SCHEMAS_FOLDER, fileName);
    new checkMigrationChecksum = CheckMigration(serverDatabase, fileName),
        fileCheckSum = GetMigrationFileChecksum(fileName);

    if (checkMigrationChecksum == -1) {
        new Cache:queryExecutionResult = mysql_query_file(serverDatabase, fullFilePath, true);
        new migrationExecutionTime = cache_get_query_exec_time();
        cache_delete(queryExecutionResult);

        if (migrationExecutionTime != -1) 
        {
            InsertNewMigration(serverDatabase, getMigrationVersion(fileName), getMigrationDescription(fileName), fileCheckSum, migrationExecutionTime);
            printf("["LOG_PREFIX"] Migrated schema to version 'V%s - %s'", getMigrationVersion(fileName), getMigrationDescription(fileName));
            return true;
        }
        printf("["LOG_PREFIX"] Failed to migrate schema to version 'V%s - %s'", getMigrationVersion(fileName), getMigrationDescription(fileName));

        return false;
    }
    else {
        if (checkMigrationChecksum == fileCheckSum) return true;
        else {
            printf("["LOG_PREFIX"] Invalid checksum for migrated version 'V%s - %s', migration stopped.", getMigrationVersion(fileName), getMigrationDescription(fileName));
            return false;
        }
    }
}

// Inserts migration into schema table after successful migration.
stock InsertNewMigration(MySQL:serverDatabase, migrationVersion[], migrationDesc[], migrationCheckSum, migrationExecutionTime) {
    new dbQueryBuffer[256];
    mysql_format(serverDatabase, dbQueryBuffer, sizeof(dbQueryBuffer), 
                "INSERT INTO `"SCHEMAS_TABLE"` (`version`, `description`, `checksum`, `type`, `execution_time`) VALUES ('%s', '%s', '%d', 'SCHEMA', '%d')", 
                migrationVersion, migrationDesc, migrationCheckSum, migrationExecutionTime);
    new Cache:queryExecutionResult = mysql_query(serverDatabase, dbQueryBuffer);
    new insertExecutionTime = cache_get_query_exec_time();
    cache_delete(queryExecutionResult);
    return insertExecutionTime;
}

stock ValidateMigrationTable(MySQL:serverDatabase)
{
    new Cache:queryExecutionResult = mysql_query(serverDatabase, "SHOW TABLES LIKE '"SCHEMAS_TABLE"'"),
        migrationRowCount;
    cache_get_row_count(migrationRowCount);
    cache_delete(queryExecutionResult);
    if (migrationRowCount == 0) migrationInit = true;
}

stock DbMigrationInit() {
    dir_create(SCHEMAS_PATH);
    print("["LOG_PREFIX"] Schemas folder does not exist - created!");
    file_create(CREATE_SCHEMA_NAME);
    file_write(CREATE_SCHEMA_NAME, CREATE_SCHEMA_SQL);
    print("["LOG_PREFIX"] Created initial database migration schema.");
}

stock MigrateSchemas(MySQL:serverDatabase) {

    if (!dir_exists(SCHEMAS_PATH)) {
        DbMigrationInit();
        migrationInit = true;
    }
    else migrationInit = false;

    ValidateMigrationTable(serverDatabase);

    new dir:dHandle = dir_open(SCHEMAS_PATH);
    new item[40], type;

    while (dir_list(dHandle, item, type))
    {
        if (type == FM_FILE && isMigrationFile(item)) {
            if (MigrateSQLFile(serverDatabase, item)) migrationsExecuted++;
            else break;
        }
    }
    if (migrationsExecuted > 0) printf("["LOG_PREFIX"] Successfully applied %d migrations to schema.", migrationsExecuted);

    dir_close(dHandle);
}