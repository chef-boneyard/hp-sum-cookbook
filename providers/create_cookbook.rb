use_inline_resources

# Create smallest possible wrapper cookbook for the provided mount.
# Look for a bp-*.xml file and extract the baseline name.
# From that, assert a cookbook name
# Overwrite an existing cookbook in the path with the same name

action :create do

  require 'nokogiri'

  remote_fs = new_resource.remote_fs
  remote_location = new_resource.remote_location

  local_location = new_resource.local_location
  local_mount = new_resource.local_mount
  local_directory = new_resource.local_directory
  local_fs = new_resource.local_fs
  local_mountpt = new_resource.local_mountpt

  nfs_type = new_resource.nfs_type
  clean = new_resource.clean

  # if there is a matching baseline config file, pull the name out and establish
  # our cookbook name

  @doc = Nokogiri::XML("<name_xlate /><description_xlate />")
  ::Dir["#{local_mountpt}/bp-*.xml"].each do |file|
    f = ::File.open(file)
    @doc = Nokogiri::XML(f)
    f.close
  end

  cookbook_name = 'HPSum-' + @doc.css("name_xlate")[0].text.gsub(' ','_')
  bl_action = 'upgrade'
  bl_description = @doc.css("description_xlate")[0].text

  directory "/tmp/cookbooks/#{cookbook_name}/recipes" do
    recursive true
    action :create
  end

  directory "/tmp/cookbooks/#{cookbook_name}/attributes" do
    recursive true
    action :create
  end

  template "/tmp/cookbooks/#{cookbook_name}/recipes/inventory_check.rb" do
    source 'inventory_check.rb.erb'
    variables ({ :cookbook_name => cookbook_name})
  end

  combined_report = "HPSUM_Combined_Report_#{cookbook_name}.xml"

  template "/tmp/cookbooks/#{cookbook_name}/attributes/default.rb" do
    source 'attributes_default.rb.erb'
    variables ({ :action => bl_action,
                 :remote_fs => remote_fs, :remote_location => remote_location,
                 :local_location => local_location, :local_mount => local_mount, :local_directory => local_directory,  :local_fs => local_fs,
                 :combined_report => combined_report,
                 :nfs_type => nfs_type, :clean => clean })
  end

  template "/tmp/cookbooks/#{cookbook_name}/metadata.rb" do
    source 'metadata.rb.erb'
    variables ({ :cookbook_name => cookbook_name})
  end

  template "/tmp/cookbooks/#{cookbook_name}/README.md" do
    source 'README.md.erb'
    variables ({ :cookbook_name => cookbook_name, :remote_location => remote_location})
  end

  execute 'Upload Cookbook' do
    command "knife cookbook upload #{cookbook_name} -o /tmp/cookbooks/"
    notifies :delete, 'directory[cleanup]'
  end

  directory "cleanup" do
    path "/tmp/cookbooks/#{cookbook_name}"
    recursive true
    action :nothing
  end
end
