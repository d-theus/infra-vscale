require 'active_support/core_ext/hash/except'

module Infra
  class Info 
    def initialize(exclude_dynamic_info: false)
      @api = Vscale::Api::Client.new(Vscale::Api::TOKEN)
      @options = {
        exclude_dynamic_info: exclude_dynamic_info
      }
    end

    def call
        servers = Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets.body
        server_tags = Vscale::Api::Client.new(Vscale::Api::TOKEN).scalets_tags.body
        domains = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains.body
        domain_tags = Vscale::Api::Client.new(Vscale::Api::TOKEN).domains_tags.body
        domain_records = domains.flat_map { |d| Vscale::Api::Client.new(Vscale::Api::TOKEN).domain_records(d["id"]).body }

      @state = Infra::State.new(
        "servers" => servers,
        "server_tags" => server_tags,
        "domains" => domains,
        "domain_tags" => domain_tags,
        "domain_records" => domain_records,
      )

      exclude_dynamic_info if @options[:exclude_dynamic_info]
      @state
    end

    def self.call(options = {})
      new(**options).call
    end

    private

    def exclude_dynamic_info
      @state["servers"].map! do |hash|
        hash["make_from"] = hash.delete("made_from")
        hash.except("created", "public_address", "private_address", "hostname", "deleted", "ctid", "status", "active", "locked")
      end

      @state["domains"].map! do |hash|
        hash.except("change_date", "create_date", "id", "user_id")
      end

      puts @state["domain_records"].inspect
      @state["domain_records"].map! do |hash|
        hash.except("id")
      end
    end
  end
end
