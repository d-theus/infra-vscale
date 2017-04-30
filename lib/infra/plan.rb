module Infra
  class Plan
    attr_reader :state_to, :state_from
    def initialize(state)
      @state_to = state
      @state_from = query

      @commands = []
    end

    def call
      infer_commands_for("servers")
      infer_commands_for("domains")
      infer_commands_for("server_tags")
      infer_commands_for("domain_tags")
      infer_commands_for("domain_records")

      @commands
    end

    def self.call(state)
      new(state).call
    end

    private

    def query
      state = Infra::Info.call(exclude_dynamic_info: true)
    end

    def infer_commands_for(entity)
      def entity.constantize
        self.to_s.split("_").map(&:capitalize).join
      end

      @commands.concat(send("#{entity}_modified").map do |e|
        Commands.const_get(entity.constantize).const_get('Update').new(e.to_h)
      end)

      @commands.concat(send("#{entity}_added").map do |e|
        Commands.const_get(entity.constantize).const_get('Create').new(e.to_h)
      end)

      @commands.concat(send("#{entity}_deleted").map do |e|
        Commands.const_get(entity.constantize).const_get('Delete').new(e.to_h)
      end)
    end

    %w(servers domains server_tags domain_tags domain_records).each do |pref|
      define_method "#{pref}_to" do
        state_to.fetch(pref, []).map(&OpenStruct.method(:new))
      end

      define_method "#{pref}_from" do
        state_from.fetch(pref, []).map(&OpenStruct.method(:new))
      end

      define_method pref do
        send("#{pref}_to") + send("#{pref}_from").uniq(&:name)
      end

      define_method "#{pref}_modified" do
        send(pref)
          .select { |p| send("#{pref}_to").map(&:name).include?(p.name) && send("#{pref}_from").map(&:name).include?(p.name) }
          .reject { |p| send("#{pref}_to").find { |pp| p.name == pp.name } == send("#{pref}_from").find { |pp| p.name == pp.name} }
          .reject { |p| send("#{pref}_from").include? p }
      end

      define_method "#{pref}_added" do
        send(pref).select { |p| send("#{pref}_to").map(&:name).include?(p.name) && !send("#{pref}_from").map(&:name).include?(p.name) }
      end

      define_method "#{pref}_deleted" do
        send(pref).select { |p| !send("#{pref}_to").map(&:name).include?(p.name) && send("#{pref}_from").map(&:name).include?(p.name) }
      end
    end
  end
end
