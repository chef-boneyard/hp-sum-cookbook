# timestamp of last inventory check
default['hpsum']['inventory']['lastcheck'] = nil
# time (in seconds) for the interval policy, default is 180 days
default['hpsum']['inventory']['interval'] = 15_552_000

# ip of server exporting baseline mounts
default['hpsum']['baseline']['hostip'] = '16.250.24.197'
# filterstring to be used when identifying baseline remote mounts
default['hpsum']['baseline']['filterstring'] = 'spptool'

#######################
### Remote File System

# Remote NFS server and exported filesystem for Firmware baseline
default['hpsum']['baseline']['remotefs'] = '16.250.24.197:/opt/mount1/hotfix2'

# Remote NFS server and exported filesystem for HP SUM software
default['hpsum']['nfs']['remotelocation'] = '16.250.24.197:/opt/mount1/hpsum'

######################
### Local File System

# Local server mount point for the HP SUM software
default['hpsum']['nfs']['locallocation'] = '/opt/hpsum'

# base folder for local mount
default['hpsum']['baseline']['localmountfolder'] = '/mnt/nfs'

# Local store repository for copying HP SUM to server
default['hpsum']['local']['directory'] = '/var/tmp'

# Local server mount point for firmware baseline
default['hpsum']['baseline']['localfs'] = '/opt/hotfix2'

#########################
### Mount Behavior

# HP SUM NFS mount type - options are "rw", "ro", or "local"
default['hpsum']['nfs']['type'] = 'rw'

# Clean local store repository before and after run - options "nil" or "true"
default['hpsum']['local']['clean'] = nil


#########################
### Set attributes

# XPATH for attributes to gather from the HP SUM Combined report
default['hpsum']['combined_report']['firmware_xpath'] = '///inventoryreport'
default['hpsum']['combined_report']['drivers_xpath'] = '///firmwarereport//system//driver_details//driver'

# Driver name and version xpath from Combined report
default['hpsum']['swkey_xpath'] = '//driver//swkey'
default['hpsum']['version_xpath'] = '//driver//version'

# Firmware name and version xpath from Combined report
default['hpsum']['firmware_name_xpath'] = '//component//name'
default['hpsum']['firmware_version_xpath'] = '//component//version'

# Component type from Combined report
default['hpsum']['component_type_xpath'] = '//component//type'

# Name of the HP SUM Combined report for specific baseline
default['hpsum']['combined_report'] = 'HPSUM_Combined_Report_baseline.xml'
