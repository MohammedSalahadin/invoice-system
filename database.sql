-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema invoice_database
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema invoice_database
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS invoice_database;
CREATE SCHEMA IF NOT EXISTS `invoice_database` DEFAULT CHARACTER SET utf8mb4 ;
USE `invoice_database` ;

-- -----------------------------------------------------
-- Table `invoice_database`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `invoice_database`.`users` (
  `idusers` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `phonenumber` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idusers`))
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb4;


-- -----------------------------------------------------
-- Table `invoice_database`.`invoice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `invoice_database`.`invoice` (
  `invoiceID` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  `price` DOUBLE NULL DEFAULT NULL,
  PRIMARY KEY (`invoiceID`),
  INDEX `fk_invoice_users_idx` (`user_id` ASC),
  CONSTRAINT `fk_invoice_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `invoice_database`.`users` (`idusers`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 30
DEFAULT CHARACTER SET = utf8mb4;


-- -----------------------------------------------------
-- Table `invoice_database`.`items`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `invoice_database`.`items` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `item_name` VARCHAR(100) NOT NULL,
  `Item_price` DOUBLE NOT NULL,
  `item_quantity` INT(11) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `item_name` (`item_name` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 16
DEFAULT CHARACTER SET = utf8mb4;


-- -----------------------------------------------------
-- Table `invoice_database`.`invoice_items`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `invoice_database`.`invoice_items` (
  `invoice_invoiceID` INT(11) NOT NULL,
  `items_ID` INT(11) NOT NULL,
  `quantity` SMALLINT(6) NOT NULL,
  PRIMARY KEY (`invoice_invoiceID`, `items_ID`),
  INDEX `fk_invoice_items_invoice1_idx` (`invoice_invoiceID` ASC),
  INDEX `fk_invoice_items_items1_idx` (`items_ID` ASC),
  CONSTRAINT `fk_invoice_items_invoice1`
    FOREIGN KEY (`invoice_invoiceID`)
    REFERENCES `invoice_database`.`invoice` (`invoiceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_invoice_items_items1`
    FOREIGN KEY (`items_ID`)
    REFERENCES `invoice_database`.`items` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

USE `invoice_database` ;

-- -----------------------------------------------------
-- Placeholder table for view `invoice_database`.`sell_report`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `invoice_database`.`sell_report` (`goods_ID` INT, `Name` INT, `No_of_k` INT);

-- -----------------------------------------------------
-- Placeholder table for view `invoice_database`.`sell_report_invoices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `invoice_database`.`sell_report_invoices` (`invoiceID` INT, `price` INT, `date` INT);

-- -----------------------------------------------------
-- Placeholder table for view `invoice_database`.`total_invoices_price_for_today`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `invoice_database`.`total_invoices_price_for_today` (`totInvoicePrice` INT);

-- -----------------------------------------------------
-- function CUSTOMER_ID
-- -----------------------------------------------------


DELIMITER $$
USE `invoice_database`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `CUSTOMER_ID`(CUSTOMER_NAME varchar(100)) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
RETURN (SELECT idusers FROM users WHERE `username`= CUSTOMER_NAME)$$

DELIMITER ;

-- -----------------------------------------------------
-- function ITEM_ID
-- -----------------------------------------------------

DELIMITER $$
USE `invoice_database`$$
CREATE  DEFINER=`root`@`localhost` FUNCTION `ITEM_ID`(ITEM_NAME varchar(100)) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
RETURN (SELECT `ID` FROM items WHERE `item_name`= ITEM_NAME)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure SELL_REPORT_SPECIFIC_DATE
-- -----------------------------------------------------

DELIMITER $$
USE `invoice_database`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SELL_REPORT_SPECIFIC_DATE`(IN `DateFrom` DATE, IN `DateTo` DATE)
IF datediff(`DateFrom`,`DateTo`)<=0 THEN
BEGIN
    SELECT 
        `cgq`.`items_ID` AS `goods_ID`,
        (SELECT 
                `g`.`item_name`
            FROM
                `items` `g`
            WHERE
                `g`.`ID` = `cgq`.`items_ID`) AS `Name`,
        SUM(`cgq`.`quantity`) AS `No_of_k`
    FROM
        `invoice_items` `cgq`
    WHERE 
            CAST((SELECT DISTINCT
                    `i`.`date`
                FROM
                    `invoice` `i`
                WHERE
                    `i`.`invoiceID` = `cgq`.`invoice_invoiceID`)
            AS DATE) BETWEEN DateFrom and DateTo 
		GROUP BY `cgq`.`items_ID` , (SELECT 
            `g`.`item_name`
        FROM
            `items` `g`
        WHERE
            `g`.`ID` = `cgq`.`items_ID`) order by `cgq`.`quantity` desc;
END;
else select 'Input the old date then the date after' as 'Wrong Input';
end if$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure TOTAL_INVOICES_PRICES_FOR_SPECIFIC_DATE
-- -----------------------------------------------------

DELIMITER $$
USE `invoice_database`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TOTAL_INVOICES_PRICES_FOR_SPECIFIC_DATE`(IN `DATE_FROM` DATE,IN `DATE_TO` DATE)
IF datediff(`DATE_FROM`,`DATE_TO`)<=0 THEN
BEGIN  
    SELECT 
        SUM(`i`.`price`) AS `totInvoicePrice`
    FROM
        `invoice` `i`
    WHERE
        CAST(`i`.`date` AS DATE) BETWEEN `DATE_FROM` AND `DATE_TO`;
END;
else select 'Input the old date then the date after' as 'Wrong Input';
end if$$

DELIMITER ;

-- -----------------------------------------------------
-- View `invoice_database`.`sell_report`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `invoice_database`.`sell_report`;
USE `invoice_database`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `invoice_database`.`sell_report` AS select `cgq`.`items_ID` AS `goods_ID`,(select `g`.`item_name` from `invoice_database`.`items` `g` where `g`.`ID` = `cgq`.`items_ID`) AS `Name`,sum(`cgq`.`quantity`) AS `No_of_k` from `invoice_database`.`invoice_items` `cgq` where cast((select distinct `i`.`date` from `invoice_database`.`invoice` `i` where `i`.`invoiceID` = `cgq`.`invoice_invoiceID`) as date) = curdate() group by `cgq`.`items_ID`,(select `g`.`item_name` from `invoice_database`.`items` `g` where `g`.`ID` = `cgq`.`invoice_invoiceID`);

-- -----------------------------------------------------
-- View `invoice_database`.`sell_report_invoices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `invoice_database`.`sell_report_invoices`;
USE `invoice_database`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `invoice_database`.`sell_report_invoices` AS select `i`.`invoiceID` AS `invoiceID`,`i`.`price` AS `price`,`i`.`date` AS `date` from `invoice_database`.`invoice` `i` where cast(`i`.`date` as date) = curdate();

-- -----------------------------------------------------
-- View `invoice_database`.`total_invoices_price_for_today`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `invoice_database`.`total_invoices_price_for_today`;
USE `invoice_database`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `invoice_database`.`total_invoices_price_for_today` AS select sum(`i`.`price`) AS `totInvoicePrice` from `invoice_database`.`invoice` `i` where cast(`i`.`date` as date) = curdate();

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
