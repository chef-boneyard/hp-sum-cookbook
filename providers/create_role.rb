use_inline_resources

# Create role if needed - for the provided mount, look for a bp-*.xml file and
# extract the baseline name.  From that, assert a role name, check to see if it
# already exists, and create it if needed.

action :create do

  require 'nokogiri'
  remote_mount = new_resource.remote_mount
  local_mountpt = new_resource.local_mountpt
  local_mount_folder = new_resource.local_folder

  # if there is a matching baseline config file, pull the name out and establish
  # our role name

  @doc = Nokogiri::XML("<name_xlate /><description_xlate />")
  ::Dir["#{local_mountpt}/bp-*.xml"].each do |file|
    f = ::File.open(file)
    @doc = Nokogiri::XML(f)
    f.close
  end

  blrolename = local_mount_folder + '-' + @doc.css("name_xlate")[0].text.gsub(' ','_')

  blattr = Hash.new
  blattr['mount'] = remote_mount
  blattr['action'] = 'upgrade'
  blattr['description'] = @doc.css("description_xlate")[0].text

  # Use cheffish to update mount
  chef_role blrolename do
    default_attributes blattr
    action :create
  end

end
