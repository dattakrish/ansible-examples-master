Install NetBackup
=================

Written by Michael Barron.

This role deploys the NetBackup agent from a remote repository and installs it. It will then execute a PowerShell file (stored in the files directory) to configure the agent and host entries.
<br/><br/>

Requirements
------------

- Compatible with Windows ONLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- src_netbackup_path
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-netbackup
      when: backup_required
      

