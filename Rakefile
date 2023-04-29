files = [
  "main.rb",
  "view.rb",
  "circuit.rb"
]

file "main.js" => files do |t|
  sh %(./compile.sh compile main.rb > main.js)
  sh %(touch z_rake_flag)
end

task :default => "main.js"
