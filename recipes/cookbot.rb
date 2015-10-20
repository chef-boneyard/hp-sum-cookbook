#
# Cookbook Name:: hp-sum
# Recipe:: cookbot
#
# Scan mounts of provided mounthost, for those that are SUM baselines, create
# a new wrapper cookbook and upload to the Chef Server.

require 'open3'
require 'fileutils'

mounthost = node['hpsum']['baseline']['hostip']

# run showmount -e to retrieve available mounts
mountlist = []
Open3.popen3("showmount -e #{mounthost}") do |stdin, stdout, stderr, wait_thr|
  if wait_thr.value.success?
    while (line = stdout.gets)
       if (line =~ /#{node['hpsum']['baseline']['filterstring']}/)
         mountlist.push(line)
       end
    end
  end
end

# parse through those mounts and find any with a baseline xml config file
mountlist.each do |mountline|
  remote_mountpt = mountline[/^\S+/]
  puts "remote mount point: #{remote_mountpt}"

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
    options 'rw'
    action [:mount, :enable]
    notifies :umount, "mount[#{local_mountpt}]"
    notifies :disable, "mount[#{local_mountpt}]"
  end

  hp_sum_create_cookbook local_mountpt do
    remote_fs node['hpsum']['baseline']['remotefs']
    remote_location node['hpsum']['nfs']['remotelocation']

    local_location node['hpsum']['nfs']['locallocation']
    local_mount node['hpsum']['baseline']['localmountfolder']
    local_directory node['hpsum']['local']['directory']
    local_fs node['hpsum']['baseline']['localfs']

    nfs_type node['hpsum']['nfs']['type']
    clean node['hpsum']['local']['clean']
    action :create
  end
end
