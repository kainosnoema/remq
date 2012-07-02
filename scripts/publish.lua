local namespace, channel, msg, utc_sec = ARGV[1], ARGV[2], ARGV[3], ARGV[4]
local channel_key = namespace .. ':channel:' .. channel

-- ids are an incrementing integer followed by UTC time as a decimal value
local id = redis.call('incr', namespace .. ':id') .. '.' .. (utc_sec or 0)

redis.call('zadd', channel_key, id, msg)

redis.call('publish', channel_key, msg)
redis.call('publish', namespace .. ':stats:' .. channel, id)

return id