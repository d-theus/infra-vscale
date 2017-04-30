module Infra
  module Commands
    module Servers
      class Delete < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          @existing_scalet =
            Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets.body
              .find { |s| s["name"] == @payload["name"] }
          validate!
          super("server:delete", @payload)
        end

        def invoke
          Vscale::Api::Client.new(Vscale::Api::TOKEN).delete_scalet(@existing_scalet.fetch("ctid"))
        end

        def validate!
          %w(name).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          fail "Cannot find scalet with name '#{@payload["name"]}'" unless @existing_scalet
        end
      end
    end
  end
end
