module Infra
  module Commands
    module ServerTags
      class Create < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("server_tags:create", @payload)
        end

        def invoke
          existing_scalets = Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets.body
          @payload["scalets"] = []
          @payload.delete("server_names").each do |sname|
            @payload["scalets"] << existing_scalets.find { |s| s["name"] == sname }["ctid"] or
              fail "Cannot find existing scalet with name '#{sname}'"
          end

          Vscale::Api::Client.new(Vscale::Api::TOKEN).add_scalet_tag(@payload)
        end

        def validate!
          %w(name server_names).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end

