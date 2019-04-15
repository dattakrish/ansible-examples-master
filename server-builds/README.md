Server Build Automation
=======================

Maintained by ETIG Automation.

This repository is for the server build automation.
<br/><br/>

Requirements
------------

- Full process compatible with 2016 ONLY currently.
- No additional/custom modules required.
<br/>

Contents
--------
**test-ping**<br/>
This playbook tests whether the IP is available.
<br/><br/>

**shared-add-dns**<br/>
This playbook adds a DNS entry in to EXPERIANUK DNS.
<br/><br/>

**inventory-add**<br/>
This playbook adds a host to the Server Builds inventory.
<br/><br/>

**shared-ad-config**<br/>
This is the root playbook for any tasks that run on the domain controllers, including:
- Deciding which domain controller to use
- Pre-staging domain account
- Adding DNS entries
- Creating server groups (Windows only)
<br/>

**deploy-vm**<br/>
This is the root playbook for deploying a new virtual machine on-premise, including:
- Deploying a VM based on a tenplate
- Adding new disk to a VM
<br/>

**script-host-deploys**<br/>
This is the root playbook for scripts that execute from the ETIG script hosts, including:
- Vmware disk additions
- VisionApp addition
- SolarWinds config
<br/>

**windows-post-build**<br/>
This is the root playbook for essential application and config deploys on Windows servers, including:
- OS configuration
- Deploying the security stack
<br/>

**windows-additional**<br/>
This is the root playbook for non-essential application and config deploys on Windows servers, including:
- Optional applications
- Adding new drives to Windows
<br/>

**inventory-remove**<br/>
This playbook removes a host from the Server Builds inventory.
<br/><br/>

Template Variables
------------------

- ping-test
  - primary_ip_address

- inventory-add
  - server_name
  - domain

- shared-add-dns
  - server_name
  - primary_ip_address

- shared-ad-config
  - server_name
  - os_class
  - os
  - domain
  - domain_adm_group (Windows only)
  - domain_std_group (Windows only)

- deploy-vm
  - server_name
  - server_role
  - os_class
  - os
  - domain
  - vcenter_site
  - vcenter_cluster
  - vcenter_datastore_cluster
  - vcenter_folder
  - primary_vlan
  - primary_ip_address
  - primary_subnet_mask
  - primary_default_gateway
  - backup_required
    - backup_vlan (only when backup_required)
    - backup_ip_address (only when backup_required)
    - backup_subnet_mask (only when backup_required)
  - vm_memory_gb
  - vm_cpu_sockets
  - vm_cpu_cores
  - build_engineer_email

- script-host-deploys
  - server_name
  - server_role
  - primary_ip_address
  - region
  - business_unit
  - sub_business_unit
  - domain
  - os_class
  - vcenter_site
  - vcenter_folder
  - extra_drives
  - drive_sizes

- windows-post-build
  - server_env
  - server_role
  - domain
  - domain_adm_group
  - domain_std_group
  - backup_required
  - dynatrace_hostgroup
  
- windows-additional
  - business_unit
  - support_group
  - install_net35
  - install_winzip
  - install_beyondcompare
  - install_iisaspnet
  - install_javajdk
  - install_javajre
  - install_npp
  - install_rds
    - rds_license_server (only when install_rds)
    - rds_license_mode (only when install_rds)
    - rds_target_server (only when install_rds)
  - install_vfile
  - extra_drives
    - drive_letters (only when extra_drives)
    - drive_sizes (only when extra_drives)
    - drive_labels (only when extra_drives)
    - drive_allocation (only when extra_drives)
  - install_sql
    - sql_version (only when install_sql)
    - sql_collation (only when install_sql)

- inventory-remove
  - server_name
