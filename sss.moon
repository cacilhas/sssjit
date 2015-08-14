ffi = assert require "ffi"

local *


_VERSION = "0.4"
_DESCRIPTION = "LuaJIT-powered Simple Stupid Socket"
_AUTHOR = "ℜodrigo Arĥimedeς ℳontegasppa ℭacilhας <batalema@cacilhas.info>"
_LICENSE = "BSD-3 Clausule"


ffi.cdef [[
    typedef unsigned char      __uint8_t;
    typedef short              __int16_t;
    typedef unsigned short     __uint16_t;
    typedef int                __int32_t;
    typedef unsigned int       __uint32_t;
    typedef long long          __int64_t;
    typedef unsigned long long __uint64_t;

    typedef __uint8_t  sa_family_t;
    typedef __uint16_t in_port_t;
    typedef __uint32_t in_addr_t;
    typedef __uint32_t socklen_t;

    struct protoent {
        char *p_name;
        char **p_aliases;
        int p_proto;
    };

    struct in_addr {
        in_addr_t s_addr;
    };

    struct sockaddr {
        __uint8_t   sa_len;
        sa_family_t sa_family;
        char        sa_data[14];
    };

    struct sockaddr_in {
        __uint8_t      sin_len;
        sa_family_t    sin_family;
        in_port_t      sin_port;
        struct in_addr sin_addr;
        char           sin_zero[8];
    };

    struct timeval {
        long      tv_sec;
        __int32_t tv_usec;
    };

    char *strerror(int);
    int strcmp(const char *, const char *);
    struct protoent *getprotobyname(const char *);

    enum {
        INET_ADDRSTRLEN =  16,
        INET6_ADDRSTRLEN = 46,
    };

    enum {
        INADDR_ANY =             0x00000000,
        INADDR_BROADCAST =       0xffffffff,
        INADDR_LOOPBACK =        0x7f000001,
    };

    enum {
        SOCK_STREAM =    1,
        SOCK_DGRAM =     2,
        SOCK_RAW =       3,
        SOCK_RDM =       4,
        SOCK_SEQPACKET = 5,
    };

    uint16_t ntohs(uint16_t);
    int inet_aton(const char *, struct in_addr *);
    uint16_t htons(uint16_t);
    int inet_pton(int, const char *src, void *);
    int socket(int, int, int);
    const char *inet_ntop(int, const void *, char *, socklen_t);
    char *inet_ntoa(struct in_addr);

    int close(int);
    int connect(int, const struct sockaddr *, size_t);
    int bind(int, const struct sockaddr *, size_t);
    int listen(int, int);
    int accept(int, struct sockaddr *, socklen_t *);

    size_t recv(int, void *, size_t, int);
    size_t send(int, const void *, size_t, int);
    size_t sendto(int, const void *, size_t, int, const struct sockaddr *, socklen_t);

    int getsockopt(int, int, int, void *, socklen_t *);
    int setsockopt(int, int, int, const void *, socklen_t);


    typedef struct {
        int sid, domain, type, protocol;
    } socket_wrapper_t;

    typedef struct {
        const char host[INET6_ADDRSTRLEN + 1];
        uint16_t   port;
    } address_t;
]]

