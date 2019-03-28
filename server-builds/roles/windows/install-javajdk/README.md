Install Java JDK
================

Written by Michael Barron

This role deploys the Java JDK executable and installs it.
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
- src_javajdk_path
- src_javajdk_installer
- src_javajdk_version
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-javajdk
      when: install_javajdk

