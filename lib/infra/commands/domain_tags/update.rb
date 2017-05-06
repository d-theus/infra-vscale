module Infra
  module Commands
    module DomainTags
      class Update < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          tags = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains_tags.body
          @existing_tag = tags.find { |t| t["name"] == @payload["name"]}
          validate!
          super("server_tags:update", @payload)
        end

        def invoke
          existing_domains = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains.body
          @payload["domains"] = []
          @payload.delete("domain_names").each do |sname|
            @payload["domains"] << existing_domains.find { |s| s["name"] == sname }["ctid"] or
              fail "Cannot find existing domain with name '#{sname}'"
          end

          Vscale::Api::Client.new(Vscale::Api::TOKEN).update_domain_tag(@existing_tag["id"], @payload)
        end

        def validate!
          %w(name server_names).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          @existing_tag or
            fail "Cannot find existing domain tag with name '#{@payload["name"]}'"
        end
      end
    end
  end
end


