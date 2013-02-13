local pattern, cursor, limit = ARGV[1], ARGV[2], ARGV[3]
local pattern_key = 'remq:channel:' .. pattern

limit = math.min(limit or 1000, 1000)

-- for results from multiple channels, we'll merge them into a single set
-- zunionstore is not optimal here since we only need a subset of matching sets
local union_key = pattern_key .. '@' .. (redis.call('get', 'remq:id') or 0)
local channel_keys = redis.call('keys', pattern_key)
for i=1,#channel_keys do
  local key = channel_keys[i]
  local channel = key:gsub('remq:channel:', '')
  local msgs_ids = redis.call(
    'zrangebyscore', key, '(' .. cursor, '+inf', 'WITHSCORES', 'LIMIT', 0, limit
  )
  for i=1,#msgs_ids do
    if i % 2 == 0 then
      -- add a header in the format: "<channel>@<id>\n<message>"
      local msg = channel .. '@' .. msgs_ids[i] .. '\n' .. msgs_ids[i - 1]
      redis.call('zadd', union_key, msgs_ids[i], msg)
    end
  end
end

local msgs = redis.call(
  'zrangebyscore', union_key, '(' .. cursor, '+inf', 'LIMIT', 0, limit
)

redis.call('del', union_key) -- remove the union key

return msgs