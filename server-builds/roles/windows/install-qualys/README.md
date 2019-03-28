Install Qualys Cloud Agent
==========================

Written by Barry Field.

This role deploys the Qualys executable and installs it.
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
- src_qualys_path
- src_qualys_installer
- src_qualys_version
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-qualys

