require "optparse"
require "ostruct"
require "pp"

module Focus
  class Parser
    DEFAULT_VALUES = {
      minutes: 25,
      quiet:   true
    }.freeze

    class << self
      def parse(options)
        args = OpenStruct.new(DEFAULT_VALUES)
        parser = build_parser(args)
        parser.parse!(options)
        args
      end

      private

      def build_parser(args) # rubocop:disable MethodLength
        OptionParser.new do |opts|
          opts.banner = "Usage: focus [options]"

          opts.on("-d", "--daemonize", "Allow focus to be forked to the background") do
            args.daemonize = true
          end

          opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit

          end

          opts.on("-mMINUTES", "--minutes=MINUTES", "How many minutes to focus.") do |m|
            args.minutes = m

          end
          opts.on("-t", "--target=TARGET", "Specify what you are focusing on") do |t|
            raise ArgumentError, "#{t} is not a valid target name" if t =~ /^\d+(\.\d)?$/
            args.target = t
          end

          opts.on("--verbose", "Run focus with more verbose STDOUT") do
            args.quiet = false
          end

          opts.on("-v", "--version", "Prints version") do
            puts "ifocusst v-#{Focus::VERSION}"
            exit
          end
        end
      end
    end
  end

  class CLI
    class << self
      def run!(argv)
        options = Parser.parse(argv)
        StartFocusTime.call(options.to_h)
      end
    end
  end
end
