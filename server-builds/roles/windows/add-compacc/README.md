Pre-stages computer account in AD
=================================

Written by Barry Field.

This role determnines correct domain and OU to place new computer account in, and creates it.
<br/><br/>

Requirements
------------

- Must be ran on the domain controller inventory.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- None

Passed from playbook:
- domain
- server_name

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
          name: windows/add-compacc


