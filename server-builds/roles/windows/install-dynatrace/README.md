Install Dynatrace OneAgent
==========================

Written by Tom Meer.

This role deploys the Dynatrace OneAgent installer from a remote repository and installs it.
<br/><br/>

Requirements
------------

- Compatible with Windows 2012 R2 or 2016 ONLY.
- No additional/custom modules required.
<br/>

Role Variables
--------------

Passed from host facts:
- none

Passed from playbook:
- server_env
- dynatrace_hostgroup

Passed from global vars file:
- src_dynatrace_path
- src_dynatrace_installer
- cfg_dynatrace_gateway
- cfg_dynatrace_infraonly
- cfg_dynatrace_tenantid_prod
- cfg_dynatrace_tenantid_nonprod
- cfg_dynatrace_tenanttoken_prod
- cfg_dynatrace_tenanttoken_nonprod
<br/>

Dependencies
------------

No other roles used within this role.
<br/><br/>

Example Playbook
----------------

Example of how to use this role:

    - include_role:
        name: windows/install-dynatrace
      when: install_dynatrace

