Install SQL Server
==================

Written by Barry Field.

This role deploys the SQL source files, and executes an install PowerShell script.
<br/><br/>

Requirements
------------

- Compatible with Windows 2016 ONLY
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- sql_version
- sql_collation

Passed from global vars file:
- src_sql_2016_ent_path
- src_sql_2016_std_path
- src_sql_2017_ent_path
- src_sql_2017_std_path
- cfg_sql_destPath
- cfg_sql_zipDest
- cfg_sql_working_Dir
- cfg_sql_powershellPath
- cfg_sql_sqladmin_Key
- cfg_sql_sqladmin_Pw
- cfg_sql_key_File
- cfg_sql_txt_File
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-sql

