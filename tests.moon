package.path = "?.lua;?/init.lua;#{package.path}"
ffi = assert require "ffi"
sss = assert require "sss"


testing = (...) -> print "[testing]", ...


try = (t) ->
    ok, err = pcall ->
        if t.catch
            xpcall(t.do, t.catch)
        else
            t.do!
    t.finally! if t.finally
    error err if not ok


--------------------------------------------------------------------------------
do  -- SOCK
    testing "sss.SOCK"
    assert (tostring value)\match"^cdata<int>" for _, value in pairs sss.SOCK
    assert sss.SOCK.stream
    assert sss.SOCK.dgram
    assert sss.SOCK.raw


--------------------------------------------------------------------------------
do  -- AF
    testing "sss.AF"
    assert (tostring value)\match"^cdata<unsigned char>" for _, value in pairs sss.AF
    assert sss.AF.unspec
    assert sss.AF.local
    assert sss.AF.inet
    assert sss.AF.inet6
    assert sss.AF.ipx
    assert sss.AF.netbios


--------------------------------------------------------------------------------
do  -- SO
    testing "sss.SO"
    assert (tostring value)\match"^cdata<int>" for _, value in pairs sss.SO


--------------------------------------------------------------------------------
do  -- C address
    testing "sss.tocaddress"
    address = sss.tocaddress
        host: "127.0.0.1"
        port: 32000
    assert (tostring address)\match "^cdata<struct "
    assert (ffi.string address.host) == "127.0.0.1"
    assert (tonumber address.port) == 32000

    testing "sss.toladdress"
    address = sss.toladdress address
    assert (type address) == "table"
    assert address.host == "127.0.0.1"
    assert address.port == 32000


--------------------------------------------------------------------------------
do  -- socket instantiation
    testing "sss.socket: default parameters"
    s = sss.socket!
    try
        do: ->
            assert (tostring s)\match "^cdata<struct "
            assert (type s.sid) == "number"
            assert s.domain == sss.AF.inet
            assert s.type == sss.SOCK.stream
            assert s.protocol == 0
        finally: ->
            s\close!

    testing "sss.socket: local socket"
    s = sss.socket sss.AF.local, sss.SOCK.raw
    try
        do: ->
            assert (tostring s)\match "^cdata<struct "
            assert (type s.sid) == "number"
            assert s.domain == sss.AF.local
            assert s.type == sss.SOCK.raw
            assert s.protocol == 0
        finally: ->
            s\close!

    testing "sss.socket: udp"
    s = sss.socket sss.AF.inet, sss.SOCK.dgram, "udp"
    try
        do: ->
            assert (tostring s)\match "^cdata<struct "
            assert (type s.sid) == "number"
            assert s.domain == sss.AF.inet
            assert s.type == sss.SOCK.dgram
            assert (type s.protocol) == "number"
            assert s.protocol > 0
        finally: ->
            s\close!


--------------------------------------------------------------------------------
do  -- socket methods
    testing "sss.socket: main methods"
    s = sss.socket!
    try
        do: ->
            assert s.connect
            assert s.bind
            assert s.listen
            assert s.accept
            assert s.receive
            assert s.send
            assert s.recv
            assert s.sendto
            assert s.settimeout
            assert s.gettimeout
        finally: ->
            s\close!
            assert s.sid == 0

    testing "sss.socket: reuseaddr"
    s = sss.socket!
    try
        do: ->
            assert (s\getsockopt sss.SO.reuseaddr) == 0
            s\setsockopt sss.SO.reuseaddr, 1
            assert (s\getsockopt sss.SO.reuseaddr) == 1
        finally: ->
            s\close!


--------------------------------------------------------------------------------
print "all tests have passed"
