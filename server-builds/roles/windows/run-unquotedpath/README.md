Run Unquoted Path Fix
====================================

Written by Barry Field.

This role deploys and executes the Powershell script to identify unquoted paths in the registry and apply quotes.
<br/><br/>

Requirements
------------

- Required for all Windows servers. Compatible with all.
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
        name: windows/run-unquotedpath

