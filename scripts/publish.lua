local channel, msg = ARGV[1], ARGV[2]

-- ids are an incrementing double precision integer
local id, per_bucket = redis.call('incr', 'remq:message-id'), 100000

-- prefix message with header in the format: "<channel>@<id>\n<message>"
msg = channel .. '@' .. id .. '\n' .. msg

-- split into buckets every 100,000 to allow 4x10^14 (400 trillion) messages
local bucket = 'remq:archive:' .. math.floor(id / per_bucket) * per_bucket

redis.call('zadd', bucket, id, msg) -- add to bucket
redis.call('publish', 'remq:channel:' .. channel, msg) --  publish to pub/sub

return id