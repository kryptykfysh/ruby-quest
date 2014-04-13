require 'bcrypt'

module RubyQuest
  class Character < ActiveRecord::Base
    attr_accessor :password, :connection
    before_validation { self.name = self.name.downcase }
    before_save :encrypt_password
    validates :name, presence: true, uniqueness: { case_sensitive: false }

    def self.login(name:, password:, connection:)
      character = Character.find_by(name: name.downcase)
      if character
        if authenticates?(character: character, password: password)
          character.connection = connection
          character.connection.send_line "Welcome back, #{character.name.capitalize}!"
          return character.id
        else
          connection.send_line "Invalid credentials."
          connection.login
          return nil
        end
      else
        connection.send_line  "This character does not yet exist.\n" \
                              "Create it? (Y/N)"
        connection.status[:confirm_character_creation] = {
                              name:     name,
                              password: password
                            }
        return nil
      end
    end

    private

    def self.authenticates?(character:, password:)
      character.password_digest == BCrypt::Engine.hash_secret(
        password,
        character.password_salt
      )
    end

    def encrypt_password
      generate_password_salt if self.password_salt.nil?
      self.password_digest = BCrypt::Engine.hash_secret(
        self.password,
        self.password_salt
      )
    end

    def generate_password_salt
      self.password_salt = BCrypt::Engine.generate_salt
    end
  end
end
