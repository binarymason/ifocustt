actions = Dir.glob("#{Focus.root}/lib/focus/actions/*").map do |file|
  File.expand_path file
end

actions.each { |file| require file }
