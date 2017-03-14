actions = Dir.glob("../focus/lib/focus/actions/*").map do |file|
  File.expand_path file
end

actions.each { |file| require file }
