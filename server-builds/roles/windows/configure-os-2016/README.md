Configure Windows Server 2016
=============================

Written by Michael Barron.

This role configures many different OS settings, including:
- Install telnet client, snmp, server backup
- Uninstall defender, smb v1, wmp
- Modify registry entries, network protocols
- Create folders and permisions
- Reboots server
<br/><br/>

Requirements
------------

- Compatible with Windows Server 2016 OLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- ansible_date_time.date
- ansible_domain

Passed from playbook:
- ANSIBLE_NET_USERNAME
- ANSIBLE_NET_PASSWORD
- backup_required

Passed from global vars file:
- src_config2016_path
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/configure-os-2016
      when: "'2016' in ansible_os_name"

