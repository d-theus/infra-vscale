require 'yaml'
require 'forwardable'

module Infra
  class State
    extend Forwardable
    extend Enumerable

    def initialize(hash)
      hash = hash.with_indifferent_access

      hash[:server_tags] = extract_server_tags(hash)
      hash[:domain_tags] = extract_domain_tags(hash)
      hash[:domain_records] = extract_domain_records(hash)
      normalize_ssh_keys(hash)

      @hash = {
        servers: hash.fetch(:servers, []),
        domains: hash.fetch(:domains, []),
        server_tags: hash.fetch(:server_tags, []),
        domain_tags: hash.fetch(:domain_tags, []),
        domain_records: hash.fetch(:domain_records, []),
      }.with_indifferent_access
    end

    def self.load(file)
      new(YAML.load(File.read(file)))
    end

    def_delegators :@hash, :[], :fetch, :each

    private

    def extract_server_tags(hash)
      hash.fetch("servers", []).reduce({}) do |acc,e|
        tags =
          e.delete("tags").map { |t| t["server_names"] ||= []; t["server_names"].push e["name"]; t }
        tags.each do |t|
          acc[t["name"]] ||= []
          acc[t["name"]] |= t["server_names"]
        end
        acc
      end.map { |tag, names| { "name" => tag, "server_names" => names.to_set }}
    end

    def extract_domain_tags(hash)
      hash.fetch("domains", []).reduce({}) do |acc,e|
        tags =
          e.delete("tags").map do |t|
          if t.is_a? Hash
            t
          else
            hash.fetch("domain_tags", []).find { |tt| tt["id"] == t }
          end
          end.map do |t|
            t["domain_names"] ||= []
            t["domain_names"].push e["name"]
            t
          end
        tags.each do |t|
          acc[t["name"]] ||= []
          acc[t["name"]] |= t["domain_names"]
        end
        acc
      end.map { |tag, names| { "name" => tag, "domain_names" => names.to_set }}
    end

    def extract_domain_records(hash)
      hash.fetch "domain_records" do
        hash.fetch(:domains, []).reduce({}) do |acc, dom|
          acc[dom["name"]] ||= []
          records = dom.delete("records").map { |r| r["domain"] = dom["name"]; r }
          acc[dom["name"]] |= Array(records)
          acc
        end.values.flatten.uniq
      end
    end

    def normalize_ssh_keys(hash)
      exising_keys = Vscale::Api::Client.new(Vscale::Api::TOKEN)
        .sshkeys.body.map(&OpenStruct.method(:new))
      hash.fetch(:servers, []).each do |srv|
        srv["keys"].map! do |sshkey|
          exising_key = exising_keys.find { |k| k.name == sshkey["name"] } or
            fail "Cannot find ssh key named '#{sshkey[:name]}'"
          exising_key.id 
        end
      end
    end
  end
end
