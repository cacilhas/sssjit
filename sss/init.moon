local *
ffi = assert require "ffi"
import floor from math


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
    ffi.new "struct netaddress", address


toladdress = (address) -> {
    host: ffi.string address.host
    port: tonumber address.port
}


Socket = ffi.metatype "struct socket_wrapper",
    __gc: =>
        @\close!

    __index:
        close: =>
            if @sid != 0
                C.close @sid
                @sid = 0

        connect: (address) =>
            sockaddr, size = getsockaddr @domain, address
            error strerror ffi.errno! unless sockaddr
            status = C.connect @sid, sockaddr, size
            error strerror ffi.errno! if status == -1
            status

        bind: (address) =>
            sockaddr, size = getsockaddr @domain, address
            error strerror ffi.errno! unless sockaddr
            status = C.bind @sid, sockaddr, size
            error strerror ffi.errno! if status == -1
            status

        listen: (backlog=1) =>
            status = C.listen @sid, backlog
            error strerror ffi.errno! if status == -1
            status

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

        send: (data, address=nil) =>
            if address
                port = ffi.cast "uint16_t", port
                sockaddr, size = getsockaddr @domain, address
                error strerror ffi.errno! if sockaddr == nil
                status = sendto @sid, data, #data, 0, sockaddr, size
                error strerror ffi.errno! if status == -1
                status

            else
                status = C.send @sid, data, #data, 0
                error strerror ffi.errno! if status == -1
                status

        setopt: (optname, optval) =>
            assert type(optval) == "cdata"
            optlen = ffi.sizeof optval
            ovtype = ffi.typeof "$ *", optval
            optval_p = ffi.cast ovtype, (0 + (tostring optval)\match": (0x.+)$")
            status = C.setsockopt @sid, SOL_SOCKET, optname, optval_p, optlen
            error strerror ffi.errno! if status == -1
            status

        getopt: (optname) =>
            optlen = ffi.new "socklen_t"
            optlen_p = ffi.cast "socklen_t", optlen
            optval_p = ffi.new "void *"
            status = C.getsockopt @sid, SOL_SOCKET, optname, optval_p, optlen_p
            optval_p = ffi.cast "unsigned char *", optval_p
            optval = ffi.new "unsigned char[?]", optlen
            optval[i] = optval_p[0][i] for i = 0, optlen - 1
            optval, optlen

        reuseaddr: =>
            @\setopt SO.reuseaddr, (ffi.cast "int", 1)

        settimeout: (param) =>
            local snd, rcv
            switch type param
                when "number"
                    snd = param
                    rcv = param
                when "table"
                    snd = param.send
                    rcv = param.receive
                else
                    error "unknown parameter #{param}"

            status = {}
            if snd
                tval = ffi.new "struct timeval[?]", 1
                luatotimeval tval[0], snd
                status.snd = C.setsockopt @sid, SOL_SOCKET, SO.sndtimeo, tval, ffi.sizeof tval
                error strerror ffi.errno! if status.snd == -1
            if rcv
                tval = ffi.new "struct timeval[?]", 1
                luatotimeval tval[0], rcv
                status.rcv = C.setsockopt @sid, SOL_SOCKET, SO.rcvtimeo, tval, ffi.sizeof tval
                error strerror ffi.errno! if status.rcv == -1
            status

        broadcast: =>
            @\setopt SO.broadcast, (ffi.cast "int", 1)


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
