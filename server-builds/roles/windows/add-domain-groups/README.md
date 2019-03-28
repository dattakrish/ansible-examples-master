Add Admin and RDP Groups to Active Directory
===========================================

Written by Barry Field.

This role creates two new AD groups, one for admin users and one for RDP users. As requested by GSA. 
<br/><br/>

Requirements
------------

- Must be ran on the domain controller inventory.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- None

Passed from playbook:
- domain_adm_group
- domain_std_group

Passed from global vars file:
- ou_experianuk_groups
- ou_gdc_groups
- ou_ipani_groups
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

      - include_role:
          name: windows/add-domain-groups
        when: os_class == 'Windows'


