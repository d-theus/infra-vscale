module Infra
  module Commands
    module DomainRecords
      class Create < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("domain_records:create", @payload)
        end

        def invoke
          domain = 
            Vscale::Api::Client.new(Vscale::Api::TOKEN).domains.body
            .find { |e| e["name"] == @payload.fetch(:domain) }
          fail "Cannot find domain by name '#{@payload[:domain]}'" unless domain
          @payload.delete(:domain)
          domain = domain.with_indifferent_access

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
