# timestamp of last inventory check
default['hpsum']['inventory']['lastcheck'] = nil
# time (in seconds) for the interval policy, default is 180 days
default['hpsum']['inventory']['interval'] = 15_552_000

# ip of server exporting baseline mounts
default['hpsum']['baseline']['hostip'] = '16.250.24.197'
# filterstring to be used when identifying baseline remote mounts
default['hpsum']['baseline']['filterstring'] = 'hotfix2'

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
