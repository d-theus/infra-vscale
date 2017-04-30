module Infra
  module Commands
    module Servers
      class Create < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          @payload[:do_start] = true
          validate!
          super("server:create", @payload)
        end

        def invoke
          puts @payload.inspect
          Vscale::Api::Client.new(Vscale::Api::TOKEN).new_scalet(@payload)
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
