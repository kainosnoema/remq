# Remq

Remq (pronounced 'rem-que') is two things: (1) A [Redis](http://redis.io)-based
protocol defined by a collection of Lua scripts (this project) which effectively
turn Redis into a capable message queue broker for fast, reliable inter-service
communication. (2) Multiple client libraries using these scripts for building
fast, persisted pub/sub message queues.

  - Producers publish any string to a message channel and receive a unique message-id
  - Consumers subscribe to message channels via polling with a cursor (allowing resume), or via Redis pub/sub
  - Consumers can subscribe to multible channels using Redis key globbing (ie. `'events.*'`)
  - Able to sustain ~10k messages/sec (bursts to ~30k/sec) on loopback interface (1 producer -> 1 consumer)
  - Consistent performance if Redis has enough memory (tested up to ~15m messages, 3GB in memory)
  - Channels may be flushed of old messages periodically to maintain performance

**WARNING**: In early-stage development, API not locked. If you've used a previous
version of these scripts, you'll most likely have to clear all previously
published messages in order to upgrade to the latest version.

## Client Libraries

- Node.js: [remq-node](https://github.com/kainosnoema/remq-node) (`npm install remq`)
- Ruby: [remq-rb](https://github.com/kainosnoema/remq-rb) (`gem install remq --pre`)

## Usage

This project includes just the core Lua scripts that define the Remq protocol.
To use Remq to build a message queue, install Redis along with one or more of
the client libraries listed above.

Raw Redis syntax:

**Producer:**
``` sh
redis> EVAL <publish.lua> 0 <channel> <message>
# returns a unique message id
```

**Consumer:**
``` sh
redis> PSUBSCRIBE remq:channel:<pattern>
# messages are published in the format "<channel>@<id>\n<message>"
```
or
``` sh
redis> EVAL <consume.lua> 0 <pattern> <cursor> <limit>
# messages are returned in the format "<channel>@<id>\n<message>"
```

**Purge:**
``` sh
redis> EVAL <flush.lua> 0 <pattern> [BEFORE <id> (or) KEEP <count>]
# returns the count of messages flushed
```