# Description #
Cookbook to manage updates with HP Smart Update Manager.

# Attributes #

* `['hpsum']['path']` path to cache HP SUM files, nil unless customer provides permanent location
* `['hpsum']['policy']['allow_reboot']` true by default
* `['hpsum']['inventory']['lastcheck']` timestamp
* `['hpsum']['inventory']['interval']` how frequently the policty
* `['hpsum']['baseline']['mount'][]` list of HP SUM baseline mounts

# Recipes #

## baseline_role_generator ##
Dynamically generate new roles from the baselines by iterating over the node['hpsum']['baseline']['mount'].keys using cheffish chef_role. Parses XML to dynamically generate roles.

### Roles ###
Baselines are managed as roles that provide the packages and their required versions.

```
role[bl_production]
[hpsum][bl][prod][action] = "downgrade"
[hpsum][bl][prod][ilo_firmware] = "2.3.1.2"
[hpsum][bl][prod][nic] = "9.2.3.5"
[hpsum][bl][prod][raidcontroller] = "1.2.3.5"
[hpsum][bl][prod][usbcontroller] = "9.2.3.5"
role[bl_hotfix]
[hpsum][bl][hotfix][action] = "rewrite"
[hpsum][bl][hotfix][raidcontroller] = "1.2.3.7"
role[bl_hotfix2]
[hpsum][bl][hotfix2][action] = "upgrade"
[hpsum][bl][hotfix2][raidcontroller2] = "1.2.3.9"
```

node[hpsum][bl].keys.each do |baseline|
  baseline.keys.each do |pkg|
    hpsum_package pkg do
      action pkg[action]
      version pkg[version]
      allow_retry true
      allow_reboot true
    end
end

## inventory_check ##
Iterates over mount points, generates new XML for future compliance check.
hpsum --report --location (requires baseline)

knife exec check dates report

## parse_node_data ##
Iterates over mount points, pushes XML into node object. Could be used for a compliance report. No changes to the node.

You can do an ad-hoc report
knife exec check packages report
role says
[hpsum][bl][hotfix][raidcontroller] = "1.2.3.7"
node says
[hpsum][bl][hotfix][raidcontroller] = "1.2.3.9"

## generate_audit_event ##
What sort of reports do we want to generate and where do they go? Audit cookbook or process data for Analytics.

## package_update ##
Performs updates
Call the HPSUM CLI to generate the new XML files based off of each baseline.
Mounts each HP SUM mount and runs the CLI, generating XML files
hpsum -s --rewrite|downgrade --location
Set environment for permanent HP SUM as an option %TMP%
rewrite requires preventing multiple runs

# License and Authors #

Author:: Matt Ray (<matt@chef.io>)

Copyright 2015 Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
