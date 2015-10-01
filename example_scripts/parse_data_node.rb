#!/usr/bin/ruby

require 'nokogiri'

# Read two arguements off CMD line. First arguement is file to be read in.
# Second arguement is a XPATH double tag search string i.e. "//value//value2 | //value3"...

xmlfile = File.open(ARGV[0], "r")
value = ARGV[1]

@doc = Nokogiri::XML(File.open(xmlfile))
list = @doc.xpath(value)

# Format the order of values - in this case the driver (value3) is sourced after the version (//value//value2)
# The following switches that order around.
# The ".text" removes the tag value being sourced.

# Find the length of the array and remove the last value - arrays start at 0
iteration = list.length - 1
locale = 0

# Run through array two values at a time, and switch order.
until locale > iteration do
  print list[locale += 1].text,"   ",list[locale -= 1].text,"\n"
  locale += 2
end
