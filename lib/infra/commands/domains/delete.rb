module Infra
  module Commands
    module Domains
      class Delete < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("domain:delete", @payload)
        end

        def invoke
          Vscale::Api::Client.new(Vscale::Api::TOKEN).remove_domain(@payload)
        end

        def validate!
          %w(id name).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end
