module Infra
  module Commands
    module ServerTags
      class Update < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          tags = Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets_tags.body
          @existing_tag = tags.find { |t| t["name"] == @payload["name"]}
          validate!
          super("server_tags:update", @payload)
        end

        def invoke
          existing_scalets = Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets.body
          @payload["scalets"] = []
          @payload.delete("server_names").each do |sname|
            @payload["scalets"] << existing_scalets.find { |s| s["name"] == sname }["ctid"] or
              fail "Cannot find existing scalet with name '#{sname}'"
          end

          Vscale::Api::Client.new(Vscale::Api::TOKEN).update_scalet_tag(@existing_tag["id"], @payload)
        end

        def validate!
          %w(name server_names).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          @existing_tag or
            fail "Cannot find existing scalet tag with name '#{@payload["name"]}'"
        end
      end
    end
  end
end

