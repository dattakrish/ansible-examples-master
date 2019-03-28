Deploy Acronis .BAT File
========================

Written by Michael Barron.

This role copies the acronis.bat file to System32.
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
        name: windows/deploy-acronisbat