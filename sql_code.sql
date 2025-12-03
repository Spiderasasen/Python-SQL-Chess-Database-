-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ddiaz11
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema ddiaz11
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ddiaz11` DEFAULT CHARACTER SET utf8 ;
USE `ddiaz11` ;

-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_Opening`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_Opening` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_Opening` (
  `Chess_Opening_id` INT NOT NULL AUTO_INCREMENT,
  `Eco` VARCHAR(3) NULL,
  `Name` VARCHAR(100) NULL,
  `Opening_Play` INT NULL,
  PRIMARY KEY (`Chess_Opening_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_Winning_Stats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_Winning_Stats` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_Winning_Stats` (
  `Status_id` INT NOT NULL AUTO_INCREMENT,
  `Winning_player` VARCHAR(5) NULL,
  `Victory_results` VARCHAR(9) NULL,
  `Number_of_turns` INT NULL,
  PRIMARY KEY (`Status_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_Time`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_Time` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_Time` (
  `Time_id` INT NOT NULL AUTO_INCREMENT,
  `Start_time` BIGINT UNSIGNED NULL,
  `End_time` BIGINT UNSIGNED NULL,
  `Time_incrument` VARCHAR(10) NULL,
  PRIMARY KEY (`Time_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_Game`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_Game` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_Game` (
  `Game_Primary_ID` INT NOT NULL AUTO_INCREMENT,
  `Game_id` VARCHAR(25) NULL,
  `Rated` VARCHAR(5) NULL,
  `Status_id` INT NOT NULL,
  `Time_id` INT NOT NULL,
  PRIMARY KEY (`Game_Primary_ID`, `Status_id`, `Time_id`),
  INDEX `fk_Chess_Game_Chess_Winning_Stats1_idx` (`Status_id` ASC) VISIBLE,
  INDEX `fk_Chess_Game_Chess_Time1_idx` (`Time_id` ASC) VISIBLE,
  CONSTRAINT `fk_Chess_Game_Chess_Winning_Stats1`
    FOREIGN KEY (`Status_id`)
    REFERENCES `ddiaz11`.`Chess_Winning_Stats` (`Status_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Chess_Game_Chess_Time1`
    FOREIGN KEY (`Time_id`)
    REFERENCES `ddiaz11`.`Chess_Time` (`Time_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_Player`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_Player` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_Player` (
  `Player_id` INT NOT NULL AUTO_INCREMENT,
  `Game_Primary_ID` INT NOT NULL,
  `White_player` VARCHAR(100) NULL,
  `Black_player` VARCHAR(100) NULL,
  PRIMARY KEY (`Player_id`, `Game_Primary_ID`),
  INDEX `fk_Chess_Player_Chess_Game1_idx` (`Game_Primary_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Chess_Player_Chess_Game1`
    FOREIGN KEY (`Game_Primary_ID`)
    REFERENCES `ddiaz11`.`Chess_Game` (`Game_Primary_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_Moves`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_Moves` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_Moves` (
  `Moves_id` INT NOT NULL AUTO_INCREMENT,
  `Moves` VARCHAR(10000) NULL,
  `Chess_Opening_id` INT NOT NULL,
  `Player_id` INT NOT NULL,
  PRIMARY KEY (`Moves_id`, `Chess_Opening_id`, `Player_id`),
  INDEX `fk_Chess_Moves_Chess_Opening_idx` (`Chess_Opening_id` ASC) VISIBLE,
  INDEX `fk_Chess_Moves_Chess_Player1_idx` (`Player_id` ASC) VISIBLE,
  CONSTRAINT `fk_Chess_Moves_Chess_Opening`
    FOREIGN KEY (`Chess_Opening_id`)
    REFERENCES `ddiaz11`.`Chess_Opening` (`Chess_Opening_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Chess_Moves_Chess_Player1`
    FOREIGN KEY (`Player_id`)
    REFERENCES `ddiaz11`.`Chess_Player` (`Player_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_White`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_White` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_White` (
  `White_Player_id` INT NOT NULL AUTO_INCREMENT,
  `Rating` INT NULL,
  PRIMARY KEY (`White_Player_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_Black`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_Black` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_Black` (
  `Black_Player_id` INT NOT NULL AUTO_INCREMENT,
  `Rating` INT NULL,
  PRIMARY KEY (`Black_Player_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_White_has_Chess_Player`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_White_has_Chess_Player` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_White_has_Chess_Player` (
  `White_Player_id` INT NOT NULL,
  `Player_id` INT NOT NULL,
  PRIMARY KEY (`White_Player_id`, `Player_id`),
  INDEX `fk_Chess_White_has_Chess_Player_Chess_Player1_idx` (`Player_id` ASC) VISIBLE,
  INDEX `fk_Chess_White_has_Chess_Player_Chess_White1_idx` (`White_Player_id` ASC) VISIBLE,
  CONSTRAINT `fk_Chess_White_has_Chess_Player_Chess_White1`
    FOREIGN KEY (`White_Player_id`)
    REFERENCES `ddiaz11`.`Chess_White` (`White_Player_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Chess_White_has_Chess_Player_Chess_Player1`
    FOREIGN KEY (`Player_id`)
    REFERENCES `ddiaz11`.`Chess_Player` (`Player_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ddiaz11`.`Chess_Black_has_Chess_Player`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ddiaz11`.`Chess_Black_has_Chess_Player` ;

CREATE TABLE IF NOT EXISTS `ddiaz11`.`Chess_Black_has_Chess_Player` (
  `Black_Player_id` INT NOT NULL,
  `Player_id` INT NOT NULL,
  PRIMARY KEY (`Black_Player_id`, `Player_id`),
  INDEX `fk_Chess_Black_has_Chess_Player_Chess_Player1_idx` (`Player_id` ASC) VISIBLE,
  INDEX `fk_Chess_Black_has_Chess_Player_Chess_Black1_idx` (`Black_Player_id` ASC) VISIBLE,
  CONSTRAINT `fk_Chess_Black_has_Chess_Player_Chess_Black1`
    FOREIGN KEY (`Black_Player_id`)
    REFERENCES `ddiaz11`.`Chess_Black` (`Black_Player_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Chess_Black_has_Chess_Player_Chess_Player1`
    FOREIGN KEY (`Player_id`)
    REFERENCES `ddiaz11`.`Chess_Player` (`Player_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
