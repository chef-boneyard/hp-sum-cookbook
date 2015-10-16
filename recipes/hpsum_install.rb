#
# Cookbook Name:: hpsum_install
# Recipe:: default
#
# Copyright 2015, Hewlett P ckard Enterprise
#
# All rights reserved - Do Not Redistribute
#
require 'fileutils'

# Ascertain whether to use HP SUM NFS mount (nfstype), update HP SUM on local store (RO), or use existing local store (if exists) - inherit from wrapper cookbook
# Shorten some of the attributes that get re-used a number of times
hslocalmount = node['hpsum']['nfs']['locallocation']
hsremotemount = node['hpsum']['nfs']['remotelocation']
bllocalmount = node['hpsum']['baseline']['localfs']
blremotemount = node['hpsum']['baseline']['remotefs']
nfstype = node['hpsum']['nfs']['type']
localtmp = node['hpsum']['local']['directory']
localhs = "#{localtmp}/localhpsum/"

# Delete local HP SUM if necessary - if "true"
if node['hpsum']['local']['clean']
  directory "#{localhs}" do
    recursive true
    action :delete
  end
end

# Mount HP SUM NFS mount point (if required), either due to NFS use model or updating local store (RO)
case nfstype
when "rw"
  log "Mounting HP SUM NFS FS read-write!" do
    level :info
  end

  mount hslocalmount do
     device hsremotemount
     fstype 'nfs'
     options 'rw'
  end
when "ro"
  log "Mounting HP SUM NFS FS read-only!" do
    level :info
  end

  mount hslocalmount do
     device hsremotemount
     fstype 'nfs'
     options 'ro'
  end
when "local"
  log "Using local store in this iteration." do
    level :info
  end
end

# Mount the baseline NFS Mount Point
log "Mounting Firmware baseline NFS mount" do
  level :info
end

mount bllocalmount do
   device blremotemount
   fstype 'nfs'
   options 'ro'
end
#Array(node['hpsum']['baseline']['mount']).each do |fs|
#  mount fs['localfs']
#    device fs['remotefs']
#    fstyp 'nfs'
#    options 'ro'
#  end
#end

# Run HP SUM command either from local store, or from NFS, if updating local store (RO) specify location (TMPDIR)
case nfstype
when "rw"
  execute 'NFS_rw' do
    command "#{hslocalmount}/bin/hpsum -s -use_location #{bllocalmount} -report -combined_report -reportdir #{localtmp}"
    ignore_failure true
  end
when "ro"
    execute 'hpsum_ro' do
      command "#{hslocalmount}/bin/hpsum -s -use_location #{bllocalmount} -report -combined_report -reportdir #{localtmp}"
      environment 'TMPDIR' => "#{localtmp}"
      ignore_failure true
    end
when "local"
  local64 = "#{localtmp}/localhpsum/x64"
  local86 = "#{localtmp}/localhpsum/x86"

  if ::Dir.exist?(local64)
     execute 'Local_startup_x64' do
       command "#{localtmp}/localhpsum/x64/hpsum_bin_x64 -s -use_location #{bllocalmount} -report -combined_report -reportdir #{localtmp}"
       ignore_failure true
     end
  elsif ::Dir.exist?(local86)
    execute 'Local_startup_x86' do
      command "#{localtmp}/localhpsum/x86/hpsum_bin_x86 -s -use_location #{bllocalmount} -report -combined_report -reportdir #{localtmp}"
      ignore_failure true
    end
  else
    log "There is no local store under #{localtmp}, exiting without update." do
      level :info
    end
  end
end

# Clean Up - unmount NFS mounts
log "Cleaning up NFS mount-points!!" do
  level :info
end

# Baseline mount point
mount bllocalmount do
  device blremotemount
  fstype 'nfs'
  action :umount
end

#Array(node['hpsum']['baseline']['mount']).each do |fs|
#  mount fs['localfs']
#    device fs['remotefs']
#    fstyp 'nfs'
#    action :umount
#  end
#end

# HP SUM mount point - will attempt even if local
mount hslocalmount do
  device hsremotemount
  fstype 'nfs'
  action :umount
end

# Remove local store if required - if "true"
if node['hpsum']['local']['clean']
  directory "#{localhs}" do
    recursive true
    action :delete
  end
end
