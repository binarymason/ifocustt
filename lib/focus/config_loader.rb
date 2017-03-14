module Focus
  class ConfigLoader
    class << self
      def load(config)
        YAML.load_file(config_file)[config]
      end

      private

      def config_file
        opts = {
          project_file:    "./.focus.yml",
          focus_repo_file: "#{Focus.root}/.focus.yml",
          home_file:       "#{ENV['HOME']}/.focus.yml",
          default_file:    "#{Focus.root}/config/default.yml"
        }

        opts.each do |_k, file|
          break file if exist?(file)
        end
      end

      def exist?(path)
        full_path = File.expand_path(path)
        File.exist?(full_path) || File.symlink?(full_path)
      end
    end
  end
end
