# encoding: UTF-8

FactoryGirl.define do
  factory :character, class: RubyQuest::Character do
    name     'test_character'
    password 'password'
  end
end