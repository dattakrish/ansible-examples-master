Configure Local Group Access
============================

Written by Barry Field.

This role modifies access to the Administrators and RDP local groups on a Windows Server.
<br/><br/>

Requirements
------------

- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- None

Passed from playbook:
- domain
- domain_adm_group
- domain_std_group

Passed from global vars file:
- grp_gdc_admin_1
- grp_gdc_admin_2
- grp_gdc_admin_3
- grp_gdc_admin_4
- grp_gdc_event
- domain_admins
- grp_expuk_admin_1
- grp_expuk_admin_1
- grp_all_admin_1
- grp_all_admin_2
- grp_all_event
- grp_all_rdp_1
- grp_ipani_admin_1
- grp_remove_1
- grp_remove_2
- grp_remove_3
- grp_remove_4
- grp_remove_5
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

      - include_role:
          name: windows/configure-group-access


