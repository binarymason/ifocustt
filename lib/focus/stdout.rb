module Focus
  class STDOUT
    class << self
      def puts_line(str, opts = { quiet: false })
        quiet = opts[:quiet]
        ::STDOUT.puts str unless quiet
      end

      def print_line(str, opts = { quiet: false })
        quiet = opts[:quiet]
        ::STDOUT.print str unless quiet
      end

      def step(string, opts = { quiet: false })
        quiet = opts[:quiet]
        print_line(Focus::Formatter.step(string), quiet: quiet)
        yield if block_given?
        puts_line Focus::Formatter.ok, quiet: quiet
      rescue FailedActionError, MissingConfiguration => error
        puts_line Focus::Formatter.error error.to_s
      end

      def title(string)
        puts
        puts "-" * 50
        puts string
        puts "-" * 50
      end

      def debug_output(str)
        ::STDOUT.puts str if $DEBUG
      end
    end
  end
end
