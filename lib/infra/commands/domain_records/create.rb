module Infra
  module Commands
    module DomainRecords
      class Create < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("domain_records:create", @payload)
        end

        def invoke
        end

        def validate!
          %w(name type ttl).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end
