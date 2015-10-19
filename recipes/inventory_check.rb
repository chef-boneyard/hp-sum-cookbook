#
# Cookbook Name:: hp-sum
# Recipe:: inventory_check
#

now = Time.now.to_i
lastcheck = node['hpsum']['inventory']['lastcheck']
interval = node['hpsum']['inventory']['interval']
remote_mountpt = node['hpsum']['remote_mountpt']
mounthost = node['hpsum']['baseline']['hostip']
app_mountpt = node['hpsum']['application']['mountpoint']

log "Current time: #{now} Last check: #{lastcheck || 'nil'} Interval: #{interval}\n" do
  level :info
end

# check to see if we are out of interval policy
if lastcheck.nil? || (now - interval) > lastcheck
  log 'Running the inventory check' do
    level :info
  end

  ###################################################
  # Mount the specified HPSum Baseline mount point
  ###################################################
  log "Baseline Mount Point==> #{remote_mountpt}" do
    level :info
  end

  local_mount_folder = remote_mountpt[/\w+$/]
  local_mountpt = "#{node['hpsum']['baseline']['localmountfolder']}/#{local_mount_folder}"

  puts "local mount point: #{local_mountpt}"

  directory local_mountpt do
    recursive true
    group 'root'
    owner 'root'
    mode 0755
    action :create
    not_if do ::Dir.exist?(local_mountpt) end
  end

  mount local_mountpt do
    device "#{mounthost}:#{remote_mountpt}"
    fstype 'nfs'
    options 'ro'
    action [:mount, :enable]
    #notifies :umount, "mount[#{local_mountpt}]"
    #notifies :disable, "mount[#{local_mountpt}]"
  end


  ###################################################
  # Mount the HPSum Application mount point
  ###################################################
  log "Application Mount Point==> #{app_mountpt}" do
    level :info
  end

  app_mount_folder = app_mountpt[/\w+$/]
  local_app_mountpt = "#{node['hpsum']['baseline']['localmountfolder']}/#{app_mount_folder}"

  puts "local mount point: #{local_mountpt}"

  directory local_app_mountpt do
    recursive true
    group 'root'
    owner 'root'
    mode 0755
    action :create
    not_if do ::Dir.exist?(local_app_mountpt) end
  end

  mount local_app_mountpt do
    device "#{mounthost}:#{app_mountpt}"
    fstype 'nfs'
    options 'ro'
    action [:mount, :enable]
    #notifies :umount, "mount[#{app_mountpt}]"
    #notifies :disable, "mount[#{app_mountpt}]"
  end

  ###################################################
  # Execute HPSum Inventory against the baseline
  ###################################################
  execute 'Start HP Sum' do
    command "#{local_app_mountpt}/bin/hpsum --report --use_location #{local_mountpt}"
    returns [0,3] # HPSum Return code of 3 is "Sucess Not Required"
  end
  # out of policy, iterate over mounts to run inventory checks
  # hpsum --report --location (requires baseline)
  # node[hpsum][bl].keys.each do |baseline|
  #   baseline.keys.each do |pkg|
  #     hpsum --report --use_location (requires baseline)
  #     hpsum_package pkg do
  #       action pkg[action]
  #       version pkg[version]
  #       allow_retry true
  #       allow_reboot true
  #     end
  # end

  node.override['hpsum']['inventory']['lastcheck'] = now
else
  log 'No need to run the inventory check, still in policy.' do
    level :info
  end
end
