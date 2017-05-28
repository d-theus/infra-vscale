module Infra
  module Commands
    module Servers
      class Update < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          @server = Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets.body
            .find { |s| s["name"] == @payload["name"] }
          validate!
          super("server:update", @payload)
        end

        def invoke
          # does not work with current version of vscale-api
          Vscale::Api::Client.new(Vscale::Api::TOKEN).scalet_sshkeys(@server["id"], @payload)
        end

        def validate!
          %w(name keys make_from rplan location).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          fail "Cannot find scalet by name '#{@payload[:name]}'" unless @server
        end
      end
    end
  end
end
