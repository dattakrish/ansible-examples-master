Add VisionApp
================

Written by Michael Barron.

This role adds the Windows server into VisionApp, required for all Windows Servers.
<br/><br/>

Requirements
------------

- Requires the PowerShell REST API to work and to be exectued from the Script Hosts.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- server_name
- server_role
- region
- business_unit
- sub_business_unit
- domain

Passed from global vars file:
- none
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/add-visionapp

