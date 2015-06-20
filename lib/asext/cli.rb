require 'thor'
require 'asext/api'

module Asext
  module CLI
    class Config < Thor
      desc 'list', 'List launch-configurations'
      def list
        api = Asext::Api.new
        api.describe_launch_configurations.each do |conf|
          puts conf[:launch_configuration_name]
        end
      end

      desc 'change_ami <src_name> <dst_name> <image_id>', 'Clone launch-configuration and change image_id'
      def change_ami(src_name, dst_name, image_id)
        api = Asext::Api.new
        api.clone_launch_configuration src_name, dst_name, image_id: image_id
        conf = api.describe_launch_configurations(launch_configuration_names: [dst_name]).first
        puts "created: #{conf}"
      end
    end

    class Root < Thor
      desc 'config [COMMAND]', 'Operate launch-configuration'
      subcommand 'config', Config

      desc 'change_ami <as_group> <image_id>', 'Clone launch-configuration and change image_id'
      def change_ami(as_group, image_id)
        api = Asext::Api.new
        dst_conf = api.update_auto_scaling_group_ami as_group, image_id
        puts "rotated: #{dst_conf}"
      end
    end
  end
end
