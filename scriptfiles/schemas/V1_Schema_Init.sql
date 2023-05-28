CREATE TABLE IF NOT EXISTS `migration_schema` 
    (
        `version` varchar(10) NOT NULL,
        `description` varchar(128) NOT NULL,
        `type` varchar(20) NOT NULL DEFAULT 'SQL',
        `execution_time` varchar(12) NOT NULL,
        `checksum` varchar(64) NOT NULL,
        `installed_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY (`version`)
    );