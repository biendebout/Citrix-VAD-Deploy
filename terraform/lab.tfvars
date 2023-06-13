
#vsphere connetion info
vsphere_server     = "controller.access.network"
vsphere_user       = "administrator@vsphere.local"
vsphere_password   = "689tpa2Y@"
vsphere_datacenter = "Datacenter"
vsphere_datastore  = "datastore1"
#Resource Pool (If no resource pool place in CLUSTER/Resources format)
vsphere_rp           = "RP1"
vsphere_template     = "w2016"
#DHCP Network
vsphere_network      = "VM Network"
#Use linked clones.(Requires a single snapshot on the VM)
vsphere_linkedclones = true
#https://docs.microsoft.com/en-us/previous-versions/windows/embedded/ms912391(v=winembedded.11)?redirectedfrom=MSDN
vsphere_timezone = 105

#VM naming
#Prefix
vm_storefront = "sf-ctx-lab-0"
vm_ddc        = "ddc-ctx-lab-0"
vm_vda        = "vda-ctx-lab-0"
#Actual Name
vm_sql = "sql-ctx-lab-01"


#Join domain
domain_user     = "Administrateur@biendebout.ad"
domain_password = "01658B6c51"
domain          = "biendebout.ad"
