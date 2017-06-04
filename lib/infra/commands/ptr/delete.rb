module Infra
  module Commands
    module Ptr
      class Delete < Base
        def initialize(payload)
          @payload = payload.with_indifferent_access
          validate!
          super("ptr:delete", @payload)
        end

        def invoke
          ptr = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains_ptr.body
            .map(&OpenStruct.method(:new))
            .find { |ptr| ptr.content == @payload[:content] }
          fail "Cannot find ptr record by content '#{@payload[:content]}'" unless ptr

          Vscale::Api::Client.new(Vscale::Api::TOKEN).update_domains_ptr(ptr.id)
        end

        def validate!
          %w(content).each do |key|
            fail ArgumentError, "Missing key: #{key}" unless @payload.key?(key)
          end
        end
      end
    end
  end
end
