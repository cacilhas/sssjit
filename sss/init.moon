ffi = assert require "ffi"
import floor from math

local *


_VERSION = "1.0b2"
_DESCRIPTION = "LuaJIT-powered Simple Stupid Socket"
_AUTHOR = "ℜodrigo Arĥimedeς ℳontegasppa ℭacilhας <batalema@cacilhas.info>"
_LICENSE = "BSD-3 Clausule"


assert require "sss.#{ffi.os}"

C = ffi.C


--------------------------------------------------------------------------------
INADDR =
    any:       ffi.cast "in_addr_t", C.INADDR_ANY
    broadcast: ffi.cast "in_addr_t", C.INADDR_BROADCAST
    loopback:  ffi.cast "in_addr_t", C.INADDR_LOOPBACK


SOL_SOCKET = ffi.cast "int", C.SOL_SOCKET


SOCK =
    stream:    ffi.cast "int", C.SOCK_STREAM
    dgram:     ffi.cast "int", C.SOCK_DGRAM
    raw:       ffi.cast "int", C.SOCK_RAW
    rdm:       ffi.cast "int", C.SOCK_RDM
    seqpacket: ffi.cast "int", C.SOCK_SEQPACKET


AF =
    unspec:    ffi.cast "sa_family_t", C.AF_UNSPEC
    unix:      ffi.cast "sa_family_t", C.AF_UNIX
    local:     ffi.cast "sa_family_t", C.AF_LOCAL
    inet:      ffi.cast "sa_family_t", C.AF_INET
    inet6:     ffi.cast "sa_family_t", C.AF_INET6
    ipx:       ffi.cast "sa_family_t", C.AF_IPX
    appletalk: ffi.cast "sa_family_t", C.AF_APPLETALK
    netbios:   ffi.cast "sa_family_t", C.AF_NETBIOS
    key:       ffi.cast "sa_family_t", C.AF_KEY
    route:     ffi.cast "sa_family_t", C.AF_ROUTE
    ieee8021:  ffi.cast "sa_family_t", C.AF_IEEE8021


SO =
    debug:     ffi.cast "int", C.SO_DEBUG
    reuseaddr: ffi.cast "int", C.SO_REUSEADDR
    type:      ffi.cast "int", C.SO_TYPE
    error:     ffi.cast "int", C.SO_ERROR
    dontroute: ffi.cast "int", C.SO_DONTROUTE
    broadcast: ffi.cast "int", C.SO_BROADCAST
    sndbuf:    ffi.cast "int", C.SO_SNDBUF
    rcvbuf:    ffi.cast "int", C.SO_RCVBUF
    keepalive: ffi.cast "int", C.SO_KEEPALIVE
    oobinline: ffi.cast "int", C.SO_OOBINLINE
    no_check:  ffi.cast "int", C.SO_NO_CHECK
    priority:  ffi.cast "int", C.SO_PRIORITY
    bsdcompat: ffi.cast "int", C.SO_BSDCOMPAT
    linger:    ffi.cast "int", C.SO_LINGER
    reuseport: ffi.cast "int", C.SO_REUSEPORT
    passcred:  ffi.cast "int", C.SO_PASSCRED
    peercred:  ffi.cast "int", C.SO_PEERCRED
    sndlowat:  ffi.cast "int", C.SO_SNDLOWAT
    rcvlowat:  ffi.cast "int", C.SO_RCVLOWAT
    sndtimeo:  ffi.cast "int", C.SO_SNDTIMEO
    rcvtimeo:  ffi.cast "int", C.SO_RCVTIMEO


--------------------------------------------------------------------------------
getprotobyname = (name) ->
    pe_p = C.getprotobyname name
    if pe_p == nil then nil else pe_p[0].p_proto


getsockaddr = (domain, address) ->
    address = tocaddress address if (type address) == "table"
    sockaddr = nil

    if domain == AF.inet
        sockaddr = ffi.new "struct sockaddr_in[?]", 1
        sockaddr[0].sin_family = AF.inet

        switch ffi.string address.host
            when "0.0.0.0"
                sockaddr[0].sin_addr.s_addr = INADDR.any
            when "*"
                sockaddr[0].sin_addr.s_addr = INADDR.any
            when "broadcast"
                sockaddr[0].sin_addr.s_addr = INADDR.broadcast
            when "loopback"
                sockaddr[0].sin_addr.s_addr = INADDR.loopback
            else
                C.inet_aton address.host, sockaddr[0].sin_addr

        sockaddr[0].sin_port = C.htons address.port

    elseif domain == AF.inet6
        sockaddr = ffi.new "struct sockaddr_in6[?]", 1
        sockaddr[0].sin6_family = AF.inet6

        address.host = "::" if (C.strcmp address.host, "*") == 0
        C.inet_pton AF.inet6, host, sockaddr[0].sin6_addr

        sockaddr[0].sin6_port = C.htons address.port

    size = if sockaddr == nil then 0 else ffi.sizeof sockaddr
    (ffi.cast "const struct sockaddr *", sockaddr), size


strerror = (errnum) ->
    ffi.string C.strerror errnum


timevaltolua = (tv) ->
    (tonumber tv.tv_sec) + (tonumber tv.tv_usec) / 1000000


luatotimeval = (tv, value) ->
    tv.tv_sec = floor value
    tv.tv_usec = floor (value * 1000000) % 1000000


--------------------------------------------------------------------------------
tocaddress = (address) ->
    assert (type address) == "table"
    ffi.new "address_t", address


