Install Windows Management Framework
====================================

Written by Michael Barron.

This role deploys the WMF installer and executes it.
<br/><br/>

Requirements
------------

- Required for Windows Server 2012 R2.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- src_wmf_path
- src_wmf_installer
- src_wmf_kb
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-npp
      when: install_npp

