# Remq

Remq (pronounced 'rem-que') is two things: (1) A [Redis](http://redis.io)-based protocol defined by a collection of Lua scripts (this project) which effectively turn Redis into a capable message queue broker for fast inter-service communication. (2) Multiple client libraries using these scripts for building fast, persisted pub/sub message queues.

  - Producers publish any string to a message channel and receive a unique message-id
  - Consumers subscribe to message channels via polling with a cursor (allowing resume), or via Redis pub/sub
  - Consumers can subscribe to multible queues at once using Redis key globbing (ie. `'events.*'`)
  - Able to sustain ~15k messages/sec on loopback interface (1 producer -> 1 consumer)
  - Consistent performance if Redis has enough memory (tested up to ~15m messages, 3GB in memory)
  - Purge channels of old messages periodically to maintain performance

NOTE: In early-stage development, API not locked.

## Client Libraries

- Node.js: [remq-node](https://github.com/kainosnoema/remq-node) (`npm install remq`)
- Ruby: [remq-rb](https://github.com/kainosnoema/remq-rb) (`gem install remq`)

## Usage

This project includes just the core Lua scripts that define the Remq protocol. To use Remq to build a message queue, install Redis along with one or more of the client libraries listed above.

Raw Redis syntax:

**Producer:**
``` sh
redis> EVAL <publish.lua> 0 namespace channel message utcseconds
# returns a unique message id
```

**Consumer:**
``` sh
redis> EVAL <consume.lua> 0 namespace channel cursor limit
# returns each message followed by its id, just like ZRANGEBYSCORE
```

**Purge:**
``` sh
redis> EVAL <purge.lua> 0 namespace channel <BEFORE id (or) KEEP count>
# returns the count of messages purged
```