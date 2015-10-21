#
# Cookbook Name:: hp-sum
# Recipe:: add_firmware_attributes.rb
#
# Uses the HP SUM Combined report to update firmware/driver attributes of the node


require 'nokogiri'
require 'pry'


report = File.expand_path(node['hpsum']['combined_report']+ "/^(HPSUM_Combined_Report_)(.*)(xml)$")
xmlfile = File.open(report)

@doc = Nokogiri::XML(File.open(xmlfile))

def get_driver_details drivers_xml, drivers
    swkeys = drivers_xml.xpath(node['hpsum']['swkey_xpath'])
    versions = drivers_xml.xpath(node['hpsum']['version_xpath'])
    if swkeys.length == versions.length
      iteration = swkeys.length
      for i in 0..iteration-1 do
        drivers[swkeys[i].content] = versions[i].content
      end
    end
end

def get_firmware_details firmware_xml, firmware
    components = firmware_xml.xpath(node['hpsum']['firmware_name_xpath'])
    versions = firmware_xml.xpath(node['hpsum']['firmware_version_xpath'])
    types = firmware_xml.xpath(node['hpsum']['component_type_xpath'])

    if components.length == versions.length
      iteration = components.length
      for i in 0..iteration-1 do
        if types[i].content == "Firmware"
          firmware[components[i].content] = versions[i].content
        end
      end
    end
end


drivers_list = @doc.xpath(node['hpsum']['combined_report']['drivers_xpath'])
drivers_hash = Hash.new
get_driver_details drivers_list, drivers_hash
drivers_hash.each do |name, version|
  #puts "node attribute will be [hpsum][driver_version][#{name}] = #{version}"
  node.set['hpsum']['driver_version'][name]=version
end

firmware_list = @doc.xpath(node['hpsum']['combined_report']['firmware_xpath'])
firmware_hash = Hash.new
get_firmware_details firmware_list, firmware_hash
firmware_hash.each do |name, version|
  #puts "node attribute will be [hpsum][firmware_version][#{name}] = #{version}"
  node.set['hpsum']['firmware_version'][name] = version
end
