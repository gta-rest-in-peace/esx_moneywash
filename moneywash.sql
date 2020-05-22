USE `es_extended`;

CREATE TABLE `auto_moneywash` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(100) NOT NULL,
	`amount` INT(11) NOT NULL,
	`deposit_date` DATETIME NOT NULL DEFAULT now(),
    `get_date` DATETIME NOT NULL,
    `notified` tinyint(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`));
