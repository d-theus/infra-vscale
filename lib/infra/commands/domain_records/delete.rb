module Infra
  module Commands
    module DomainRecords
      class Delete < Base
        def initialize(payload)
          @payload = payload
          validate!
          super("domain_records:delete", @payload)
        end

        def invoke
        end

        def validate!
          %w(name type).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end

