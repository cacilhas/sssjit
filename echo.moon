local *
package.path = "?.lua;?/init.lua;#{package.path}"
sss = assert require "sss"

s = with sss.socket!
    \reuseaddr!
    \bind
        host: "*"
        port: 32000
    \listen!

while true
    c, addr = s\accept!
    addr = sss.toladdress addr
    got = c\receive!
    print "got #{got} from #{addr.host}:#{addr.port}"
    c\send got
    c\close!