toladdress = (address) ->
    host: ffi.string address.host
    port: tonumber address.port


Socket = ffi.metatype "socket_wrapper_t",
    __gc: =>
        @\close!

    __index:
        close: =>
            if @sid != 0
                C.close(@sid)
                @sid = 0

        connect: (address) =>
            sockaddr, size = getsockaddr @domain, address
            error strerror ffi.errno! if sockaddr == nil
            status = C.connect @sid, sockaddr, size
            error strerror ffi.errno! if status == -1
            status

        bind: (address) =>
            sockaddr, size = getsockaddr @domain, address
            error strerror ffi.errno! if sockaddr == nil
            status = C.bind @sid, sockaddr, size
            error strerror ffi.errno! if status == -1
            status

        listen: (backlog=1) =>
            status = C.listen @sid, backlog
            error strerror ffi.errno! if status == -1

        accept: =>
            sockaddr = ffi.new "struct sockaddr[?]", 1
            sin_size = ffi.new "socklen_t[?]", 1
            sin_size[0] = ffi.sizeof sockaddr
            sid = C.accept @sid, sockaddr, sin_size
            error strerror ffi.errno! if sid == -1

            if @domain == AF.inet6
                sockaddr_p = ffi.cast "struct sockaddr_in6 *", sockaddr
                host = ffi.new "char[?]", C.INET6_ADDRSTRLEN
                C.inet_ntop AF.inet6, sockaddr_p[0].sin6_addr, host, C.INET6_ADDRSTRLEN
                port = C.ntohs sockaddr_p[0].sin6_port

            else
                sockaddr_p = ffi.cast "struct sockaddr_in *", sockaddr
                host = C.inet_ntoa sockaddr_p[0].sin_addr
                port = C.ntohs sockaddr_p[0].sin_port

            address = tocaddress {:host, :port}
            (Socket sid, @domain, @type, @protocol), address

        recv: (bsize=1024) =>
            buf = ffi.new "char[?]", bsize + 1
            C.recv @sid, buf, bsize, 0
            ffi.string buf

        receive: =>
            aux = @\recv 1
            buf = aux
            while aux != "\n"
                aux = @\recv 1
                buf ..= aux
            buf

        send: (data) =>
            status = C.send @sid, data, #data, 0
            error strerror ffi.errno! if status == -1

        sendto: (data, address) =>
            port = ffi.cast "uint16_t", port
            sockaddr, size = getsockaddr @domain, address
            error strerror ffi.errno! if sockaddr == nil
            status = sendto @sid, data, #data, 0, sockaddr, size
            error strerror ffi.errno! if status == -1

        setsockopt: (optname, value=1) =>
            local optval, optlen
            switch type(value)
                when "number"
                    optval = ffi.new "int[?]", 1
                    optval[0] = value
                    optlen = ffi.sizeof "int"
                when "cdata"
                    optval = value
                    optlen = ffi.sizeof optval
                when "string"
                    optval = ffi.cast "char *", value
                    optlen = #value
                else
                    error "unknown value: #{value}"

            status = C.setsockopt @sid, SOL_SOCKET, optname, optval, optlen
            error strerror ffi.errno! if status == -1

        getsockopt: (optname) =>
            -- TODO: get other value types
            optval = ffi.new "int[?]", 1
            optlen = ffi.sizeof "int"
            status = C.getsockopt @sid, SOL_SOCKET, optname, optval, optlen
            error strerror ffi.errno! if status == -1
            tonumber optval[0]

        settimeout: (param) =>
            local snd, rcv
            switch (type param)
                when "number"
                    snd = param
                    rcv = param
                when "table"
                    snd = param.send
                    rcv = param.receive
                else
                    error "unknown parameter #{param}"

            if snd
                tval = ffi.new "struct timeval[?]", 1
                luatotimeval tval[0], snd
                @\setsockopt SO.sndtimeo, tval
            if rcv
                tval = ffi.new "struct timeval[?]", 1
                luatotimeval tval[0], rcv
                @\setsockopt SO.rcvtimeo, tval

        gettimeout: =>
            tval_p = ffi.new "struct timeval[?]", 1
            optlen = ffi.sizeof "struct timeval"
            status = C.getsockopt, @sid, SOL_SOCKET, SO.sndtimeo, tval_p, optlen
            error sterror ffi.errno! if status == -1
            snd = timevaltolua tval_p[0]
            status = C.getsockopt, @sid, SOL_SOCKET, SO.rcvtimeo, tval_p, optlen
            error sterror ffi.errno! if status == -1
            rcv = timevaltolua tval_p[0]
            {send: snd, receive: rcv}


socket = (domain=AF.inet, type_=SOCK.stream, protocol) ->
    local p_proto
    switch type protocol
        when "number"
            p_proto = ffi.cast "int", protocol
        when "string"
            p_proto = getprotobyname protocol
            error "unknown protocol: #{protocol}" if p_proto == nil
        when "cdata"
            error "unknown protocol: #{protocol}" if not (tostring protocol)\match "^cdata<int>"
            p_proto = protocol
        else
            p_proto = ffi.cast "int", 0  -- IPPROTO_IP
    sid = C.socket domain, type_, p_proto
    Socket sid, domain, type_, p_proto


--------------------------------------------------------------------------------
{
    :_VERSION
    :_DESCRIPTON
    :_AUTHOR
    :_LICENSE
    :SOCK
    :AF
    :SO
    :socket
    :tocaddress
    :toladdress
}
