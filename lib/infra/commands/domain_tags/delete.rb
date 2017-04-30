module Infra
  module Commands
    module DomainTags
      class Delete < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("domain_tag:delete", @payload)
        end

        def invoke
          Vscale::Api::Client.new(Vscale::Api::TOKEN).remove_domain_tag(@payload)
        end

        def validate!
          %w(name).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          fail "Cannot find domain tag with name '#{@payload[:name]}'" unless Vscale::Api::Client.new(Vscale::Api::TOKEN)
            .domains_tags.body.any? { |s| s["name"] == @payload[:name]}
        end
      end
    end
  end
end


