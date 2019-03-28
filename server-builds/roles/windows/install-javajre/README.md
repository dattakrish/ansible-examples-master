Install Java JRE
================

Written by Michael Barron

This role deploys the Java JRE executable and installs it.
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
- src_javajre_path
- src_javajre_installer
- src_javajre_config
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-javajre
      when: install_javajre

