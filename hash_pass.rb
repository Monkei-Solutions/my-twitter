require 'scrypt'
require 'yaml'
require 'securerandom'
require 'io/console'
require_relative 'helpers/twitter'

puts "Enter your username (screen_name)"
screen_name = gets.chomp

puts "Enter your pass to be hashed"
pass = STDIN.noecho(&:gets).chomp

salt = SCrypt::Engine.generate_salt(salt_size: 32)
hashed_pass = SCrypt::Engine.hash_secret(pass, salt, 512)

puts "SALT and HASHED_PASS will be copied inside config.yml (salt and hash respectively)"
puts "SALT: #{salt}"
puts "HASHED_PASS: #{hashed_pass}"

config = YAML::load_file('config.yml')
config['screen_name'] = screen_name
config['password']['salt_size'] = 32
config['password']['key_len'] = 512
config['password']['salt'] = salt
config['password']['hash'] = hashed_pass
# quietly update cookie secret token
config['cookie_key'] = SecureRandom.hex(32)
File.open('config.yml', 'w') {|f| f.write config.to_yaml }

puts "Fetching the first data, it might take sometime"
set_up = TwitterHelper::SetUp.new
set_up.authenticate(screen_name)
data_fetcher = TwitterHelper::DataFetcher.new(set_up.client, set_up.username)
puts "Fetching data from Twitter REST API"
data_fetcher.user_show
sleep(8)
data_fetcher.user_timeline

