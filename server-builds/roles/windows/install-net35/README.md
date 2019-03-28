Install .NET 3.5
================

Written by Tom Meer.

This role installs the .NET 3.5 feature on Windows 2012 R2 and 2016 servers, utilising the SXS folder copied from a remote repository.
<br/><br/>

Requirements
------------

- Compatible with 2012 R2 or 2016 ONLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- ansible_os_name

Passed from playbook:
- none

Passed from global vars file:
- src_sxs_2012r2
- src_sxs_2016
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-net35
      when: install_net35

