Install FireEye
===============

Written by Kristiyan Nikolov.

This role deploys the FireEye executable and config file and installs it.
<br/><br/>

Requirements
------------

- Should not be installed on database servers.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- src_fireeye_path
- src_fireeye_installer
- src_fireeye_config
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-fireeye
      when: server_role == 'Database'
