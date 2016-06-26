require 'bundler'
Bundler.setup
require File.expand_path(File.join('..','app'), __FILE__)
run Api::Application
