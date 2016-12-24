export ^
local *
package.path = "?.lua;?/init.lua;#{package.path}"
unit = assert require "luaunit"
ffi = assert require "ffi"
sss = assert require "sss"


try = (t) ->
    ok, response = pcall -> if t.catch then xpcall t.do, t.catch else t.do!
    t.finally! if t.finally
    error response unless ok
    response


--------------------------------------------------------------------------------
TestSSS =

    test_socket: =>
        with unit
            .assertStrContains (tostring value), "cdata<int>" for _, value in pairs sss.SOCK
            .assertNotNil sss.SOCK.stream
            .assertNotNil sss.SOCK.dgram
            .assertNotNil sss.SOCK.raw

    test_af: =>
        with unit
            .assertStrContains (tostring value), "cdata<unsigned char>" for _, value in pairs sss.AF
            .assertNotNil sss.AF.unspec
            .assertNotNil sss.AF.local
            .assertNotNil sss.AF.inet
            .assertNotNil sss.AF.inet6
            .assertNotNil sss.AF.ipx
            .assertNotNil sss.AF.netbios

    test_so: =>
        unit.assertStrContains (tostring value), "cdata<int>" for _, value in pairs sss.SO

    test_caddress: =>
        address = sss.tocaddress
            host: "127.0.0.1"
            port: 32000
        with unit
            .assertStrContains (tostring address), "cdata<struct netaddress>"
            .assertEquals (ffi.string address.host), "127.0.0.1"
            .assertEquals (tonumber address.port), 32000

        address = sss.toladdress address
        with unit
            .assertEquals (type address), "table"
            .assertEquals address.host, "127.0.0.1"
            .assertEquals address.port, 32000


--------------------------------------------------------------------------------
TestSocket =

    test_socket_default_parameters: =>
        s = sss.socket!
        try
            do: ->
                with unit
                    .assertStrContains (tostring s), "cdata<struct socket_wrapper>"
                    .assertEquals (type s.sid), "number"
                    .assertEquals s.domain, tonumber sss.AF.inet
                    .assertEquals s.type, tonumber sss.SOCK.stream
                    .assertEquals s.protocol, 0
            finally: ->
                s\close!

    test_local_socket: =>
        s = sss.socket sss.AF.local, sss.SOCK.raw
        try
            do: ->
                with unit
                    .assertStrContains (tostring s), "cdata<struct socket_wrapper>"
                    .assertEquals (type s.sid), "number"
                    .assertEquals s.domain, tonumber sss.AF.local
                    .assertEquals s.type, tonumber sss.SOCK.raw
                    .assertEquals s.protocol, 0
            finally: ->
                s\close!

    test_udp: =>
        s = sss.socket sss.AF.inet, sss.SOCK.dgram, "udp"
        try
            do: ->
                with unit
                    .assertStrContains (tostring s), "cdata<struct socket_wrapper>"
                    .assertEquals (type s.sid), "number"
                    .assertEquals s.domain, tonumber sss.AF.inet
                    .assertEquals s.type, tonumber sss.SOCK.dgram
                    .assertEquals (type s.protocol), "number"
                    .assertTrue s.protocol > 0
            finally: ->
                s\close!

    test_socket_main_methods: =>
        s = sss.socket!
        try
            do: ->
                with aNotNil = unit.assertNotNil
                    aNotNil s.connect
                    aNotNil s.bind
                    aNotNil s.listen
                    aNotNil s.accept
                    aNotNil s.receive
                    aNotNil s.send
                    aNotNil s.recv
                    aNotNil s.sendto
                    aNotNil s.setopt
                    aNotNil s.getopt
                    aNotNil s.reuseaddr
                    aNotNil s.settimeout
                    aNotNil s.broadcast
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
