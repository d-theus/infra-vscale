module Infra
  module Commands
    module DomainRecords
      class Update < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("domain_records:update", @payload)
        end

        def invoke
          domain = 
            Vscale::Api::Client.new(Vscale::Api::TOKEN).domains.body
            .find { |e| e["name"] == @payload.fetch(:domain) }
          fail "Cannot find domain by name '#{@payload[:domain]}'" unless domain
          domain = domain.with_indifferent_access

          record = Vscale::Api::Client.new(Vscale::Api::TOKEN).domain_records(domain["id"]).body
            .find { |e| [e["name"], e["type"]] == [@payload["name"], @payload["type"]] }
          fail "Cannot find domain record by name:type '#{@payload[:name]}:#{@payload[:type]}'" unless record

          if @payload.values.any? { |e| e =~ /<%=.*%>/ }
            context_class = Struct.new(:servers, :domains) do
              def get_binding
                binding
              end
            end
            context = context_class.new
            context.servers = Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets.body.map(&OpenStruct.method(:new)).map { |e| [e.name, e] }.to_h
            context.domains = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains.body.map(&OpenStruct.method(:new)).map { |e| [e.name, e] }.to_h
            @payload.each do |k, v|
              @payload[k] = ERB.new(v).result(context.get_binding) if v =~ /<%=.*%>/
            end

          Vscale::Api::Client.new(Vscale::Api::TOKEN).remove_domain_record(domain["id"], record["id"])
          Vscale::Api::Client.new(Vscale::Api::TOKEN).add_domain_record(domain["id"], @payload)
          end
        end

        def validate!
          %w(name type ttl).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end
