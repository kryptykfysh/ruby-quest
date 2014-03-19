# encoding: UTF-8

require 'eventmachine'

module RubyQuest
  class Server < EM::Connection
    include Logging
    @connected_clients = []

    attr_reader :username

    class << self
      attr_reader :connected_clients
    end

    def post_init
      @username = nil
      
      logger.info 'A client has connected.'
      ask_username
    end

    def unbind
      self.class.connected_clients.delete(self)
      logger.info "[info] #{@username} has disconnected." if entered_username?
    end

    def receive_data(data)
      if entered_username?
        handle_chat_message(data.strip)
      else
        handle_username(data.strip)
      end
    end

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
    # Message handling
    #

    def handle_chat_message(msg)
      if command?(msg)
        self.handle_command(msg)
      else
        self.announce(msg, "#{@username}:")
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
