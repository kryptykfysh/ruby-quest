# encoding: UTF-8

require 'eventmachine'
require 'socket'

module RubyQuest
  class Server < EM::Connection
    include Logging
    @connected_clients = []

    attr_accessor :character
    attr_accessor :status

    class << self
      attr_reader :connected_clients
    end

    def post_init
      @character = nil
      @status = {}
      
      logger.info 'A client has connected.'
      # ask_username
      login
    end

    def unbind
      self.class.connected_clients.delete(self)
      logger.info "[info] #{@character.name} has disconnected." if entered_username?
    end

    # def receive_data(data)
    #   if entered_username?
    #     handle_chat_message(data.strip)
    #   else
    #     handle_username(data.strip)
    #   end
    # end

    def other_peers
      self.class.connected_clients.reject { |c| self == c }
    end

    #
    # Username handling
    #

    def entered_username?
      !@username.nil? && !@username.empty?
    end

    def handle_username(input)
      if input.empty?
        send_line("Blank usernames are not allowed. Try again.")
        ask_username
      else
        @username = input
        self.class.connected_clients.push(self)
        self.other_peers.each { |c| c.send_data("#{@username} has joined the room\n") }
        puts "#{@username} has joined"

        self.send_line("[info] Ohai, #{@username}")
      end
    end

    def ask_username
      self.send_line("[info] Enter your username:")
    end

    #
    # Character handling
    #

    def login
      self.send_line("[login] Login with 'connect character password'" )
    end

    def logged_in?
      !self.character.nil? && !self.character.name.empty?
    end

    def receive_data(data)
      login_regex = /\Aconnect\s+(?<name>\w+)\s+(?<password>\w+)\z/i
      if logged_in?
        handle_chat_message(data.strip)
      elsif self.status[:confirm_character_creation]
        if data.strip.downcase == 'y'
          character = Character.create(
            name:       status[:confirm_character_creation][:name],
            password:   status[:confirm_character_creation][:password],
            connection: self
          )
          character.connection = self
          self.character = character
          self.class.connected_clients << self
          logger.info "#{self.character.name.capitalize} connected from " \
            "#{Socket.unpack_sockaddr_in(get_peername)[1]}"
          self.send_line "Welcome, #{character.name.capitalize}!"
        else
          self.login
        end
        self.status.delete(:confirm_character_creation)
      elsif data.strip =~ login_regex
        matches = data.strip.match(login_regex)
        login_result = Character.login(
          connection: self,
          name: matches[:name],
          password: matches[:password]
        )
        if login_result          
          self.class.connected_clients << self
          self.character = Character.find(login_result)
          logger.info "#{self.character.name.capitalize} connected from " \
            "#{Socket.unpack_sockaddr_in(get_peername)[1]}"
        end
      else        
        login
      end
    end

    #
    # Message handling
    #

    def handle_chat_message(msg)
      if command?(msg)
        self.handle_command(msg)
      else
        self.announce(msg, "#{@character.name.capitalize}:")
      end
    end


    #
    # Commands handling
    #

    def command?(input)
      input =~ /exit$/i
    end

    def handle_command(cmd)
      case cmd
      when /exit$/i   then self.close_connection
      end
    end

    #
    # Helpers
    #

    def announce(msg = nil, prefix = "[chat server]")
      self.class.connected_clients.each { |c| c.send_line("#{prefix} #{msg}") } unless msg.empty?
    end

    def other_peers
      self.class.connected_clients.reject { |c| self == c }
    end

    def send_line(line)
      self.send_data("#{line}\n")
    end
  end
end
