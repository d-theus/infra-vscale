module Infra
  module Commands
    module DomainTags
      class Delete < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          @tag = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains_tags.body
            .find { |e| e["name"] == @payload["name"] }
          validate!
          super("domain_tag:delete", @payload)
        end

        def invoke
          Vscale::Api::Client.new(Vscale::Api::TOKEN).remove_domains_tag(@tag["id"])
        end

        def validate!
          %w(name).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          fail "Cannot find domain tag with name '#{@payload[:name]}'" unless Vscale::Api::Client.new(Vscale::Api::TOKEN)
            .domains_tags.body.any? { |s| s["name"] == @payload[:name]}

          fail "Cannot find tag with name '#{@payload[:name]}'" unless @tag
        end
      end
    end
  end
end


