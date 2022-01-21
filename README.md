# Dockerized Netflow Collector

Netflow collector and local processing Docker image using [NfSen](http://nfsen.sourceforge.net/)
and [nfdump](http://nfdump.sourceforge.net/) for processing.

This docker image can be run standalone or in conjunction with a analytics engine that will perform
time based graphing and stats summarization.

## Quick reference

- **Maintained by:** [Serghei Iakovlev](https://github.com/sergeyklay/docker-netflow)
- **Where to get help:** [GitHub Issues](https://github.com/sergeyklay/docker-netflow/issues)

## Supported tags and respective `Dockerfile` links

- [`1.0.0`, `1.0`, `1`, `latest`, `1.0.0-bullseye`, `1.0-bullseye`, `1-bullseye`, `bullseye`](https://github.com/sergeyklay/docker-netflow/releases/tag/1.0.0)

## Quick reference (cont.)

- **Where to file issues:** https://github.com/sergeyklay/docker-netflow/issues
- **Supported architectures:** `amd64`, `arm32v5`, `arm32v6`, `arm32v7`, `arm64v8`, `i386`, `mips64le`, `ppc64le`, `s390x`

## What is NfSen?

NfSen is a graphical web based front end for the nfdump netflow tools.

For more see http://nfsen.sourceforge.net/

# #What is nfdump?

The nfdump tools collect and process netflow data on the command line. They are part of the NfSen project which is explained more detailed at
http://www.ripe.net/ripe/meetings/ripe-50/presentations/ripe50-plenary-tue-nfsen-nfdump.pdf

For more see http://nfdump.sourceforge.net/

## How to use this image

### start a netflow instance


```bash
$ docker run -p 80:80 -p 2055:2055/udp -p 4739:4739/udp -p 6343:6343/udp -p 9996:9996/udp klay/netflow
```

## License

View [license information](http://nfsen.sourceforge.net/BSD-license.html)
for NfSen contained in this image.

View [license information](https://github.com/phaag/nfdump/blob/master/LICENSE)
for nfdump contained in this image.

As with all Docker images, these likely also contain other software which may be
under other licenses (such as Bash, etc from the base distribution, along with
any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found
[in the repo](https://github.com/sergeyklay/docker-netflow/blob/master/VERSION).

As for any pre-built image usage, it is the image user's responsibility to ensure
that any use of this image complies with any relevant licenses for all software
contained within.
