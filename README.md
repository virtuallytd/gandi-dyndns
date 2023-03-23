# gandi-dyndns
A container which runs a script which updates Gandi.net DNS via API Calls.

The docker container runs with an internal cron daemon which check and updates the dns every 30 minutes.

# Build

```
docker build -t gandi-dyndns .
```

# Run

```
docker-compose up -d
```

# Logs

Logs are created for dns updates under the log directory in a file called `update_dns.log`. This logfile will exponentially grow so will need to be rotated or cleared once in a while.