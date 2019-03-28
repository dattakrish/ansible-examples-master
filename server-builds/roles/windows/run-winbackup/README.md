Run Windows Backup
==================

Written by Michael Barron.

This role makes sure the Windows Backup role is installed, and then runs a backup to the Y drive.
<br/><br/>

Requirements
------------

- Only compatible with Windows 2012 R2 or above.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- none

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/run-winbackup

