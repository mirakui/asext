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

    def clone_launch_configuration(src_name, dst_name, override_opts={})
      conf = describe_launch_configurations(launch_configuration_names: [src_name]).first
      [:launch_configuration_arn, :created_time].each {|x| conf.delete x }
      conf.delete_if {|k,v| v == '' }
      conf[:launch_configuration_name] = dst_name
      conf.merge! override_opts

      create_launch_configuration conf
    end
  end
end
