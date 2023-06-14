# Citrix Virtual Apps and Desktop vCenter Lab Deploy
Uses Terraform and Ansible to deploy a fully functional CVAD environment. Based on project [CITRIX-VAD-LAB](https://github.com/ryancbutler/Citrix-VAD-LAB).

## What it does

Deploys the following:
 - 2 DDC Controllers with Director
 - 2 Storefront Servers (Cluster)
 - 1 SQL and License Server
 - 1 Stand alone VDA
 - Add them to the specified domain

### DDC
 - Installs components including director
 - Creates Citrix site
 - Creates 1 Machine Catalog
 - Creates 1 Delivery Group
 - Creates 1 Published Desktop
 - Creates 3 Applications
    - Notepad
    - Calculator
    - Paint
 - Configures director
    - Adds logon domain
    - Sets default page
    - Removes SSL Warning

### Storefront
 - Installs Storefront components
 - Creates Storefront cluster
 - Configures Storefromt
   - Adds Citrix Gateway
   - Sets default page
   - Enables HTTP loopback for SSL offload
   - Adjusts logoff behavior

### SQL and Citrix License
 - Installs SQL and license server
 - Installs SQL management tools
 - Configures SQL for admins and service account
 - Copies Citrix license files

### VDA
 - Installs VDA components
 - Configures for DDCs

## Prerequisites

- Need CVAD ISO contents copied to accessible share via Ansible account (eg \\\mynas\isos\Citrix\Citrix_Virtual_Apps_and_Desktops_7_1906_2)
    - I used CVAD 7 2305 ISO
- SQL Express 2019 from the CVAD ISO is installed by default. If you want another version, need SQL ISO contents copied to accessible share via Ansible account (eg \\\mynas\isos\Microsoft\SQL\en_sql_server_2017_standard_x64_dvd_11294407). Don't forget to change the $sql_path in [vars.yml](ansible/vars.yml)
    - I used SQL Express 2019
- Need SSMS setup copied to accessible share via Ansible account (eg \\\mynas\exe\SSMS-Setup-ENU.exe)
- For offline feature installation, need the "microsoft-windows-netfx3-ondemand-package.cab" (you'll find it in sxs folder of your Windows Server ISO) copied to accessible share via Ansible account (eg \\mynas\isos\Microsoft\sxs\microsoft-windows-netfx3-ondemand-package.cab)
- DHCP enabled network (with DNS pointing at your ADDS server)
- vCenter access and rights capable of deploying machines

### Deploy machine
I used [Ubuntu WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to deploy from

1. [Ansible installed](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-18-04)
   - Install **pywinrm** `pip install pywinrm` and `pip install pywinrm[credssp]`
2. [Terraform installed](https://askubuntu.com/questions/983351/how-to-install-terraform-in-ubuntu)
3. [Terraform-Inventory](https://github.com/adammck/terraform-inventory/releases) installed in path.  This is used for the Ansible inventory
    - I copied to */usr/bin/*
4. (If using remote state)[Configure Access for the Terraform CLI](https://www.terraform.io/docs/cloud/free/index.html#configure-access-for-the-terraform-cli)
5. This REPO cloned down

### vCenter Windows Server Template
    
1. I used Windows Server 2016 but I assume 2019 should also work.
2. WinRM needs to be configured and **CredSSP** enabled
    - Ansible provides a great script to enable quickly https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
    - Run manually `Enable-WSManCredSSP -Role Server -Force`
3. Need .NET Framework 4.7.2 installed
4. I use linked clones to quickly deploy.  In order for this to work the template needs to be converted to a VM with a **single snapshot** created.

## Getting Started

### Terraform
1. From the *terraform* directory copy **lab.tfvars.sample** to **lab.tfvars**
2. Adjust variables to reflect vCenter environment
3. Review **main.tf** and adjust any VM resources if needed (https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/system-requirements.html)
4. (If using remote cloud state) At the bottom of **main.tf** uncomment the *terraform* section and edit the *organization* and *workspaces* fields
```
terraform {
   backend "remote" {
     organization = "TechDrabble"
     workspaces {
       name = "cvad-lab"
     }
   }
}
```
5. run `terraform init` to install needed provider

### Ansible
1. From the *ansible* directory copy **vars.yml.sample** to **vars.yml**
2. Adjust variables to reflect environment
3. If you want to license CVAD environment place generated license file in **ansible\roles\license\files**
4. Adjust variables in **main.yml** of **site-hydrate** and **createsite role**

## Deploy
If you are comfortable with below process `build.sh` handles the below steps.  

**Note:** If you prefer to run many of the tasks asynchronously switch the `ansible-playbook` lines within `build.sh` which will call a seperate playbook. This is faster but can consume more resources and less informative output.
```
#Sync
#ansible-playbook --inventory-file=/usr/bin/terraform-inventory ./ansible/playbook.yml -e @./ansible/vars.yml
#If you prefer to run most of the tasks async (can increase resources)
ansible-playbook --inventory-file=/usr/bin/terraform-inventory ./ansible/playbook-async.yml -e @./ansible/vars.yml
``` POUET

### Terraform
1. From the *terraform* directory run `terraform apply --var-file="lab.tfvars"`
2. Verify the results and type `yes` to start the build

### Ansible
1. From the *root* directory and the terraform deployment is completed run the following
    - `export TF_STATE=./terraform` used for the inventory script
    - Synchronous run (Serial tasks)
        - `ansible-playbook --inventory-file=/usr/bin/terraform-inventory ./ansible/playbook.yml -e @./ansible/vars.yml` to start the playbook
    - Asynchronous run (Parallel tasks)
        - `ansible-playbook --inventory-file=/usr/bin/terraform-inventory ./ansible/playbook-async.yml -e @./ansible/vars.yml` to start the playbook
    - Grab coffee

## Destroy
If you are comfortable with below process `destroy.sh` handles the below steps.  **Please note this does not clean up the computer accounts**

### Terraform
1. From the *terraform* directory run `terraform destroy --var-file="lab.tfvars"`
2. Verify the results and type `yes` to destroy