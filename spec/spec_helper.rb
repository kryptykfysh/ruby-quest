# encoding:UTF-8

ENV['ENVIRONMENT'] = 'test'

require 'ruby_quest'
require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

FactoryGirl.find_definitions
