-- ##################################################
-- #         MUSICDB DATABASE CREATION SCRIPT       #
-- ##################################################

-- 01. Create user
CREATE USER music_admin WITH PASSWORD '******';
-- 02. Create database (with ENCODING= 'UTF8', TEMPLATE=Template 0, OWNER: music_admin)
CREATE DATABASE musicdb WITH ENCODING='UTF8' LC_COLLATE='es_CO.utf-8' LC_CTYPE='es_CO.utf-8' TEMPLATE=template0 OWNER = music_admin;
-- 03. Grant privileges
GRANT ALL PRIVILEGES ON DATABASE musicdb TO music_admin;
-- 04. Create Schema
CREATE SCHEMA IF NOT EXISTS vibesia_schema AUTHORIZATION music_admin;
-- 05. Comment on database
COMMENT ON DATABASE musicdb IS 'system database for music management';
-- 06. Comment of schema
COMMENT ON SCHEMA vibesia_schema IS 'main schema for the musicdb database';