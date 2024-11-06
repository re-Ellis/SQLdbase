-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema iteration2model2
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema iteration2model2
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `iteration2model2` DEFAULT CHARACTER SET utf8mb3 ;
USE `iteration2model2` ;

-- -----------------------------------------------------
-- Table `iteration2model2`.`client`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`client` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`client` (
  `clientId` VARCHAR(5) NOT NULL,
  `cooperativeName` VARCHAR(70) NOT NULL,
  `abn` BIGINT UNSIGNED NOT NULL,
  `email` VARCHAR(50) NOT NULL,
  `contactNumber` VARCHAR(20) NOT NULL,
  `country` VARCHAR(60) NOT NULL,
  `state` VARCHAR(10) NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`clientId`),
  CONSTRAINT `ABN length` CHECK (LENGTH(`abn`)=11),
  CONSTRAINT `clientId format` CHECK ((`clientId` LIKE 'c%') AND (`clientId` REGEXP '[0-9]{4}')),
  CHECK (`email` LIKE '%@%'),
  CHECK (`contactNumber` NOT REGEXP '[^0-9+ \-\(\)]'),
  CHECK (`country` REGEXP '[a-zA-Z ]'),
  CHECK (`state` REGEXP '[a-zA-Z ]'),
  UNIQUE INDEX `clientId_UNIQUE` (`clientId` ASC) VISIBLE,
  UNIQUE INDEX `cooperativeName_UNIQUE` (`cooperativeName` ASC) VISIBLE,
  UNIQUE INDEX `abn_UNIQUE` (`abn` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`suppliermembers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`suppliermembers` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`suppliermembers` (
  `supplierMemberId` VARCHAR(5) NOT NULL,
  `supplierName` VARCHAR(70) NOT NULL,
  `country` VARCHAR(60) NOT NULL,
  `state` VARCHAR(10) NOT NULL,
  `postcode` VARCHAR(15) NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  `email` VARCHAR(50) NOT NULL,
  `phoneNumber` VARCHAR(20) NOT NULL,
  `abn` BIGINT UNSIGNED NULL DEFAULT NULL,
  `latitude` DECIMAL(6,3) NOT NULL,
  `longitude` DECIMAL(6,3) NOT NULL,
  PRIMARY KEY (`supplierMemberId`),
  CONSTRAINT `supplierMemberId format` CHECK ((`supplierMemberId` LIKE 'm%') AND (`supplierMemberId` REGEXP '[0-9]{4}')),
  CHECK (LENGTH(`abn`)=11),
  CHECK (`email` LIKE '%@%'),
  CHECK (`phoneNumber` NOT REGEXP '[^0-9+ \-\(\)]'),
  CHECK (`country` REGEXP '[a-zA-Z ]'),
  CHECK (`state` REGEXP '[a-zA-Z ]'),
  CHECK (ABS(`latitude`)<=180),
  CHECK (ABS(`longitude`)<=360),
  UNIQUE INDEX `suppMemId_UNIQUE` (`supplierMemberId` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`supplier`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`supplier` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`supplier` (
  `clientId` VARCHAR(5) NOT NULL,
  `supplierId` VARCHAR(5) NOT NULL,
  `supplierMemberId` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`clientId`, `supplierId`),
  INDEX `supplierMemberId_idx` (`supplierMemberId` ASC) VISIBLE,
  CONSTRAINT `supplierId format` CHECK ((`supplierId` LIKE 's%') AND (`supplierId` REGEXP '[0-9]{4}')),
  CONSTRAINT `supplierClient`
    FOREIGN KEY (`clientId`)
    REFERENCES `iteration2model2`.`client` (`clientId`),
  CONSTRAINT `supplierMemberId`
    FOREIGN KEY (`supplierMemberId`)
    REFERENCES `iteration2model2`.`suppliermembers` (`supplierMemberId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`batches`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`batches` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`batches` (
  `clientId` VARCHAR(5) NOT NULL,
  `batchNo` VARCHAR(10) NOT NULL,
  `purchaseYear` YEAR NOT NULL,
  `produceId` VARCHAR(5) NOT NULL,
  `useByDate` DATE NOT NULL,
  `supplierId` VARCHAR(5) NULL DEFAULT NULL,
  `purchaseDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `batchVolume` DECIMAL(8,2) UNSIGNED NOT NULL,
  `price` DECIMAL(8,2) UNSIGNED NULL,
  `excess` ENUM('yes', 'no') NULL DEFAULT 'no',
  PRIMARY KEY (`clientId`, `purchaseYear`, `batchNo`),
  INDEX `supplier_idx` (`supplierId` ASC) VISIBLE,
  INDEX `supplier` (`clientId` ASC, `supplierId` ASC) VISIBLE,
  CONSTRAINT `batchNo format` CHECK ((`batchNo` LIKE 'b%') AND (`batchNo` REGEXP '[0-9]{9}')),
  CONSTRAINT `batchclient`
    FOREIGN KEY (`clientId`)
    REFERENCES `iteration2model2`.`client` (`clientId`),
  CONSTRAINT `supplierofbatch`
    FOREIGN KEY (`clientId` , `supplierId`)
    REFERENCES `iteration2model2`.`supplier` (`clientId` , `supplierId`),
  CONSTRAINT `batchproduce`
    FOREIGN KEY (`clientId` , `produceId`)
    REFERENCES `iteration2model2`.`produce` (`clientId` , `produceId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`warehouse`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`warehouse` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`warehouse` (
  `clientId` VARCHAR(5) NOT NULL,
  `warehouseId` VARCHAR(5) NOT NULL,
  `country` VARCHAR(60) NOT NULL,
  `state` VARCHAR(10) NOT NULL,
  `postcode` VARCHAR(10) NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  `email` VARCHAR(50) NULL DEFAULT NULL,
  `phoneNumber` VARCHAR(20) NULL DEFAULT NULL,
  `latitude` DECIMAL(6,3) NOT NULL,
  `longitude` DECIMAL(6,3) NOT NULL,
  PRIMARY KEY (`clientId`, `warehouseId`),
  CONSTRAINT `warehouseId format` CHECK ((`warehouseId` LIKE 'w%') AND (`warehouseId` REGEXP '[0-9]{4}')),
  CHECK (`email` LIKE '%@%'),
  CHECK (`phoneNumber` NOT REGEXP '[^0-9+ \-\(\)]'),
  CHECK (`state` REGEXP '[a-zA-Z ]'),
  CHECK (`country` REGEXP '[a-zA-Z ]'),
  CHECK (ABS(`latitude`)<180),
  CHECK (ABS(`longitude`)<360),
  CONSTRAINT `warehouseClient`
    FOREIGN KEY (`clientId`)
    REFERENCES `iteration2model2`.`client` (`clientId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`batchlocation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`batchlocation` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`batchlocation` (
  `clientId` VARCHAR(5) NOT NULL,
  `batchNo` VARCHAR(10) NOT NULL,
  `purchaseYear` YEAR NOT NULL,
  `locationstatus` ENUM('warehouse', 'store', 'in transit') NOT NULL,
  `warehouseId` VARCHAR(5) NULL DEFAULT NULL,
  `storeId` VARCHAR(5) NULL DEFAULT NULL,
  PRIMARY KEY (`clientId`, `batchNo`, `purchaseYear`),
  INDEX `batchNo_idx` (`batchNo` ASC) VISIBLE,
  INDEX `storeId_idx` (`storeId` ASC) VISIBLE,
  INDEX `purcahseYear_idx` (`purchaseYear` ASC) VISIBLE,
  INDEX `warehouseId_idx` (`warehouseId` ASC) VISIBLE,
  INDEX `clientBatch` (`clientId` ASC, `purchaseYear` ASC, `batchNo` ASC) VISIBLE,
  INDEX `clientWarehouse` (`clientId` ASC, `warehouseId` ASC) VISIBLE,
  CONSTRAINT `clientBatch`
    FOREIGN KEY (`clientId` , `purchaseYear` , `batchNo`)
    REFERENCES `iteration2model2`.`batches` (`clientId` , `purchaseYear` , `batchNo`),
  CONSTRAINT `clientWarehouse`
    FOREIGN KEY (`clientId` , `warehouseId`)
    REFERENCES `iteration2model2`.`warehouse` (`clientId` , `warehouseId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`stores`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`stores` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`stores` (
  `clientId` VARCHAR(5) NOT NULL,
  `storeId` VARCHAR(5) NOT NULL,
  `country` VARCHAR(60) NULL DEFAULT NULL,
  `state` VARCHAR(10) NOT NULL,
  `postcode` VARCHAR(10) NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  `email` VARCHAR(50) NULL DEFAULT NULL,
  `phoneNumber` VARCHAR(20) NULL DEFAULT NULL,
  `latitude` DECIMAL(6,3) NOT NULL,
  `longitude` DECIMAL(6,3) NOT NULL,
  PRIMARY KEY (`clientId`, `storeId`),
  CONSTRAINT `storeId format` CHECK ((`storeId` LIKE 'z%') AND (`storeId` REGEXP '[0-9]{4}')),
  CHECK (`email` LIKE '%@%'),
  CHECK (`phoneNumber` NOT REGEXP '[^0-9+ \-\(\)]'),
  CHECK (`state` REGEXP '[a-zA-Z ]'),
  CHECK (`country` REGEXP '[a-zA-Z ]'),
  CHECK (ABS(`latitude`)<180),
  CHECK (ABS(`longitude`)<360),
  CONSTRAINT `storeClient`
    FOREIGN KEY (`clientId`)
    REFERENCES `iteration2model2`.`client` (`clientId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`batchsales`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`batchsales` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`batchsales` (
  `clientId` VARCHAR(5) NOT NULL,
  `batchNo` VARCHAR(10) NOT NULL,
  `purchaseYear` YEAR NOT NULL,
  `storeId` VARCHAR(5) NULL DEFAULT NULL,
  `salePrice` DECIMAL(8,2) UNSIGNED NULL DEFAULT NULL,
  `saleDate` DATE NULL DEFAULT (DATE(CURRENT_TIMESTAMP)),
  `disposalDate` DATE NULL DEFAULT (DATE(CURRENT_TIMESTAMP)),
  PRIMARY KEY (`clientId`, `batchNo`, `purchaseYear`),
  INDEX `purchaseYear_idx` (`purchaseYear` ASC) VISIBLE,
  INDEX `storeId_idx` (`storeId` ASC) VISIBLE,
  INDEX `clientBatchSales` (`clientId` ASC, `purchaseYear` ASC, `batchNo` ASC) VISIBLE,
  INDEX `storeId` (`clientId` ASC, `storeId` ASC) VISIBLE,
  CONSTRAINT `clientBatchSales`
    FOREIGN KEY (`clientId` , `purchaseYear` , `batchNo`)
    REFERENCES `iteration2model2`.`batches` (`clientId` , `purchaseYear` , `batchNo`),
  CONSTRAINT `storeId`
    FOREIGN KEY (`clientId` , `storeId`)
    REFERENCES `iteration2model2`.`stores` (`clientId` , `storeId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`producetype`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`producetype` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`producetype` (
  `produceTypeId` VARCHAR(5) NOT NULL,
  `produceName` VARCHAR(50) NOT NULL,
  `storageCondition` ENUM('dry', 'cold', 'frozen') NOT NULL,
  PRIMARY KEY (`produceTypeId`),
  UNIQUE INDEX `produceTypeId_UNIQUE` (`produceTypeId` ASC) VISIBLE,
  CONSTRAINT `produceTypeId format` CHECK ((`produceTypeId` LIKE 't%') AND (`produceTypeId` REGEXP '[0-9]{4}')))
  
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`memberproduce`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`memberproduce` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`memberproduce` (
  `supplierMemberId` VARCHAR(5) NOT NULL,
  `produceTypeId` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`supplierMemberId`, `produceTypeId`),
  INDEX `produceType_idx` (`produceTypeId` ASC) VISIBLE,
  CONSTRAINT `memberId`
    FOREIGN KEY (`supplierMemberId`)
    REFERENCES `iteration2model2`.`suppliermembers` (`supplierMemberId`),
  CONSTRAINT `memberProduceType`
    FOREIGN KEY (`produceTypeId`)
    REFERENCES `iteration2model2`.`produceType` (`produceTypeId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`produce`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`produce` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`produce` (
  `clientId` VARCHAR(5) NOT NULL,
  `produceId` VARCHAR(5) NOT NULL,
  `produceTypeId` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`clientId`, `produceId`),
  INDEX `produceType_idx` (`produceTypeId` ASC) VISIBLE,
  CONSTRAINT `produceId format` CHECK ((`produceId` LIKE 'p%') AND (`produceId` REGEXP '[0-9]{4}')),
  CONSTRAINT `produceClient`
    FOREIGN KEY (`clientId`)
    REFERENCES `iteration2model2`.`client` (`clientId`),
  CONSTRAINT `produceType`
    FOREIGN KEY (`produceTypeId`)
    REFERENCES `iteration2model2`.`producetype` (`produceTypeId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`warehousecapacity`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`warehousecapacity` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`warehousecapacity` (
  `clientId` VARCHAR(5) NOT NULL,
  `warehouseId` VARCHAR(45) NOT NULL,
  `storageCondition` ENUM('dry', 'cold', 'frozen') NOT NULL,
  `maxCapacity` DECIMAL(8,2) UNSIGNED NOT NULL,
  PRIMARY KEY (`clientId`, `warehouseId`, `storageCondition`),
  INDEX `warehouseId_idx` (`warehouseId` ASC) VISIBLE,
  CONSTRAINT `warehouseId`
    FOREIGN KEY (`clientId` , `warehouseId`)
    REFERENCES `iteration2model2`.`warehouse` (`clientId` , `warehouseId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `iteration2model2`.`supplierProduce`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `iteration2model2`.`supplierProduce` ;

CREATE TABLE IF NOT EXISTS `iteration2model2`.`supplierProduce` (
  `clientId` VARCHAR(5) NOT NULL,
  `supplierId` VARCHAR(5) NOT NULL,
  `produceId` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`clientId`, `supplierId`),
  INDEX `produce_idx` (`clientId` ASC, `produceId` ASC) VISIBLE,
  CONSTRAINT `supplierProduce`
    FOREIGN KEY (`clientId` , `supplierId`)
    REFERENCES `iteration2model2`.`supplier` (`clientId` , `supplierId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `produce`
    FOREIGN KEY (`clientId` , `produceId`)
    REFERENCES `iteration2model2`.`produce` (`clientId` , `produceId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

INSERT INTO `iteration2model2`.`client` (`clientId`, `cooperativeName`, `abn`,`email`,`contactNumber`,`country`,`state`,`address`) VALUES ('c0001', 'Golden Harvest Coop', '71303479927','client1@mail.com','(07) 7732 2456','Aus','QLD','address 1');
INSERT INTO `iteration2model2`.`client` (`clientId`, `cooperativeName`, `abn`,`email`,`contactNumber`,`country`,`state`,`address`) VALUES ('c0002', 'Coastal Community Farm Collective', '60280477842','client2@mail.com','(07) 8891 5677','Aus','QLD','address 2');
INSERT INTO `iteration2model2`.`client` (`clientId`, `cooperativeName`, `abn`,`email`,`contactNumber`,`country`,`state`,`address`) VALUES ('c0003', 'Sunshine Food Alliance', '80046404245','client3@mail.com','(07) 8372 6549','Aus','QLD','address 3');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0001', 'Sunrise Valley Farms', 'Aus', 'QLD', '4520','address 1','supplier1@mail.com','00000000','-27.35','152.903');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0002', 'Palm Grove Produce', 'Aus', 'QLD', '4170','address 2','supplier2@mail.com','00000000','-27.46','153.091');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0003', 'Azure Sky Gardens', 'Aus', 'QLD', '4152','address 3','supplier3@mail.com','00000000','-27.51','153.122');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0004', 'Harmony Harvest Co.', 'Aus', 'QLD', '4075','address 4','supplier4@mail.com','00000000','-27.55','152.990');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0005', 'Sunshine Farms Delight', 'Aus', 'QLD', '4068','address 5','supplier5@mail.com','00000000','-27.49','152.963');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0006', 'Golden Fields Organics', 'Aus', 'QLD', '4520','address 6','supplier6@mail.com','00000000','-27.32','152.869');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0007', 'Brisbane Berry Co.', 'Aus', 'QLD', '4123','address 7','supplier7@mail.com','00000000','-27.57','153.126');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0008', 'PalmHarvest', 'Aus', 'QLD', '4520','address 8','supplier8@mail.com','00000000','-27.42','152.867');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0009', 'Coastal Citrus Delights', 'Aus', 'QLD', '4170','address 9','supplier9@mail.com','00000000','-27.48','153.082');
INSERT INTO `iteration2model2`.`suppliermembers` (`supplierMemberId`, `supplierName`, `country`, `state`, `postcode`,`address`,`email`,`phonenumber`,`latitude`,`longitude`) VALUES ('m0010', 'Harbor Fresh Farms', 'Aus', 'QLD','4075','address 10','supplier10@mail.com','00000000','-27.57','152.971');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0001', 'apple', 'cold');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0002', 'orange', 'cold');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0003', 'brocolli', 'cold');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0004', 'onion', 'dry');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0005', 'potato', 'dry');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0006', 'carrot', 'cold');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0007', 'frozen berries', 'frozen');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0008', 'cabbage', 'cold');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0009', 'lettuce', 'cold');
INSERT INTO `iteration2model2`.`producetype` (`produceTypeId`, `produceName`, `storageCondition`) VALUES ('t0010', 'avacado', 'cold');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0001', 't0001');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0001', 't0003');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0001', 't0008');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0002', 't0009');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0003', 't0009');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0003', 't0003');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0004', 't0004');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0005', 't0001');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0005', 't0002');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0006', 't0005');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0006', 't0010');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0007', 't0007');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0008', 't0007');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0008', 't0001');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0008', 't0002');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0008', 't0003');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0009', 't0002');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0009', 't0004');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0010', 't0001');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0010', 't0002');
INSERT INTO `iteration2model2`.`memberproduce` (`supplierMemberId`, `produceTypeId`) VALUES ('m0010', 't0006');
INSERT INTO `iteration2model2`.`supplier` (`clientId`, `supplierId`, `supplierMemberId`) VALUES ('c0001', 's0001', 'm0002');
INSERT INTO `iteration2model2`.`supplier` (`clientId`, `supplierId`, `supplierMemberId`) VALUES ('c0001', 's0002', 'm0006');
INSERT INTO `iteration2model2`.`supplier` (`clientId`, `supplierId`, `supplierMemberId`) VALUES ('c0001', 's0003', 'm0007');
INSERT INTO `iteration2model2`.`supplier` (`clientId`, `supplierId`, `supplierMemberId`) VALUES ('c0001', 's0004', 'm0001');
INSERT INTO `iteration2model2`.`supplier` (`clientId`, `supplierId`, `supplierMemberId`) VALUES ('c0001', 's0005', 'm0005');
INSERT INTO `iteration2model2`.`supplier` (`clientId`, `supplierId`, `supplierMemberId`) VALUES ('c0001', 's0006', 'm0010');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0001', 'p0001', 't0009');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0001', 'p0002', 't0001');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0001', 'p0003', 't0008');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0001', 'p0004', 't0002');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0001', 'p0005', 't0005');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0001', 'p0006', 't0010');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0001', 'p0007', 't0007');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0002', 'p0001', 't0002');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0003', 'p0001', 't0003');
INSERT INTO `iteration2model2`.`produce` (`clientId`, `produceId`, `produceTypeId`) VALUES ('c0003', 'p0002', 't0002');
INSERT INTO `iteration2model2`.`warehouse` (`clientId`, `warehouseId`, `country`, `state`, `postcode`, `address`, `latitude`, `longitude`) VALUES ('c0001', 'w0001', 'Aus', 'QLD', '4170', 'address 1', '-27.480', '153.061');
INSERT INTO `iteration2model2`.`warehouse` (`clientId`, `warehouseId`, `country`, `state`, `postcode`, `address`, `latitude`, `longitude`) VALUES ('c0001', 'w0002', 'Aus', 'QLD', '4051', 'address 2', '-27.423', '152.993');
INSERT INTO `iteration2model2`.`warehousecapacity` (`clientId`, `warehouseId`, `storageCondition`, `maxCapacity`) VALUES ('c0001', 'w0001', 'dry', '10.5');
INSERT INTO `iteration2model2`.`warehousecapacity` (`clientId`, `warehouseId`, `storageCondition`, `maxCapacity`) VALUES ('c0001', 'w0001', 'cold', '15.2');
INSERT INTO `iteration2model2`.`warehousecapacity` (`clientId`, `warehouseId`, `storageCondition`, `maxCapacity`) VALUES ('c0001', 'w0002', 'dry', '15');
INSERT INTO `iteration2model2`.`warehousecapacity` (`clientId`, `warehouseId`, `storageCondition`, `maxCapacity`) VALUES ('c0001', 'w0002', 'cold', '35.5');
INSERT INTO `iteration2model2`.`warehousecapacity` (`clientId`, `warehouseId`, `storageCondition`, `maxCapacity`) VALUES ('c0001', 'w0002', 'frozen', '15.8');
INSERT INTO `iteration2model2`.`stores` (`clientId`, `storeId`, `country`, `state`, `postcode`, `address`, `latitude`, `longitude`) VALUES ('c0001', 'z0001', 'Aus', 'QLD', '4006', 'address1', '-27.456', '153.037');
INSERT INTO `iteration2model2`.`stores` (`clientId`, `storeId`, `country`, `state`, `postcode`, `address`, `latitude`, `longitude`) VALUES ('c0001', 'z0002', 'Aus', 'QLD', '4060', 'address2', '-27.471', '153.005');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000001', 'p0005', '2024-01-01', '2023-10-09', '0.3', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000002', 'p0002', '2023-11-03', '2023-10-27', '0.1', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000003', 'p0007', '2023-12-28', '2023-09-02', '0.2', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000004', 'p0002', '2023-11-05', '2023-10-26', '0.1', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000005', 'p0004', '2023-12-03', '2023-10-18', '0.5', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000006', 'p0001', '2023-11-06', '2023-10-07', '0.1', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000007', 'p0002', '2023-11-07', '2023-10-22', '0.1', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0002', 2023, 'b000000001', 'p0001', '2023-10-21', '2023-10-17', '0.2', 'yes');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000008', 'p0003', '2023-09-27', '2023-09-16', '0.25', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0001', 2023, 'b000000009', 'p0001', '2023-10-01', '2023-09-18', '0.40', 'no');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`,`price`, `excess`) VALUES ('c0001', 2023, 'b000000010', 'p0006', '2023-09-12', '2023-08-23', '0.35','80', 'yes');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`,`price`, `excess`) VALUES ('c0001', 2023, 'b000000011', 'p0003', '2023-09-19', '2023-08-28', '0.30','70', 'yes');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0003', 2023, 'b000000001', 'p0001', '2023-10-25', '2023-10-16', '0.3', 'yes');
INSERT INTO `iteration2model2`.`batches` (`clientId`, `purchaseYear`, `batchNo`, `produceId`, `useByDate`, `purchaseDate`, `batchVolume`, `excess`) VALUES ('c0003', 2023, 'b000000002', 'p0002', '2023-10-21', '2023-10-17', '0.25', 'yes');
INSERT INTO `iteration2model2`.`batchlocation` (`clientId`, `batchNo`, `purchaseYear`, `locationstatus`) VALUES ('c0001', 'b000000001', 2023, 'in transit');
INSERT INTO `iteration2model2`.`batchlocation` (`clientId`, `batchNo`, `purchaseYear`, `locationstatus`, `warehouseId`) VALUES ('c0001', 'b000000002', 2023, 'warehouse', 'w0001');
INSERT INTO `iteration2model2`.`batchlocation` (`clientId`, `batchNo`, `purchaseYear`, `locationstatus`, `warehouseId`) VALUES ('c0001', 'b000000003', 2023, 'warehouse', 'w0002');
INSERT INTO `iteration2model2`.`batchlocation` (`clientId`, `batchNo`, `purchaseYear`, `locationstatus`, `storeId`) VALUES ('c0001', 'b000000004', 2023, 'store', 'z0001');
INSERT INTO `iteration2model2`.`batchlocation` (`clientId`, `batchNo`, `purchaseYear`, `locationstatus`, `storeId`) VALUES ('c0001', 'b000000005', 2023, 'store', 'z0001');
INSERT INTO `iteration2model2`.`batchlocation` (`clientId`, `batchNo`, `purchaseYear`, `locationstatus`, `warehouseId`) VALUES ('c0001', 'b000000006', 2023, 'warehouse', 'w0002');
INSERT INTO `iteration2model2`.`batchlocation` (`clientId`, `batchNo`, `purchaseYear`, `locationstatus`, `storeId`) VALUES ('c0001', 'b000000007', 2023, 'store', 'z0002');
INSERT INTO `iteration2model2`.`batchsales` (`clientId`, `batchNo`, `purchaseYear`, `storeId`, `salePrice`, `saleDate`) VALUES ('c0001', 'b000000008', 2023, 'z0001', '80.00', '2023-09-20');
INSERT INTO `iteration2model2`.`batchsales` (`clientId`, `batchNo`, `purchaseYear`, `storeId`, `salePrice`, `saleDate`) VALUES ('c0001', 'b000000009', 2023, 'z0002', '130.00', '2023-09-25');
INSERT INTO `iteration2model2`.`batchsales` (`clientId`, `batchNo`, `purchaseYear`, `disposalDate`) VALUES ('c0001', 'b000000010', 2023, '2023-09-12');
