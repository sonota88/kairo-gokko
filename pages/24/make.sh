#!/bin/bash

print_file_list(){
  cat <<EOB
child_circuit.rb
circuit.rb
data.rb
drawer_dxopal.rb
main.rb
tuden.rb
unit.rb
view.rb
EOB
}

copy(){
  while read -r file; do
    cp "../../${file}" .
  done
}

print_file_list | copy

mv main.rb main.rb.orig
sed -e 's/click\.wav/\.\.\/click\.wav/' main.rb.orig > main.rb
rm main.rb.orig
