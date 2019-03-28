Update Disallowed and Auth Certs
===============================

Written by Michael Barron.

This role deploys updated Disallowed and Auth Certs/
<br/><br/>

Requirements
------------

- Compatible with Windows 2012 R2 and 2016 ONLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- src_certs_path
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/update-certs