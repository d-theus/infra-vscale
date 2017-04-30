module Infra
  module Commands
    module ServerTags
      class Delete < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          @existing_tag = Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets_tags.body.find { |s| s["name"] == @payload[:name] }
          validate!
          super("server_tags:delete", @payload)
        end

        def invoke
          Vscale::Api::Client.new(Vscale::Api::TOKEN).remove_scalet_tag(@existing_tag.fetch("id"))
        end

        def validate!
          %w(name).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          fail "Cannot find server tag with name '#{@payload[:name]}'" unless @existing_tag
        end
      end
    end
  end
end

