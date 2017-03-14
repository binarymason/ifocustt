utils = Dir.glob("../focus/lib/focus/utils/*").map do |file|
  File.expand_path file
end

utils.each { |file| require file }
