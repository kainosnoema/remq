# Remq

Remq (pronounced 'rem-que') is a set of [Redis](http://redis.io) Lua scripts
enabling Redis to function as a durable message queue/topic broker for fast,
reliable inter-service communication. These scripts, along with some simple
client libraries make it easy to build fast, durable message channels with
minimal infrastructure requirements.

**How it works**:

  - Producers publish messages to a channel and receive unique message-ids
  - Consumers subscribe to message channels via Redis pub/sub for fast delivery
  - Subscribe to multiple channels at once using globbing (ie. `'events.*'`)
  - Replay missed messages from a given message-id for recovery after consumer failure
  - Messages are garanteed to be received in-order when consumers use ids properly
  - Able to sustain ~35k messages/sec on loopback interface (1 producer -> 1 consumer)
  - Consistent performance up to memory limit (tested to ~25m messages in 4GB memory)
  - Channels may be flushed of old messages periodically to reduce memory footprint

**WARNING**: In early-stage development, API not stable. If you've used a previous
version of these scripts, you'll most likely have to clear all previously
published messages in order to upgrade to the latest version.

## Client Libraries

- Node.js: [remq-node](https://github.com/kainosnoema/remq-node) (`npm install remq`)
- Ruby: [remq-rb](https://github.com/kainosnoema/remq-rb) (`gem install remq`)

## Usage

This project includes just the core Lua scripts that define the Remq protocol.
To use Remq to build a message queue, install Redis along a client library.

Redis protocol:

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