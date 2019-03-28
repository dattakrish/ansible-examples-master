Install Remote Desktop Services
===============================

Written by Michael Barron.

This role installs RDS on Windows 2012 R2 and 2016 servers and configures local/remote licence server.
<br/><br/>

Requirements
------------

- Compatible with 2012 R2 or 2016 ONLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- rds_license_server
- rds_license_mode
- rds_target_server

Passed from global vars file:
- scr_rds_name
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-rds
      when: install_rds

