local namespace, channel, msg = ARGV[1], ARGV[2], ARGV[3]
local channel_key = namespace .. ':channel:' .. channel

local id = redis.call('incr', namespace .. ':id')

redis.call('zadd', channel_key, id, msg)

redis.call('publish', channel_key, msg)
redis.call('publish', namespace .. ':stats:' .. channel, id)

return id