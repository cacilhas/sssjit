ffi = assert require "ffi"

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

    char *strerror(int);
    int strcmp(const char *, const char *);

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

    enum {
        INET_ADDRSTRLEN = 16,
        INET6_ADDRSTRLEN = 46,
    };

    enum {
        INADDR_ANY = 0x00000000,
        INADDR_BROADCAST = 0xffffffff,
        INADDR_LOOPBACK = 0x7f000001,
        INADDR_UNSPEC_GROUP = 0xe0000000,
        INADDR_ALLHOSTS_GROUP = 0xe0000001,
        INADDR_ALLRTRS_GROUP = 0xe0000002,
        INADDR_ALLRPTS_GROUP = 0xe0000016,
        INADDR_CARP_GROUP = 0xe0000012,
        INADDR_PFSYNC_GROUP = 0xe00000f0,
        INADDR_ALLMDNS_GROUP = 0xe00000fb,
        INADDR_MAX_LOCAL_GROUP = 0xe00000ff,
    };

    enum {
        SOCK_STREAM = 1,
        SOCK_DGRAM = 2,
        SOCK_RAW = 3,
        SOCK_RDM = 4,
        SOCK_SEQPACKET = 5,
    };

    enum {
        AF_UNSPEC = 0,
        AF_UNIX = 1,
        AF_LOCAL = 1,
        AF_INET = 2,
        AF_IMPLINK = 3,
        AF_PUP = 4,
        AF_CHAOS = 5,
        AF_NS = 6,
        AF_ISO = 7,
        AF_OSI = 7,
        AF_ECMA = 8,
        AF_DATAKIT = 9,
        AF_CCITT = 10,
        AF_SNA = 11,
        AF_DECnet = 12,
        AF_DLI = 13,
        AF_LAT = 14,
        AF_HYLINK = 15,
        AF_APPLETALK = 16,
        AF_ROUTE = 17,
        AF_LINK = 18,
        pseudo_AF_XTP = 19,
        AF_COIP = 20,
        AF_CNT = 21,
        pseudo_AF_RTIP = 22,
        AF_IPX = 23,
        AF_SIP = 24,
        pseudo_AF_PIP = 25,
        AF_NDRV = 27,
        AF_ISDN = 28,
        AF_E164 = 28,
        pseudo_AF_KEY = 29,
        AF_INET6 = 30,
        AF_NATM = 31,
        AF_SYSTEM = 32,
        AF_NETBIOS = 33,
        AF_PPP = 34,
        pseudo_AF_HDRCMPLT = 35,
        AF_RESERVED_36 = 36,
        AF_IEEE80211 = 37,
        AF_UTUN = 38,
        AF_MAX = 40,
    };

    enum {
        SO_DEBUG = 0x0001,
        SO_ACCEPTCONN = 0x0002,
        SO_REUSEADDR = 0x0004,
        SO_KEEPALIVE = 0x0008,
        SO_DONTROUTE = 0x0010,
        SO_BROADCAST = 0x0020,
        SO_USELOOPBACK = 0x0040,
        SO_LINGER = 0x0080,
        SO_OOBINLINE = 0x0100,
        SO_REUSEPORT = 0x0200,
        SO_TIMESTAMP = 0x0400,
        SO_TIMESTAMP_MONOTONIC = 0x0800,
        SO_ACCEPTFILTER = 0x1000,
        SO_DONTTRUNC = 0x2000,
        SO_WANTMORE = 0x4000,
        SO_WANTOOBFLAG = 0x8000,

        SO_SNDBUF = 0x1001,
        SO_RCVBUF = 0x1002,
        SO_SNDLOWAT = 0x1003,
        SO_RCVLOWAT = 0x1004,
        SO_SNDTIMEO = 0x1005,
        SO_RCVTIMEO = 0x1006,
        SO_ERROR = 0x1007,
        SO_TYPE = 0x1008,
        SO_LABEL = 0x1010,
        SO_PEERLABEL = 0x1011,
        SO_NREAD = 0x1020,
        SO_NKE = 0x1021,
        SO_NOSIGPIPE = 0x1022,
        SO_NOADDRERR = 0x1023,
        SO_NWRITE = 0x1024,
        SO_REUSESHAREUID = 0x1025,
        SO_NOTIFYCONFLICT = 0x1026,
        SO_UPCALLCLOSEWAIT = 0x1027,
        SO_LINGER_SEC = 0x1080,
        SO_RANDOMPORT = 0x1082,
        SO_NP_EXTENSIONS = 0x1083,
        SO_NUMRCVPKT = 0x1112,
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
        uint16_t port;
    } address_t;
]]


local *

C = ffi.C


