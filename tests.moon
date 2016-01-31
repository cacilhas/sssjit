export ^
local *
package.path = "?.lua;?/init.lua;#{package.path}"
unit = assert require "luaunit"
ffi = assert require "ffi"
sss = assert require "sss"


try = (t) ->
    ok, response = pcall ->
        if t.catch
            xpcall(t.do, t.catch)
        else
            t.do!
    t.finally! if t.finally
    error response unless ok
    response


--------------------------------------------------------------------------------
TestSSS =

    test_socket: =>
        unit.assertStrContains (tostring value), "cdata<int>" for _, value in pairs sss.SOCK
        unit.assertNotNil sss.SOCK.stream
        unit.assertNotNil sss.SOCK.dgram
        unit.assertNotNil sss.SOCK.raw

    test_af: =>
        unit.assertStrContains (tostring value), "cdata<unsigned char>" for _, value in pairs sss.AF
        unit.assertNotNil sss.AF.unspec
        unit.assertNotNil sss.AF.local
        unit.assertNotNil sss.AF.inet
        unit.assertNotNil sss.AF.inet6
        unit.assertNotNil sss.AF.ipx
        unit.assertNotNil sss.AF.netbios

    test_so: =>
        unit.assertStrContains (tostring value), "cdata<int>" for _, value in pairs sss.SO

    test_caddress: =>
        address = sss.tocaddress
            host: "127.0.0.1"
            port: 32000
        unit.assertStrContains (tostring address), "cdata<struct netaddress>"
        unit.assertEquals (ffi.string address.host), "127.0.0.1"
        unit.assertEquals (tonumber address.port), 32000

        address = sss.toladdress address
        unit.assertEquals (type address), "table"
        unit.assertEquals address.host, "127.0.0.1"
        unit.assertEquals address.port, 32000


--------------------------------------------------------------------------------
TestSocket =

    test_socket_default_parameters: =>
        s = sss.socket!
        try
            do: ->
                unit.assertStrContains (tostring s), "cdata<struct socket_wrapper>"
                unit.assertEquals (type s.sid), "number"
                unit.assertEquals s.domain, tonumber sss.AF.inet
                unit.assertEquals s.type, tonumber sss.SOCK.stream
                unit.assertEquals s.protocol, 0
            finally: ->
                s\close!

    test_local_socket: =>
        s = sss.socket sss.AF.local, sss.SOCK.raw
        try
            do: ->
                unit.assertStrContains (tostring s), "cdata<struct socket_wrapper>"
                unit.assertEquals (type s.sid), "number"
                unit.assertEquals s.domain, tonumber sss.AF.local
                unit.assertEquals s.type, tonumber sss.SOCK.raw
                unit.assertEquals s.protocol, 0
            finally: ->
                s\close!

    test_udp: =>
        s = sss.socket sss.AF.inet, sss.SOCK.dgram, "udp"
        try
            do: ->
                unit.assertStrContains (tostring s), "cdata<struct socket_wrapper>"
                unit.assertEquals (type s.sid), "number"
                unit.assertEquals s.domain, tonumber sss.AF.inet
                unit.assertEquals s.type, tonumber sss.SOCK.dgram
                unit.assertEquals (type s.protocol), "number"
                unit.assertTrue s.protocol > 0
            finally: ->
                s\close!

    test_socket_main_methods: =>
        s = sss.socket!
        try
            do: ->
                unit.assertNotNil s.connect
                unit.assertNotNil s.bind
                unit.assertNotNil s.listen
                unit.assertNotNil s.accept
                unit.assertNotNil s.receive
                unit.assertNotNil s.send
                unit.assertNotNil s.recv
                unit.assertNotNil s.sendto
                unit.assertNotNil s.setopt
                unit.assertNotNil s.getopt
                unit.assertNotNil s.reuseaddr
                unit.assertNotNil s.settimeout
                unit.assertNotNil s.broadcast
            finally: ->
                s\close!
                assert s.sid == 0

    test_reuseaddr: =>
        s = sss.socket!
        try
            do: ->
                s\reuseaddr!
            finally: ->
                s\close!

    test_settimeout: =>
        s = sss.socket!
        try
            do: ->
                s\settimeout snd: 1.125, rcv: 5
            finally: ->
                s\close!

    test_broadcast: =>
        s = sss.socket sss.AF.inet, sss.SOCK.dgram, "udp"
        try
            do: ->
                s\broadcast!
            finally: ->
                s\close!

--------------------------------------------------------------------------------
os.exit unit.LuaUnit.run!
