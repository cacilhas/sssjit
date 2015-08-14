#!/usr/bin/env moon

import loadfile from assert require "moonscript.base"
sss = (loadfile "sss.moon")!

s = sss.socket!
s\setsockopt sss.SO.reuseaddr
s\bind
    host: "*"
    port: 32000
s\listen!

while true
    c = s\accept!
    got = c\receive!
    c\send got
    c\close!
