local pattern, cursor, limit = ARGV[1], ARGV[2], ARGV[3]

-- convert Redis-style globbing to a Lua Pattern
pattern = '^' .. pattern:gsub('%.', '%%.'):gsub('%*', '.*') .. '@\%d+\n'

cursor = math.max(cursor or 0, 0)
limit = math.min(math.max(limit or 1000, 0), 1000)

local matched, per_loop, per_bucket = {}, limit, 100000
while true do
  local bucket = math.floor(cursor / per_bucket) * per_bucket
  local unfiltered = redis.call(
    'zrangebyscore', 'remq:archive:' .. bucket,
    '(' .. cursor, '+inf', 'LIMIT', 0, per_loop
  )

  if #unfiltered == 0 then
    return matched -- end of the timeline
  end

  for i=1, #unfiltered do
    if unfiltered[i]:match(pattern) then
      matched[#matched + 1] = unfiltered[i]
      if #matched == limit then
        return matched -- reached the limit
      end
    end
  end

  cursor = cursor + per_loop
end