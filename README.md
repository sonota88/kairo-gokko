# kairo-gokko

![](https://cdn-ak.f.st-hatena.com/images/fotolife/s/sonota88/20200412/20200412074010.gif)

リレー式論理回路シミュレータを自作して1bit CPUまで動かした - memo88  
https://memo88.hatenablog.com/entry/2020/05/03/132253


## Demo

https://sonota88.github.io/kairo-gokko/pages/index.html


## Setup

Ubuntu 18.04 で `dxopal_sdl.rb` を使う場合

```
sudo apt install libsdl-sge libsdl-mixer1.2
```

## Run

```sh
# example
BROWSER=1 ./run.sh data/step_39.fodg 1
```

Open [http://localhost:7521/index.html](http://localhost:7521/index.html).
