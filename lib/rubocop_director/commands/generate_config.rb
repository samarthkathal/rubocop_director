require "dry/monads"

module RubocopDirector
  module Commands
    class GenerateConfig
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:run)

      RUBOCOP_TODO = ".rubocop_todo.yml"

      def run
        todo = yield load_config

        weights = todo.keys.each_with_object({}).each do |cop, acc|
          acc.merge!(cop => 1)
        end

        File.write(CONFIG_NAME, {
          "update_weight" => 1,
          "default_cop_weight" => 1,
          "weights" => weights
        }.to_yaml)

        Success("Config generated")
      end

      private

      def load_config
        if File.file?(CONFIG_NAME)
          puts("#{CONFIG_NAME} already exists, do you want to override it? (y, n)")

          return Failure("previous version of #{CONFIG_NAME} was preserved.") unless $stdin.gets.chomp == "y"
        end

        Success(YAML.load_file(RUBOCOP_TODO))
      rescue Errno::ENOENT
        Failure("#{RUBOCOP_TODO} not found, generate it using `rubocop --regenerate-todo`")
      end
    end
  end
end
