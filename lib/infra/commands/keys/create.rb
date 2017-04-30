module Infra
  module Commands
    module Keys
      class Create < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("domain:create", @payload)
        end

        def invoke
        end

        def validate!
          %w(name key).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end

