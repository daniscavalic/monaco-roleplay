CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model` int(11) NOT NULL DEFAULT '0',
  `positionX` float NOT NULL DEFAULT '0',
  `positionY` float NOT NULL DEFAULT '0',
  `positionZ` float DEFAULT '0',
  `positionA` float NOT NULL DEFAULT '0',
  `color1` int(11) NOT NULL DEFAULT '0',
  `color2` int(11) NOT NULL DEFAULT '0',
  `veh_usage` int(11) NOT NULL DEFAULT '0',
  `veh_owner_id` int(11) NOT NULL DEFAULT '0',
  `veh_owner` varchar(30) NOT NULL DEFAULT '"Drzava"',
  PRIMARY KEY (`id`)
);