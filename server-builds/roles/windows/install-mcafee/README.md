Install McAfee Framework
========================

Written by Michael Barron.

This role deploys the McAfee Framework agent from a remote repository and installs it.
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
- src_mcafee_path
- src_mcafee_installer
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-mcafee
      

