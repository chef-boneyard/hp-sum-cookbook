actions :create
default_action :create

attribute :remote_fs, kind_of: String
attribute :remote_location, kind_of: String

attribute :local_location, kind_of: String
attribute :local_mount, kind_of: String
attribute :local_directory, kind_of: String
attribute :local_fs, kind_of: String
attribute :local_mountpt, name_attribute: true, kind_of: String

attribute :nfs_type, kind_of: String
attribute :clean, kind_of: TrueClass

attr_accessor :exists
