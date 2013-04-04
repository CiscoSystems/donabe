require 'yaml'
require 'json'

APP_CONFIG = YAML.load_file("#{Rails.root}/config/donabe.yml")[Rails.env]
APP_CONFIG['policy'] = JSON.parse( IO.read("#{Rails.root}/config/policy.json") ) 

puts APP_CONFIG
