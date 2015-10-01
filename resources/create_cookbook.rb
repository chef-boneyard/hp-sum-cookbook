actions :create
default_action :create

attribute :local_mountpt, name_attribute: true, kind_of: String
attribute :remote_mount, kind_of: String
attribute :local_folder, kind_of: String

attr_accessor :exists
