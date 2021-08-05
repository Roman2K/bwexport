# bwexport

> Bitwarden vault backup

An alternative to `bw export` that does not require the master password, and
also timestamps and encrypts files with a GPG public key

## Usage

Example docker-compose service:

```yaml
bwexport:
  <<: *common
  image: bwexport
  volumes:
    - "bwexport:/home/node/.config/Bitwarden CLI"
    - $HOME/mnt/drive/backup/bitwarden:/home/node/out
    - ../conf/bwexport/gpg-roman.asc:/home/node/pub.gpg:ro
  environment:
    BW_SESSION: "…"
  command: ["export", "Roman"]
```

Log in and set `BW_SESSION`:

```sh
$ docker-compose run --rm --entrypoint=sh --user=root bwexport -c "chown -R node: /home/node"
$ docker-compose run --rm --entrypoint=bw bwexport login
```
