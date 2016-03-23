# Cleaning up stale Redis sessions

GitSwarm EE stores web user sessions as key-value pairs in Redis. Prior to
GitSwarm EE 2015.3, user sessions did not automatically expire from Redis.
If you have been running a large GitSwarm EE server (thousands of users)
since before GitSwarm EE 2015.3, we recommend cleaning up stale sessions to
compact the Redis database after you upgrade to GitSwarm EE 2015.3 or
newer. You can also perform a cleanup while still running GitSwarm EE
2015.2 or older, but in that case new stale sessions will start building up
again after you clean up.

In GitSwarm EE versions prior to 2015.4, the session keys in Redis are
16-byte hexadecimal values such as '976aa289e2189b17d7ef525a6702ace9'.
Starting with GitSwarm EE 2015.4, the keys are prefixed with
'session:gitlab:', so they would look like
'session:gitlab:976aa289e2189b17d7ef525a6702ace9'. Below we describe how to
remove the keys in the old format.

First we define a shell function with the proper Redis connection details.

```bash
rcli() {
  sudo /opt/gitswarm/embedded/bin/redis-cli -s /var/opt/gitswarm/redis/redis.socket "$@"
}

# test the new shell function; the response should be PONG
rcli ping
```

Now we do a search to see if there are any session keys in the old format
for us to clean up.

```bash
# returns the number of old-format session keys in Redis
rcli keys '*' | grep '^[a-f0-9]\{32\}$' | wc -l
```

If the number is larger than zero, you can proceed to expire the keys from
Redis. If the number is zero there is nothing to clean up.

```bash
# Tell Redis to expire each matched key after 600 seconds.
rcli keys '*' | grep '^[a-f0-9]\{32\}$' | awk '{ print "expire", $0, 600 }' | rcli
# This will print '(integer) 1' for each key that gets expired.
```

Over the next 15 minutes (10 minutes expiry time plus 5 minutes Redis
background save interval) your Redis database will be compacted. If you are
still using GitSwarm EE 2015.3, users who are not clicking around in
GitSWarm EE during the 10 minute expiry window are signed out of GitSwarm
EE.