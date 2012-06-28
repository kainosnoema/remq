local namespace, channel, cmd, value = ARGV[1], ARGV[2], ARGV[3], ARGV[4]
local channel_key = namespace .. ':channel:' .. channel

local matched_keys = { channel_key }
if string.find(channel_key, '*') then
  matched_keys = redis.call('keys', channel_key)
end

local purged = 0
for i,key in ipairs(matched_keys) do
  if cmd == 'BEFORE' then
    purged = purged + redis.call('zremrangebyscore', key, '-inf', '(' .. value)
  elseif cmd == 'KEEP' then
    purged = purged + redis.call('zremrangebyrank', key, 0, 0 - (value - 1))
  end
end

return purged