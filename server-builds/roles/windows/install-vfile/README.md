Install V the File Viewer
=========================

Written by Scott Whitehead.

This role deploys the V the File Viewer executable and installs it.
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
- src_vfile_path
- src_vfile_appFolder
- src_vfile_installer
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-vfile
      when: install_vfile

