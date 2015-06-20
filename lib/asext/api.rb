require 'logger'
require 'aws-sdk-core'

module Asext
  class Api
    def initialize
    end

    def as
      @as = ::Aws::AutoScaling::Client.new logger: Logger.new($stdout).tap{|l| l.level = Logger::DEBUG }
    end

    def describe_launch_configurations(opts=nil)
      as.describe_launch_configurations(opts).to_h[:launch_configurations]
    end

    def create_launch_configuration(opts)
      as.create_launch_configuration opts
    end

    def describe_auto_scaling_groups(opts=nil)
      as.describe_auto_scaling_groups(opts).to_h[:auto_scaling_groups]
    end

    def update_auto_scaling_group(opts)
      as.update_auto_scaling_group opts
    end

    def delete_launch_configuration(opts)
      as.delete_launch_configuration opts
    end

    def clone_launch_configuration(src_name, dst_name, override_opts={})
      conf = describe_launch_configurations(launch_configuration_names: [src_name]).first
      [:launch_configuration_arn, :created_time].each {|x| conf.delete x }
      conf.delete_if {|k,v| v == '' }
      conf[:launch_configuration_name] = dst_name
      conf.merge! override_opts

      create_launch_configuration conf
    end

    def update_auto_scaling_group_ami(group_name, image_id)
      grp = describe_auto_scaling_groups(auto_scaling_group_names: [group_name]).first
      src_conf_name = grp[:launch_configuration_name]
      dst_conf_name = config_name_from_group_name(group_name, image_id)
      clone_launch_configuration src_conf_name, dst_conf_name, image_id: image_id
      update_auto_scaling_group auto_scaling_group_name: group_name, launch_configuration_name: dst_conf_name
      delete_launch_configuration launch_configuration_name: src_conf_name if src_conf_name =~ /^#{group_name}_\d+_ami-\w+$/
      dst_conf_name
    end

    def config_name_from_group_name(group_name, image_id)
      "#{group_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}_#{image_id}"
    end
  end
end
