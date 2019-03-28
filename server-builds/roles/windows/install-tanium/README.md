Install Tanium
==============

Written by Michael Barron.

This role deploys the Tanium agent from a remote repository and installs it.
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
- src_tanium_path
- cfg_tanium_ip1
- cfg_tanium_ip2
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-tanium
      

