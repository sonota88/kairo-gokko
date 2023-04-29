require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/**/test_*.rb"]
end

files = [
  "main.rb",
  "view.rb",
  "circuit.rb"
]

file "main.js" => files do |t|
  sh %(./compile.sh compile main.rb > main.js)
  sh %(touch z_rake_flag)
end

task "build" => "main.js"

task :default => "build"
