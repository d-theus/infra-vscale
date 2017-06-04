module Infra
  module Commands
    module Ptr
      class Update < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("ptr:update", @payload)
        end

        def invoke
          ptr = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains_ptr.body
            .map(&OpenStruct.method(:new))
            .find { |ptr| ptr.content == @payload[:content] }
          fail "Cannot find ptr record by content '#{@payload[:content]}'" unless ptr

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

          end
          Vscale::Api::Client.new(Vscale::Api::TOKEN).update_ptr_id(ptr.id, @payload)
        end

        def validate!
          %w(ip content).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end
