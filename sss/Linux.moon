ffi = assert require "ffi"


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

    struct in6_addr {
        union {
            __uint8_t u6_addr8[16];
            __int16_t u6_addr16[8];
            __int32_t u6_addr32[4];
        } in6_u;
    };

    struct sockaddr {
        sa_family_t sa_family;
        char        sa_data[14];
    };

    struct sockaddr_in {
        sa_family_t    sin_family;
        in_port_t      sin_port;
        struct in_addr sin_addr;
        char           sin_zero[8];
    };

    struct sockaddr_in6 {
        sa_family_t     sin6_family;
        in_port_t       sin6_port;
        struct in6_addr sin6_addr;
        __uint32_t      sin6_scope_id;
    };

    struct timeval {
        long      tv_sec;
        __int32_t tv_usec;
    };

    char *strerror(int);
    int strcmp(const char *, const char *);
    struct protoent *getprotobyname(const char *);

    enum {
        SOL_SOCKET = 0x0001,
    };

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

    struct socket_wrapper {
        int sid, domain, type, protocol;
    };

    struct netaddress {
        const char host[INET6_ADDRSTRLEN + 1];
        uint16_t   port;
    };

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
