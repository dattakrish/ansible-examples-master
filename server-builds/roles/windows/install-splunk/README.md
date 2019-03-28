Install Splunk
==============

Written by Kristiyan Nikolov.

This role deploys the Splunk executable and installs it.
<br/><br/>

Requirements
------------

- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- src_splunk_path
- src_splunk_installer
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-splunk

