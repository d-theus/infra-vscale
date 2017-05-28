module Infra
  module Commands
    module Domains
      class Delete < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          @domain = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains.body
            .find { |e| e["name"] == @payload["name"] }
          validate!
          super("domain:delete", @payload)
        end

        def invoke
          Vscale::Api::Client.new(Vscale::Api::TOKEN).remove_domain(@domain["id"])
        end

        def validate!
          %w(name).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          fail "Cannot find domain by name '#{@payload[:name]}'" unless @domain
        end
      end
    end
  end
end
