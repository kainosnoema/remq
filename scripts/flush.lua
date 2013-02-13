local pattern, cmd, value = ARGV[1], ARGV[2], ARGV[3]
local pattern_key = 'remq:channel:' .. pattern

local channel_keys = redis.call('keys', pattern_key)

local count = 0
for i=1,#channel_keys do
  local key = channel_keys[i]
  if cmd == 'BEFORE' then
    count = count + redis.call('zremrangebyscore', key, '-inf', '(' .. value)
  elseif cmd == 'KEEP' then
    count = count + redis.call('zremrangebyrank', key, 0, 0 - (value - 1))
  end
end

return count