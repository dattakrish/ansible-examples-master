#!/bin/bash
#$VM_Name = "UKWIN12IAASXX"          #Name of VM to create
#$VC_Server_Name =   #vCenter Server Name
#$VC_Data_Center_Name
#$VM_Template_Name, #Template name to use
#$Inventory_Location = "New Builds", #Location to deploy VM
#$VC_Cluster_Name,  #Name of cluster to run VM
#$DataStore_Cluster_Name,      #Storage Destination
#$Windows_Domain,     #AD domain that the VM is created in
#$Primary_VLAN,       #Examples CORPNET_2579
#$Primary_IP_Address,
#$Primary_Subnet_Mask,
#$Primary_Default_Gateway,
#$Backup_VLAN,
#$Backup_IP_Address, 
#$Backup_Subnet_Mask,
#$Memory_GB,
#$CPU_Sockets,
#$CPU_Cores_Per_Socket,
#$Build_Engineer_Email,
#$Backup_Required,
#$Is_VM,
#$Y_Drive_Required="yes"

VC_Server_Name="ukfhpcbvcs02.uk.experian.local" # This will come as an input from SNOW
VC_Data_Center_Name="Fairham" # This will come as an input from SNOW
VC_Cluster_Name="FH 40-Core Linux 01" # This will come as an input from SNOW
DataStore_Cluster_Name="FH_40-Core_Lnx-01_T1-NR" # This will come as an input from SNOW
VM_Name="ETIG-TESTVM02" # This will come as an input from SNOW. VM-NAME-CHECK15=15 char;VM-NAME-CHECK015>15
Windows_Domain="uk.experian.local" # This will come as an input from SNOW
Is_VM="Yes" # This will come as an input from SNOW. Values can be Yes|No
VM_Template_Name="IAAS-GTS-2016-DC-Template-FH" # This will come as an input from SNOW
Primary_VLAN="CORPNET|Layer2-Xsite|2579" # This will come as an input from SNOW
Primary_IP_Address="10.188.240.160" # This will come as an input from SNOW
Primary_Subnet_Mask="255.255.255.192" # This will come as an input from SNOW
Primary_Default_Gateway="10.188.240.190" # This will come as an input from SNOW
Backup_VLAN="SBN|backup|clients" # This will come as an input from SNOW
Backup_IP_Address="10.188.240.161" # This will come as an input from SNOW
Backup_Subnet_Mask="255.255.255.192" # This will come as an input from SNOW
Memory_GB="12" # This will come as an input from SNOW
CPU_Sockets="4" # This will come as an input from SNOW
CPU_Cores_Per_Socket="1" # This will come as an input from SNOW
Build_Engineer_Email="krishnendu.datta@experian.com" # This will come as an input from SNOW
Backup_Required="Yes" # This will come as an input from SNOW
Y_Drive_Required="yes" # This will come as an input from SNOW
Inventory_Location="ETIG" # This may come from SNOW as input. Default value assigned if nothing passed

echo $Primary_VLAN
echo $Primary_IP_Address
echo $Primary_Subnet_Mask
echo $Primary_Default_Gateway
echo $Backup_VLAN
echo $Backup_IP_Address
echo $Backup_Subnet_Mask
echo $VC_Server_Name
echo $VM_Template_Name
echo $DataStore_Cluster_Name
echo $VM_Name
echo $Windows_Domain
echo $VC_Cluster_Name
echo $Memory_GB
echo $CPU_Sockets
echo $CPU_Cores_Per_Socket
echo $Build_Engineer_Email
echo $VC_Data_Center_Name
echo $Backup_Required
echo $Inventory_Location
echo $Is_VM
echo $Y_Drive_Required

echo "Started vm build process on `date`"
ansible-playbook build-vm-from-template.yml -e "VC_Server_Name=$VC_Server_Name VC_Data_Center_Name=$VC_Data_Center_Name VC_Cluster_Name=$VC_Cluster_Name DataStore_Cluster_Name=$DataStore_Cluster_Name VM_Name=$VM_Name Windows_Domain=$Windows_Domain VM_Template_Name=$VM_Template_Name Primary_VLAN=$Primary_VLAN Primary_IP_Address=$Primary_IP_Address Primary_Subnet_Mask=$Primary_Subnet_Mask Primary_Default_Gateway=$Primary_Default_Gateway Backup_VLAN=$Backup_VLAN Backup_IP_Address=$Backup_IP_Address Backup_Subnet_Mask=$Backup_Subnet_Mask Is_VM=$Is_VM Memory_GB=$Memory_GB CPU_Sockets=$CPU_Sockets CPU_Cores_Per_Socket=$CPU_Cores_Per_Socket Build_Engineer_Email=$Build_Engineer_Email Backup_Required=$Backup_Required Y_Drive_Required=$Y_Drive_Required Inventory_Location=$Inventory_Location"
echo "Completed vm build process on `date`"
