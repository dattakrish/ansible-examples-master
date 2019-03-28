Install Encase
==========================

Written by Barry Field.

This role deploys the Encase agent from a remote repository and installs it.
<br/><br/>

Requirements
------------

- Compatible with Windows 2012 R2 or 2016 ONLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- src_encase_path
- src_encase_installer
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-encase
      

