#!/usr/bin/env ruby
require 'rubygems'
require 'sequel'

opts = YAML.load_file 'db.yml'

db = Sequel.connect opts
puts db[:node].first.inspect
db[:node].update(:comment => 0)
