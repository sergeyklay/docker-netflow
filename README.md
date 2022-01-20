# Docker NfSen

Netflow collector and local processing Docker image using [NfSen](http://nfsen.sourceforge.net/)
and [nfdump](https://github.com/phaag/nfdump) for processing.

This docker image can be run standalone or in conjunction with a analytics engine that will perform
time based graphing and stats summarization.

## Usage

To quickly get started running use the following command:

```bash
# Bellow are 'docker run' options:
#
# -p   Publish a container's port(s) to the host
# -i   Keep STDIN open even if not attached
# -t   Allocate a pseudo-TTY
$ docker run \
  -p 80:80 \
  -p 4739:4739/udp \
  -p 6343:6343/udp \
  -p 9995:9995/udp \
  -p 9996:9996/udp \
  -i \
  -t \
  klay/netflow:1.0.0
```
