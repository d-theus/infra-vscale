module Infra
  class Images
    def call
      Vscale::Api::Client.new(Vscale::Api::TOKEN).images.body
    end

    def self.call
      new.call
    end
  end
end
