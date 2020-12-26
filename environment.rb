require 'rubygems'
require 'bundler/setup'

Bundler.setup(:default)

require 'pathname'
lib_path ||= File.expand_path('../lib', Pathname.new(__FILE__).realpath)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require 'camo/server'
