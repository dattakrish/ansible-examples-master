Add Server to SolarWinds
========================

Written by Michael Barron.

This role adds the server into SolarWinds.
<br/><br/>

Requirements
------------

- None
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- server_name
- primary_ip_address

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
        name: windows/add-solarwinds

