$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "focus/version"

Gem::Specification.new do |s|
  s.name = "ifocustt"
  s.version = Focus::VERSION
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.0.0"
  s.authors = ["John Mason"]
  s.description = <<-EOF
    If Focus, Then That.
    Do stuff when you need to focus.
  EOF
  s.executables = ["focus"]
  s.homepage = "http://github.com/binarymason/ifocustt"
  s.email = "binarymason@users.noreply.github.com"
  s.files = `git ls-files assets bin config lib LICENSE.txt README.me`.split
  s.licenses = ["MIT"]
  s.summary = "If Focus, Then That"

  s.add_runtime_dependency("httparty", "~> 0.14")
  s.add_runtime_dependency("tty", "~> 0.6.1")
  s.add_runtime_dependency("paint", "~> 2.0")
  s.add_runtime_dependency("dotenv", "~> 2.2")
  s.add_runtime_dependency("interactor", "~> 3.0")
end
