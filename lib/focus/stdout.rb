module Focus
  class STDOUT
    class << self
      def puts(*args)
        ::STDOUT.puts args
      end

      def debug_output(*args)
        ::STDOUT.puts args if $DEBUG
      end
    end
  end
end
