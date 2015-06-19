# def foo
  puts Dir.chdir(File.dirname(__FILE__)) {
    `git rev-parse HEAD`
  }
# end

# puts foo
