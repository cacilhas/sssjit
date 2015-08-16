package.path = "?.lua;?/init.lua;#{package.path}"
sss = assert require "sss"

s = sss.socket!
s\reuseaddr!
s\bind
    host: "*"
    port: 32000
s\listen!

while true
    c = s\accept!
    got = c\receive!
    c\send got
    c\close!
