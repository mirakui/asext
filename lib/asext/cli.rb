require 'thor'

module Asext
  module CLI
    class Config < Thor
      desc 'list', 'List launch-configurations'
      def list
        puts 'foo'
      end
    end

    class Root < Thor
      desc 'config [COMMAND]', 'Operate launch-configuration'
      subcommand 'config', Config
    end
  end
end
