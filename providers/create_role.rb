use_inline_resources

# Create role if needed - for the provided mount, look for a bp-*.xml file and
# extract the baseline name.  From that, assert a role name, check to see if it
# already exists, and create it if needed.

action :create do

  local_mountpt = new_resource.local_mountpt
  local_mount_folder = new_resource.local_folder

  # if there is a matching baseline config file, pull the name out and establish
  # our role name
  blrolename = ''
  Open3.popen3("grep name_xlate #{local_mountpt}/bp-*.xml") do |stdin, stdout, stderr, wait_thr|
    if wait_thr.value.success?
      line = stdout.gets
      blname = line[/>(\w|\s)+</].gsub(' ','_').gsub('>','').gsub('<','')
      blrolename = local_mount_folder + '-' + blname
      puts "\nblrolename: #{blrolename}"
    end
  end

  # TODO: Use cheffish determine if this role already exists and needs updating

  # TODO: Use cheffish to create/update the role with mount, version, and name information

end
