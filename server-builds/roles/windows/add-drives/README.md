Add Windows Drives
==================

Written by Tom Meer.

This role initialises and formats new drives in Windows.
<br/><br/>

Requirements
------------

- Compatible with Windows 2008 or above.
- PowerShell requires version 3 or above.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- drive_letters
- drive_sizes
- drive_labels
- drive_allocation

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
        name: windows/add-drive
      when: extra_drives

