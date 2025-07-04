-- sudo -u mysql mysql < 03_slurmdb.sql
create user 'slurm'@'localhost' identified by 'an5rtdhH1KFNITO6';
grant all on slurm_acct_db.* TO 'slurm'@'localhost';
-- across network
CREATE USER 'slurm'@'%' IDENTIFIED BY 'an5rtdhH1KFNITO6';
GRANT ALL PRIVILEGES ON *.* TO 'slurm'@'%'  WITH GRANT OPTION;
-- SHOW ENGINES; -- must have InnoDB
-- #+--------------------+---------+-------------------------------------------------------------------------------------------------+--------------+------+------------+
-- #| Engine             | Support | Comment                                                                                         | Transactions | XA   | Savepoints |
-- #+--------------------+---------+-------------------------------------------------------------------------------------------------+--------------+------+------------+
-- #| CSV                | YES     | Stores tables as CSV files                                                                      | NO           | NO   | NO         |
-- #| MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                                           | NO           | NO   | NO         |
-- #| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                                       | NO           | NO   | NO         |
-- #| Aria               | YES     | Crash-safe tables with MyISAM heritage. Used for internal temporary tables and privilege tables | NO           | NO   | NO         |
-- #| MyISAM             | YES     | Non-transactional engine with good performance and small data footprint                         | NO           | NO   | NO         |
-- #| SEQUENCE           | YES     | Generated tables filled with sequential values                                                  | YES          | NO   | YES        |
-- #| InnoDB             | DEFAULT | Supports transactions, row-level locking, foreign keys and encryption for tables                | YES          | YES  | YES        |
-- #| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                                              | NO           | NO   | NO         |
-- #+--------------------+---------+-------------------------------------------------------------------------------------------------+--------------+------+------------+
-- #8 rows in set (0.001 sec)
 
create database slurm_acct_db;

