# timestamp of last inventory check
default['hpsum']['inventory']['lastcheck'] = nil
# time (in seconds) for the interval policy, default is 180 days
default['hpsum']['inventory']['interval'] = 15_552_000

# ip of server exporting baseline mounts
default['hpsum']['baseline']['hostip'] = '16.250.24.197'
# filterstring to be used when identifying baseline remote mounts
default['hpsum']['baseline']['filterstring'] = 'spp'
# base folder for local mount
default['hpsum']['baseline']['localmountfolder'] = '/mnt/nfs'