switch ffi.os
    when "Linux"
        ffi.cdef [[
            enum {
                AF_UNSPEC =     0,
                AF_UNIX =       1,
                AF_LOCAL =      1,
                AF_INET =       2,
                AF_INET6 =     10,
                AF_IPX =        4,
                AF_APPLETALK =  5,
                AF_NETBIOS =   13,
                AF_KEY =       15,
                AF_ROUTE =     16,
                AF_IEEE8021 =  36,
            };

            enum {
                SO_DEBUG =     0x0001,
                SO_REUSEADDR = 0x0002,
                SO_TYPE =      0x0003,
                SO_ERROR =     0x0004,
                SO_DONTROUTE = 0x0005,
                SO_BROADCAST = 0x0006,
                SO_SNDBUF =    0x0007,
                SO_RCVBUF =    0x0008,
                SO_KEEPALIVE = 0x0009,
                SO_OOBINLINE = 0x000a,
                SO_NO_CHECK =  0x000b,
                SO_PRIORITY =  0x000c,
                SO_LINGER =    0x000d,
                SO_BSDCOMPAT = 0x000e,
                SO_REUSEPORT = 0x000f,
                SO_PASSCRED  = 0x0010,
                SO_PEERCRED  = 0x0011,
                SO_RCVLOWAT  = 0x0012,
                SO_SNDLOWAT  = 0x0013,
                SO_RCVTIMEO  = 0x0014,
                SO_SNDTIMEO  = 0x0015,
            };
        ]]

    else
        ffi.cdef [[
            enum {
                AF_UNSPEC =     0,
                AF_UNIX =       1,
                AF_LOCAL =      1,
                AF_INET =       2,
                AF_INET6 =     30,
                AF_IPX =       23,
                AF_APPLETALK = 16,
                AF_NETBIOS =   33,
                AF_KEY =       29,
                AF_ROUTE =     17,
                AF_IEEE8021 =  37,
            };

            enum {
                SO_DEBUG =     0x0001,
                SO_REUSEADDR = 0x0004,
                SO_TYPE =      0x1008,
                SO_ERROR =     0x1007,
                SO_DONTROUTE = 0x0010,
                SO_BROADCAST = 0x0020,
                SO_SNDBUF =    0x1001,
                SO_RCVBUF =    0x1002,
                SO_KEEPALIVE = 0x0008,
                SO_OOBINLINE = 0x0100,
                SO_NO_CHECK =  0x000b,
                SO_PRIORITY =  0x000c,
                SO_BSDCOMPAT = 0x000e,
                SO_LINGER =    0x0080,
                SO_REUSEPORT = 0x0200,
                SO_PASSCRED  = 0x0010,
                SO_PEERCRED  = 0x0011,
                SO_SNDLOWAT =  0x1003,
                SO_RCVLOWAT =  0x1004,
                SO_SNDTIMEO =  0x1005,
                SO_RCVTIMEO =  0x1006,
            };
        ]]


C = ffi.C


--------------------------------------------------------------------------------
INADDR =
    any:       ffi.cast "in_addr_t", C.INADDR_ANY
    broadcast: ffi.cast "in_addr_t", C.INADDR_BROADCAST
    loopback:  ffi.cast "in_addr_t", C.INADDR_LOOPBACK


getprotobyname = (name) ->
    pe_p = C.getprotobyname name
    if pe_p == nil then nil else pe_p[0].p_proto


SOL_SOCKET = ffi.cast "int", switch ffi.os
    when "Darwin"
        0xffff
    when "Windows"
        0xffff
    else
        0x0001


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
get_sockaddr = (domain, address) ->
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


--------------------------------------------------------------------------------
tocaddress = (address) ->
    assert (type address.host) == "string" and (type address.port) == "number"
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
            sockaddr, size = get_sockaddr @domain, address
            error strerror ffi.errno! if sockaddr == nil
            status = C.connect @sid, sockaddr, size
            error strerror ffi.errno! if status == -1
            status

        bind: (address) =>
            sockaddr, size = get_sockaddr @domain, address
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
            assert (type host) == "string" and (type port) == "number"
            port = ffi.cast "uint16_t", port
            sockaddr, size = get_sockaddr @domain, address
            error strerror ffi.errno! if sockaddr == nil
            status = sendto @sid, data, #data, 0, sockaddr, size
            error strerror ffi.errno! if status == -1

        setsockopt: (optname, value=1) =>
            optval = ffi.new "int[?]", 1
            optval[0] = value
            status = C.setsockopt @sid, SOL_SOCKET, optname, optval, (ffi.sizeof optval)
            error strerror ffi.errno! if status == -1

        getsockopt: (optname) =>
            optval = ffi.new "int[?]", 1
            status = C.getsockopt @sid, SOL_SOCKET, optname, optval, (ffi.sizeof optval)
            error strerror ffi.errno! if status == -1
            tonumber optval[0]


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
