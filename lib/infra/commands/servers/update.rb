module Infra
  module Commands
    module Servers
      class Update < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("server:update", @payload)
        end

        def invoke
        end

        def validate!
          %w(name keys make_from rplan location).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end
