#
# Cookbook Name:: hp-sum
# Recipe:: inventory_check
#

# get the current timestamp
# subtract the last timestamp
#node['hpsum']['inventory']['lastcheck']
# compare vs. interval policy
#node['hpsum']['inventory']['interval']
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
