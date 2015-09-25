#
# Cookbook Name:: hp-sum
# Recipe:: inventory_check
#

now = Time.now.to_i
lastcheck = node['hpsum']['inventory']['lastcheck']
interval = node['hpsum']['inventory']['interval']

log "Current time: #{now} Last check: #{lastcheck || 'nil'} Interval: #{interval}\n" do
  level :info
end

# check to see if we are out of interval policy
if lastcheck.nil? || (now - interval) > lastcheck
  log 'Running the inventory check' do
    level :info
  end
  node.override['hpsum']['inventory']['lastcheck'] = now
else
  log 'No need to run the inventory check, still in policy.' do
    level :info
  end
end

# if out of policy, iterate over mounts to run inventory checks
# hpsum --report --location (requires baseline)
# node[hpsum][bl].keys.each do |baseline|
#   baseline.keys.each do |pkg|
#     hpsum_package pkg do
#       action pkg[action]
#       version pkg[version]
#       allow_retry true
#       allow_reboot true
#     end
# end