--------------------------------------------------------------------------------
INADDR =
    any: ffi.cast "in_addr_t", C.INADDR_ANY
    broadcast: ffi.cast "in_addr_t", C.INADDR_BROADCAST
    loopback: ffi.cast "in_addr_t", C.INADDR_LOOPBACK
    --unspec_group: ffi.cast "in_addr_t", C.INADDR_UNSPEC_GROUP
    --allhosts_group: ffi.cast "in_addr_t", C.INADDR_ALLHOSTS_GROUP
    --allrtrs_group: ffi.cast "in_addr_t", C.INADDR_ALLRTRS_GROUP
    --allrpts_group: ffi.cast "in_addr_t", C.INADDR_ALLRPTS_GROUP
    --carp_group: ffi.cast "in_addr_t", C.INADDR_CARP_GROUP
    --pfsync_group: ffi.cast "in_addr_t", C.INADDR_PFSYNC_GROUP
    --allmdns_group: ffi.cast "in_addr_t", C.INADDR_ALLMDNS_GROUP
    --max_local_group: ffi.cast "in_addr_t", C.INADDR_MAX_LOCAL_GROUP


SOL_SOCKET = ffi.cast "int", switch ffi.os
    when "Linux"
        0x0001
    else
        0xffff


SOCK =
    stream: ffi.cast "int", C.SOCK_STREAM
    dgram: ffi.cast "int", C.SOCK_DGRAM
    raw: ffi.cast "int", C.SOCK_RAW
    rdm: ffi.cast "int", C.SOCK_RDM
    seqpacket: ffi.cast "int", C.SOCK_SEQPACKET


AF =
    unspec:    ffi.cast "sa_family_t", C.AF_UNSPEC
    unix:      ffi.cast "sa_family_t", C.AF_UNIX
    local:     ffi.cast "sa_family_t", C.AF_LOCAL
    inet:      ffi.cast "sa_family_t", C.AF_INET
    implink:   ffi.cast "sa_family_t", C.AF_IMPLINK
    pup:       ffi.cast "sa_family_t", C.AF_PUP
    chaos:     ffi.cast "sa_family_t", C.AF_CHAOS
    ns:        ffi.cast "sa_family_t", C.AF_NS
    iso:       ffi.cast "sa_family_t", C.AF_ISO
    osi:       ffi.cast "sa_family_t", C.AF_OSI
    ecma:      ffi.cast "sa_family_t", C.AF_ECMA
    datakit:   ffi.cast "sa_family_t", C.AF_DATAKIT
    ccitt:     ffi.cast "sa_family_t", C.AF_CCITT
    sna:       ffi.cast "sa_family_t", C.AF_SNA
    decnet:    ffi.cast "sa_family_t", C.AF_DECnet
    dli:       ffi.cast "sa_family_t", C.AF_DLI
    lat:       ffi.cast "sa_family_t", C.AF_LAT
    hylink:    ffi.cast "sa_family_t", C.AF_HYLINK
    appletalk: ffi.cast "sa_family_t", C.AF_APPLETALK
    route:     ffi.cast "sa_family_t", C.AF_ROUTE
    link:      ffi.cast "sa_family_t", C.AF_LINK
    xtp:       ffi.cast "sa_family_t", C.pseudo_AF_XTP
    coip:      ffi.cast "sa_family_t", C.AF_COIP
    cnt:       ffi.cast "sa_family_t", C.AF_CNT
    rtip:      ffi.cast "sa_family_t", C.pseudo_AF_RTIP
    ipx:       ffi.cast "sa_family_t", C.AF_IPX
    sip:       ffi.cast "sa_family_t", C.AF_SIP
    pip:       ffi.cast "sa_family_t", C.pseudo_AF_PIP
    ndrv:      ffi.cast "sa_family_t", C.AF_NDRV
    isdn:      ffi.cast "sa_family_t", C.AF_ISDN
    e164:      ffi.cast "sa_family_t", C.AF_E164
    key:       ffi.cast "sa_family_t", C.pseudo_AF_KEY
    inet6:     ffi.cast "sa_family_t", C.AF_INET6
    natm:      ffi.cast "sa_family_t", C.AF_NATM
    system:    ffi.cast "sa_family_t", C.AF_SYSTEM
    netbios:   ffi.cast "sa_family_t", C.AF_NETBIOS
    ppp:       ffi.cast "sa_family_t", C.AF_PPP
    hdrcmplt:  ffi.cast "sa_family_t", C.pseudo_AF_HDRCMPLT
    ieee80211: ffi.cast "sa_family_t", C.AF_IEEE80211
    utun:      ffi.cast "sa_family_t", C.AF_UTUN


