#
# Cookbook Name:: hp-sum
# Recipe:: inventory_check
#
require 'fileutils'

now = Time.now.to_i
lastcheck = node['hpsum']['inventory']['lastcheck']
interval = node['hpsum']['inventory']['interval']

log "Current time: #{now} Last check: #{lastcheck} Interval: #{interval}\n" do
  level :info
end

# Ascertain whether to use HP SUM NFS mount (nfstype), update HP SUM on local store (RO), or use existing local store (if exists) - inherit from wrapper cookbook
# Shorten some of the attributes that get re-used a number of times
hslocalmount = node['hpsum']['nfs']['locallocation']
hsremotemount = node['hpsum']['nfs']['remotelocation']
bllocalmount = node['hpsum']['baseline']['localfs']
blremotemount = node['hpsum']['baseline']['remotefs']
nfstype = node['hpsum']['nfs']['type']
localtmp = node['hpsum']['local']['directory']
localhs = "#{localtmp}/localhpsum/"

 # check to see if we are out of interval policy
 if lastcheck.nil? || (now - interval) > lastcheck
   log 'Running the inventory check' do
     level :info
   end

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

  # Run HP SUM command either from local store, or from NFS, if updating local store (RO) specify location (TMPDIR)
  case nfstype
  when "rw"
    execute 'NFS_rw' do
      command "#{hslocalmount}/bin/hpsum -s -use_location #{bllocalmount} -report -combined_report -reportdir #{localtmp}"
      returns [0,3]
      notifies :umount, "mount[#{hslocalmount}]"
      notifies :umount, "mount[#{bllocalmount}]"
    end
  when "ro"
      execute 'hpsum_ro' do
        command "#{hslocalmount}/bin/hpsum -s -use_location #{bllocalmount} -report -combined_report -reportdir #{localtmp}"
        environment 'TMPDIR' => "#{localtmp}"
        returns [0,3]
        notifies :umount, "mount[#{hslocalmount}]"
        notifies :umount, "mount[#{bllocalmount}]"
      end
  when "local"
    local64 = "#{localtmp}/localhpsum/x64"
    local86 = "#{localtmp}/localhpsum/x86"

    if ::Dir.exist?(local64)
       execute 'Local_startup_x64' do
         command "#{localtmp}/localhpsum/x64/hpsum_bin_x64 -s -use_location #{bllocalmount} -report -combined_report -reportdir #{localtmp}"
         returns [0,3]
         notifies :umount, "mount[#{bllocalmount}]"
       end
    elsif ::Dir.exist?(local86)
      execute 'Local_startup_x86' do
        command "#{localtmp}/localhpsum/x86/hpsum_bin_x86 -s -use_location #{bllocalmount} -report -combined_report -reportdir #{localtmp}"
        returns [0,3]
        notifies :umount, "mount[#{bllocalmount}]"
      end
    else
      log "There is no local store under #{localtmp}, exiting without update." do
        level :info
        notifies :umount, "mount[#{bllocalmount}]"
      end
    end
  end

  # Remove local store if required - if "true"
  if node['hpsum']['local']['clean']
    directory "#{localhs}" do
      recursive true
      action :delete
    end
  end

  node.normal['hpsum']['inventory']['lastcheck'] = now
else
  log 'No need to run the inventory check, still in policy.' do
    level :info
  end
end
