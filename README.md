# LuaJIT-powered Simple Stupid Socket

A reimplementation of [SSS](https://bitbucket.org/cacilhas/sss) powered by
[MoonScript](http://moonscript.org/) and [LuaJIT](http://luajit.org).


## Install

```
sh$ make
sh$ make test
sh$ sudo make install
```

Before `make install`, you can check if it’s ok by running:

```
sh$ make echoserver
```

And:

```
sh$ telnet localhost 32000
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
test
test
Connection closed by foreign host.
sh$
```


## Use

```
#!moonscript

sss = assert require "sss"
socket = sss.socket!
```

The `socket` function receives three parameters:

1. domain: from `sss.AF` table, default `sss.AF.inet`
2. type: from `sss.SOCK` table, default `sss.SOCK.stream`
3. protocol: integer or string, see `/etc/protocols`, default 0

The socket object accepts the following messages:

* `socket.close!` – closes the socket.

* `socket.connect address` – connects to the address. The address can be:
	- a table with the keys `host` and `port`
	- an address object, got from `sss.tocaddress t`

* `socket.bind address` – binds to the address. Adress as above.

* `socket.listen backlog` – like C `listen` function.

* `socket.accept!` – accepts new connections, returns the client socket and the
  C address.

* `socket.receive!` – receives and returns one line from remote peer.

* `socket.recv n` – receives `n` bytes from remote peer. Default 1024.

* `socket.send data` – sends data to remote peer.

* `socket.sendto data, address` – like C `sendto` function.

* `socket.setopt name, value` – sets socket option, value must be a `cdata`.

* `socket.getopt name` – gets socket option value, returns
  `cdata<unsgined char[?]>` and the length in bytes.

* `socket.settimeout tmo` – sets the receiving and/or sending timeout. `tmo`
  can be a number, or a table containing the keys `send` and `receive`.


Another useful functions:

* `tocaddress addr` – converts a table to C address.
* `toladdress addr` – converts a C address to table.


### The tables

* `sss.AF`: contains the socket address families.
* `sss.SOCK`: contains the socket types.
* `sss.SO`: contains the socket options.

To see the content:

```
#!moonscript

table.foreach sss.AF, print
```


### The sample echo server

```
#!moonscript

#!/usr/bin/env moon

sss = assert require "sss"

s = with sss.socket!
    \reuseaddr!
    \bind
        host: "*"
        port: 32000
    \listen!

while true
    with s\accept!
        got = \receive!
        \send got
        \close!
```


## License

[The BSD 3-Clause License](http://opensource.org/licenses/BSD-3-Clause)

Copyright © 2015, Rodrigo Cacilhας \<batalema@cacilhas.info>

All rights reserved.


## Author

[ℜodrigo Arĥimedeς ℳontegasppa ℭacilhας](mailto:batalema@cacilhas.info)
