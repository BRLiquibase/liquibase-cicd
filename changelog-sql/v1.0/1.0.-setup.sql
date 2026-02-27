--liquibase formatted sql

--changeset changelog-sql:v1.0.0-setup
CREATE TABLE IF NOT EXISTS `changelog` (        
    `id` VARCHAR(255) NOT NULL,        
    `author` VARCHAR(255) NOT NULL,        
    `filename` VARCHAR(255) NOT NULL,        
    `dateexecuted` DATETIME NOT NULL,        
    `orderexecuted` INT NOT NULL,        
    `exectype` VARCHAR(10) NOT NULL,        
    PRIMARY KEY (`id`, `author`, `filename`)    
);

--rollback DROP TABLE `changelog`;