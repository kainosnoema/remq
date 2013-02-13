local channel, msg = ARGV[1], ARGV[2]
local channel_key = 'remq:channel:' .. channel

-- ids are an incrementing double precision integer
local id = redis.call('incr', 'remq:id')

redis.call('zadd', channel_key, id, msg) -- add to channel

-- publish using pub/sub with header in the format: "<channel>@<id>\n<message>"
redis.call('publish', channel_key, channel .. '@' .. id .. '\n' .. msg)

return id