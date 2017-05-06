module Infra
  module Commands
    module DomainRecords
      class Delete < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          @domain = 
            Vscale::Api::Client.new(Vscale::Api::TOKEN).domains.body
            .find { |e| e["name"] == @payload.delete(:name) }
            .with_indifferent_access
          @record = Vscale::Api::Client.new(Vscale::Api::TOKEN).domain_records.body
            .find { |e| [e["name"], e["type"]] == [@payload.fetch(:name), @payload.fetch(:type)] }
            .with_indifferent_access
          validate!
          super("domain_records:delete", @payload)
        end

        def invoke
          Vscale::Api::Client.new(Vscale::Api::TOKEN).remove_domain_record(@payload)
        end

        def validate!
          %w(name type).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end

          fail "Cannot find domain by name '#{@payload[:name]}'" unless @domain
          fail "Cannot find domain record by name-type '#{@payload[:name]}:#{@payload[:type]}'" unless @record[:id]
        end
      end
    end
  end
end