SO =
    debug: ffi.cast "int", C.SO_DEBUG
    acceptconn: ffi.cast "int", C.SO_ACCEPTCONN
    reuseaddr: ffi.cast "int", C.SO_REUSEADDR
    keepalive: ffi.cast "int", C.SO_KEEPALIVE
    dontroute: ffi.cast "int", C.SO_DONTROUTE
    broadcast: ffi.cast "int", C.SO_BROADCAST
    useloopback: ffi.cast "int", C.SO_USELOOPBACK
    linger: ffi.cast "int", C.SO_LINGER
    oobinline: ffi.cast "int", C.SO_OOBINLINE
    resuseport: ffi.cast "int", C.SO_REUSEPORT
    timestamp: ffi.cast "int", C.SO_TIMESTAMP
    timestamp_monotonic: ffi.cast "int", C.SO_TIMESTAMP_MONOTONIC
    acceptfilter: ffi.cast "int", C.SO_ACCEPTFILTER
    donttrunc: ffi.cast "int", C.SO_DONTTRUNC
    wantmore: ffi.cast "int", C.SO_WANTMORE
    wanttoobflag: ffi.cast "int", C.SO_WANTOOBFLAG
    sndbuf: ffi.cast "int", C.SO_SNDBUF
    rcvbuf: ffi.cast "int", C.SO_RCVBUF
    sndlowat: ffi.cast "int", C.SO_SNDLOWAT
    rcvlowat: ffi.cast "int", C.SO_RCVLOWAT
    sndtimeo: ffi.cast "int", C.SO_SNDTIMEO
    rcvtimeo: ffi.cast "int", C.SO_RCVTIMEO
    error: ffi.cast "int", C.SO_ERROR
    type: ffi.cast "int", C.SO_TYPE
    label: ffi.cast "int", C.SO_LABEL
    peerlabel: ffi.cast "int", C.SO_PEERLABEL
    nread: ffi.cast "int", C.SO_NREAD
    nke: ffi.cast "int", C.SO_NKE
    nosigpip: ffi.cast "int", C.SO_NOSIGPIPE
    noaddrerr: ffi.cast "int", C.SO_NOADDRERR
    nwrite: ffi.cast "int", C.SO_NWRITE
    reuseshareuid: ffi.cast "int", C.SO_REUSESHAREUID
    notifyconflict: ffi.cast "int", C.SO_NOTIFYCONFLICT
    upcallclosewait: ffi.cast "int", C.SO_UPCALLCLOSEWAIT
    linger_sec: ffi.cast "int", C.SO_LINGER_SEC
    randomport: ffi.cast "int", C.SO_RANDOMPORT
    np_extensions: ffi.cast "int", C.SO_NP_EXTENSIONS
    numrcvpkt: ffi.cast "int", C.SO_NUMRCVPKT


--------------------------------------------------------------------------------
get_sockaddr = (domain, address) ->
    address = tocaddress address if (type address) == "table"

    if domain == AF.inet
        sockaddr = ffi.new "struct sockaddr_in[?]", 1
        sockaddr[0].sin_family = AF.inet

        if (C.strcmp address.host, "0.0.0.0") * (C.strcmp address.host, "*") == 0
            sockaddr[0].sin_addr.s_addr = INADDR.any
        elseif (C.strcmp address.host, "broadcast")
            sockaddr[0].sin_addr.s_addr = INADDR.broadcast
        elseif (C.strcmp address.host, "loopback")
            sockaddr[0].sin_addr.s_addr = INADDR.loopback
        else
            C.inet_aton address.host, sockaddr[0].sin_addr

        sockaddr[0].sin_port = C.htons address.port
        (ffi.cast "const struct sockaddr *", sockaddr), ffi.sizeof sockaddr

    elseif domain == AF.inet6
        sockaddr = ffi.new "struct sockaddr_in6[?]", 1
        sockaddr[0].sin6_family = AF.inet6

        address.host = "::" if (C.strcmp address.host, "*") == 0
        C.inet_pton AF.inet6, host, sockaddr[0].sin6_addr

        sockaddr[0].sin6_port = C.htons address.port
        (ffi.cast "const struct sockaddr *", sockaddr), ffi.sizeof sockaddr

    else
        0, 0


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
            error strerror ffi.errno! if sockaddr == 0
            status = C.connect @sid, sockaddr, size

            error strerror ffi.errno! if status == -1
            status

        bind: (address) =>
            sockaddr, size = get_sockaddr @domain, address
            error strerror ffi.errno! if sockaddr == 0
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
            error strerror ffi.errno! if sockaddr == 0
            status = sendto @sid, data, #data, 0, sockaddr, size
            error strerror ffi.errno! if status == -1

        setsockopt: (optname, value=true) =>
            optval = ffi.new "int[?]", 1
            optval[0] = ffi.cast "int", (if value then 1 else 0)
            status = C.setsockopt @sid, SOL_SOCKET, optname, optval, (ffi.sizeof optval)
            error strerror ffi.errno! if status == -1

        getsockopt: (optname) =>
            value = ffi.new "int[?]", 1
            status = C.getsockopt @sid, SOL_SOCKET, optname, value, (ffi.sizeof value)
            error strerror ffi.errno! if status == -1
            (tonumber value[0]) != 0


socket = (domain=AF.inet, type_=SOCK.stream, protocol=0) ->
    protocol = ffi.cast "int", protocol
    sid = C.socket domain, type_, protocol
    Socket sid, domain, type_, protocol


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
