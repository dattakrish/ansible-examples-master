Check VM Customisation Status
=============================

Written by Tom Meer.

Checks whether a virtual machine has finished cusomtisation and has acquired the correct fqdn.

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
- domain

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
        name: shared/check-vm-status

