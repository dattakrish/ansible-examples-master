Check RDP SHA256 Cert
=====================

Written by Michael Barron.

This role check RDP for SHA256 Cert. Required for Windows Server 2012 R2.
<br/><br/>

Requirements
------------

- Compatible with 2012 R2 ONLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- none

Passed from global vars file:
- src_sha256_path
- src_sha256_kb
- src_sha256_installer
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/check-rdp-sha256
      when: "'2012 R2' in ansible_os_name"