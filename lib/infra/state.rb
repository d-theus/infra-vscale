require 'yaml'
require 'forwardable'

module Infra
  class State
    extend Forwardable
    extend Enumerable

    def initialize(hash)
      hash = hash.with_indifferent_access

      hash[:server_tags] = extract_tags(hash, :server)
      hash[:domain_tags] = extract_tags(hash, :domain)
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

    def extract_tags(hash, scope)
      hash.fetch("#{scope}s", []).reduce({}) do |acc,e|
        tags =
          e.delete("tags").map { |t| t["#{scope}_names"] ||= []; t["#{scope}_names"].push e["name"]; t }
        tags.each do |t|
          acc[t["name"]] ||= []
          acc[t["name"]] |= t["#{scope}_names"]
        end
        acc
      end.map { |tag, names| { "name" => tag, "#{scope}_names" => names.to_set }}
    end

    def extract_domain_records(hash)
      hash.fetch(:domains, []).reduce({}) do |acc, dom|
        acc[dom["name"]] ||= []
        acc[dom["name"]] |= Array(dom.delete("records")).map { |r| r["name"] = dom["name"]; r }
        acc
      end.values.flatten.uniq
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
