module Infra
  module Commands
    class Base < Struct.new(:type, :payload)
      attr_accessor :error

      def invoke
        raise NotImplementedError
      end

      def explain
        "Command[#{type}]:\n\
        #{payload.map { |k,v| sprintf "%15s: %s", k,v.inspect }.join("\n\t")}"
      end

      def error?
        !!error
      end

      def success?
        !error
      end
    end
  end
end
