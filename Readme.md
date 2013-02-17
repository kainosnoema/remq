# Remq

Remq (pronounced 'rem-que') is two things: (1) A [Redis](http://redis.io)-based
protocol defined by a collection of Lua scripts (this project) which effectively
turn Redis into a durable message queue broker for fast, reliable inter-service
communication. (2) Multiple client libraries using these scripts for building
fast, persisted pub/sub message queues.

  - Producers publish any string to a message channel and receive a unique message-id
  - Consumers subscribe to message channels via vanilla Redis pub/sub for instant delivery
  - Subscribe to multiple channels using Redis key globbing (ie. `'events.*'`)
  - Replay archived messages from a given message-id for failure recovery
  - Able to sustain ~35k messages/sec on loopback interface (1 producer -> 1 consumer)
  - Consistent performance up to system memory limit (tested to ~25m messages in 4GB memory)
  - Channels may be flushed of old messages periodically to reduce memory footprint

**WARNING**: In early-stage development, API not stable. If you've used a previous
version of these scripts, you'll most likely have to clear all previously
published messages in order to upgrade to the latest version.

## Client Libraries

- Node.js: [remq-node](https://github.com/kainosnoema/remq-node) (`npm install remq`)
- Ruby: [remq-rb](https://github.com/kainosnoema/remq-rb) (`gem install remq`)

## Usage

This project includes just the core Lua scripts that define the Remq protocol.
To use Remq to build a message queue, install Redis along with one or more of
the client libraries listed above.

Raw Redis syntax:

**Producer:**
``` sh
redis> EVAL <publish.lua> 0 <channel> <message>
# returns a unique message-id
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

**Flush:**
``` sh
redis> EVAL <flush.lua> 0 <pattern> <before-message-id>
# returns the count of messages flushed
```

## License

(The MIT License)

Copyright © 2013 Evan Owen &lt;kainosnoema@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.