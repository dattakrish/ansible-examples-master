Install SQL Studio
==================

Written by Barry Field.

This role deploys the SQL Studio source files, installs and then removes source files.
<br/><br/>

Requirements
------------

- Compatible with Windows 2012 R2 and 2016 ONLY
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- sqlstudiosourceDest
- sqlstudiosourcePath

<br/>

Dependencies
------------

Playbook is only called if SQL Server has been installed and is included in 'windows-additonal.yml'
<br/><br/>

Example Playbook
----------------
n/a


