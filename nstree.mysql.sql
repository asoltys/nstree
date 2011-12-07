/*
MySQL Data Transfer
Source Host: localhost
Source Database: yourdatabase
Target Host: localhost
Target Database: yourdatabase
Date: 5/23/2009 7:49:18 AM
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `categoryId` int(11) NOT NULL auto_increment,
  `parentCategoryId` int(11) NOT NULL,
  `categoryName` varchar(50) NOT NULL,
  PRIMARY KEY  (`categoryId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for categorynst
-- ----------------------------
DROP TABLE IF EXISTS `categorynst`;
CREATE TABLE `categorynst` (
  `treeId` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `lft` int(11) NOT NULL,
  `rgt` int(11) NOT NULL,
  PRIMARY KEY  (`treeId`,`id`),
  KEY `treeId` (`treeId`),
  KEY `id` (`id`),
  KEY `lft` (`lft`),
  CONSTRAINT `categorynst_ibfk_1` FOREIGN KEY (`id`) REFERENCES `category` (`categoryId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
