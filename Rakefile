$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "focus/version"

desc "Open console with focus loaded"
task :console do
  exec "pry -r ./lib/focus.rb"
end

task c: :console # alias "c" for console
task default: :console
