Add VMware Disks
================

Written by Tom Meer.

This role adds new disks to VMware virtual machines, using PowerShell deployed on the script hosts.
<br/><br/>

Requirements
------------

- Uses the ETIG script hosts, must be executed against those.
- PowerCLI module VMware.VimAutomation.Core.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- server_name
- vcenter_site
- drive_sizes

Passed from global vars file:
- none
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: shared/add-vmware-disk
      when: extra_drives

