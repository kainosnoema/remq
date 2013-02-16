local pattern, cursor = ARGV[1], ARGV[2]

-- convert Redis-style globbing to a Lua Pattern
pattern = '^' .. pattern:gsub('%.', '%%.'):gsub('%*', '.*') .. '@\%d+\n'

local flushed, per_loop, per_bucket = 0, 1000, 100000
while true do
  local bucket = math.floor((cursor - 1) / per_bucket) * per_bucket
  local prev_cursor = 0 + cursor - math.min(cursor - bucket, per_loop)

  local unfiltered = redis.call(
    'zrangebyscore', 'remq:archive:' .. bucket,
    prev_cursor, '(' .. cursor
  )

  if #unfiltered == 0 then
    return flushed -- end of the timeline
  end

  local matched = {}
  for i=1, #unfiltered do
    if unfiltered[i]:match(pattern) then
      matched[#matched + 1] = unfiltered[i]
    end
  end

  if #matched > 0 then
    redis.call('zrem', 'remq:archive:' .. bucket, unpack(matched))
    flushed = flushed + #matched
  end

  cursor = prev_cursor
end