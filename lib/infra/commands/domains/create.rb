module Infra
  module Commands
    module Domains
      class Create < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("domain:create", @payload)
        end

        def invoke
          Vscale::Api::Client.new(Vscale::Api::TOKEN).add_domain(@payload)
        end

        def validate!
          %w(name).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end
