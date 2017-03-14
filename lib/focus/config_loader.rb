module Focus
  class ConfigLoader
    class << self
      def load(config)
        YAML.load_file(config_file)[config]
      end

      private

      def config_file
        project_file = "./.focus.yml"
        home_file    = "#{ENV['HOME']}/.focus.yml"
        default_file = "#{Focus.root}/config/default.yml"

        if File.exist?(project_file)
          project_file
        elsif File.exist?(home_file)
          home_file
        else
          default_file
        end
      end
    end
  end
end
