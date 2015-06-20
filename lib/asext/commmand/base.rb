module Asext
  module Command
    class Base
      attr_accessor :api

      def initialize(api)
        @api = api
      end
    end
  end
end
