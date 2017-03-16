module Focus
  module Utils
    class WebClient < Util
      class << self
        %i(get post).each do |action|
          define_method(action) do |url, opts = {}|
            HTTParty.send(action, url, opts)
          end
        end
      end
    end
  end
end
