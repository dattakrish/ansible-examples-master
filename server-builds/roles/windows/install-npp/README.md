Install Notepad++
=================

Written by Scott Whitehead.

This role deploys the Notepad++ executable and installs it.
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
- src_npp_path
- src_npp_installer
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

