module Infra
  class Plan
    attr_reader :state_to, :state_from
    def initialize(state)
      @state_to = state
      @state_from = query

      @stages = []
    end

    def call
      @stages.push(
        name: 'servers',
        commands: infer_commands_for("servers")
      )
      @stages.push(
        name: 'domains',
        commands: infer_commands_for("domains")
      )
      @stages.push(
        name: 'tags',
        commands:
          infer_commands_for("server_tags") +
          infer_commands_for("domain_tags"),
      )
      @stages.push(
        name: 'domain_records',
        commands: infer_commands_for("domain_records")
      )
      @stages.push(
        name: 'ptr_records',
        commands: infer_commands_for("ptr")
      )

      @stages.map(&OpenStruct.method(:new))
    end

    def self.call(state)
      new(state).call
    end

    private

    # TODO: query_static + query_dynamic
    #       then use query_dynamic state
    #       to interpolate latter stage
    #       fields
    def query
      state = Infra::Info.call(exclude_dynamic_info: true)
    end

    def infer_commands_for(entity)
      def entity.constantize
        self.to_s.split("_").map(&:capitalize).join
      end

      def entity.keys
        { servers: [:name], domains: [:name], server_tags: [:name], domain_tags: [:name], domain_records: [:name, :type], ptr: [:content] }
          .fetch(self.to_sym)
      end

      m = send("#{entity}_modified", entity.keys).map do |e|
        Commands.const_get(entity.constantize).const_get('Update').new(e.to_h)
      end

      a = send("#{entity}_added", entity.keys).map do |e|
        Commands.const_get(entity.constantize).const_get('Create').new(e.to_h)
      end

      d = send("#{entity}_deleted", entity.keys).map do |e|
        Commands.const_get(entity.constantize).const_get('Delete').new(e.to_h)
      end

      m + a + d
    end

    %w(servers domains server_tags domain_tags domain_records ptr).each do |pref|
      # TODO: FinderStruct < OpenStruct ??
      define_method "#{pref}_to" do
        records = state_to.fetch(pref, []).map(&OpenStruct.method(:new))
        def records.find_by_name(name)
          find { |r| r.name == name }
        end
        def records.find_by(hash)
          find { |r| hash.all? { |k, v| r.public_send(k) == v } }
        end
        records
      end

      define_method "#{pref}_from" do
        records = state_from.fetch(pref, []).map(&OpenStruct.method(:new))
        def records.find_by_name(name)
          find { |r| r.name == name }
        end
        def records.find_by(hash)
          find { |r| hash.all? { |k, v| r.public_send(k) == v } }
        end
        records
      end

      define_method pref do
        send("#{pref}_to") + send("#{pref}_from").uniq(&:name)
      end

      define_method "#{pref}_modified" do |fields = [:name]|
        send(pref)
          .select do |p|
            q = fields.zip(fields.map { |ff| p.public_send(ff) })
            to = send("#{pref}_to").find_by(q)
            from = send("#{pref}_from").find_by(q)
            !!to && !!from && to != from
          end
          .reject { |p| send("#{pref}_from").include? p }
      end

      define_method "#{pref}_added" do |fields = [:name]|
        send(pref).select do |p|
          q = fields.zip(fields.map { |ff| p.public_send(ff) })
          to = send("#{pref}_to").find_by(q)
          from = send("#{pref}_from").find_by(q)
          !!to && !from
      end
      end

      define_method "#{pref}_deleted" do |fields = [:name]|
        send(pref).select do |p|
          q = fields.zip(fields.map { |ff| p.public_send(ff) })
          to = send("#{pref}_to").find_by(q)
          from = send("#{pref}_from").find_by(q)
          !to && !!from
      end
      end
    end
  end
end
