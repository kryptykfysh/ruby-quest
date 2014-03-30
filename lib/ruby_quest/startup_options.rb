module RubyQuest
  require 'optparse'

  class StartupOptions
    def self.parse(args)
      # Set default values
      options = {}
      options['log_level'] = 'info'
      options['port_number'] = 10_000
      options['environment'] = 'development'

      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: ruby_quest.rb [options]'
        opts.separator ''
        opts.separator 'Specific options:'
        opts.separator ''

        opts.on('-l','--log-level [LEVEL]',
          %w[debug info warn error fatal unknown],
          'Select log level from (most to least):',
          '  debug, info, warn, error, fatal, unknown',
          'The default is :info') do |log_level|
          options['log_level'] = log_level
        end

        opts.on('-p', '--port N',
          Integer,
          'Port for server to listen on.',
          'Default is 10000') do |port|
          options['port_number'] = port
        end

        opts.on('-e', '--environment [ENVIRONMENT]',
          %w[development production test],
          'Default environment is production,',
          'but if you want, there is also a ',
          'test or development environment.') do |environment|
          options['environment'] = environment
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end

      opt_parser.parse!(args)
      options
    end
  end
end