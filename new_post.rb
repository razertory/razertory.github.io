require 'date'
require 'colorize'
require 'pathname'

file = ARGV[0].to_s

if file == ""
  puts "Please input file name!".red
  exit
end

content =
"---
layout: posts_by_category
categories: #{file}
title: #{file.capitalize}
permalink: /category/#{file}
---"

path = Pathname.new(File.dirname(__FILE__)).realpath
file_name = "#{path}/_posts/#{Date.today}-#{ARGV[0]}.md"

begin
  file = File.new(file_name, "w")
  file.write(content)
  puts "Your post `#{file_name}` has been created".green
rescue
   File.delete(file_name)
ensure
  file.close
end
