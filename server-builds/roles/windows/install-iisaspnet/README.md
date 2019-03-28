Install IIS ASP.NET
===================

Written by Michael Barron.

This role installs IIS on Windows 2012 R2 and 2016 servers, utilising the SXS folder copied from a remote repository.


<br/><br/>

Requirements
------------

- Requires a D drive already present.
- Compatible with 2012 R2 or 2016 ONLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- ansible_disks
- ansible_ip_addresses

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
        name: windows/install-iisaspnet
      when: install_iisaspnet

