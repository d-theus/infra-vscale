module Infra
  module Commands
    module DomainTags
      class Create < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("domain_tag:create", @payload)
        end

        def invoke
          existing_domains = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains.body
          @payload["domains"] = []
          @payload.delete("domain_names").each do |sname|
            @payload["domains"] << existing_domains.find { |s| s["name"] == sname } or
              fail "Cannot find existing domain with name '#{sname}'"
            @payload["domains"].map! { |e| e["id"] }
          end

          Vscale::Api::Client.new(Vscale::Api::TOKEN).add_domains_tags(@payload)
        end

        def validate!
          %w(name domain_names).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end

