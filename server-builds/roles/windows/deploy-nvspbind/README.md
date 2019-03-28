Deplou NVSPBIND
===============

Written by Barry Field.

This role copies the nvspbind.exe binary to System32.
<br/><br/>

Requirements
------------

- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- src_nvspbind_path
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/deploy-nvspbind