# uServer Mailer

A mail microservice stack containing SMTP, IMAP and POP servers (see [docker-mailserver](https://github.com/tomav/docker-mailserver)) as also a webmail client (see [rainloop-webmail](https://github.com/RainLoop/rainloop-webmail)).

Auto-backup to Amazon S3 using [istepanov/docker-backup-to-s3](https://github.com/istepanov/docker-backup-to-s3).

It's part of the [uServer](https://github.com/users/ferdn4ndo/projects/1) stack project.


## Setup

### Environment

Copy both `mail/.env.template` and `webmail/.env.template` to `mail/.env` and `webmail/.env`, respectively, and then edit them to match your server configuration.


### Start Containers
    docker-compose up --build

### Create your mail accounts

    ./mail/setup.sh email add <user@domain> <password>

### Generate DKIM keys

    ./mail/setup.sh config dkim

As the keys are generated, you can configure your DNS server by just pasting the content of `config/opendkim/keys/domain.tld/mail.txt` in your `domain.tld.hosts` zone.

### More commands

Check [this links from docker-mailserver](https://github.com/tomav/docker-mailserver/wiki/Setup-docker-mailserver-using-the-script-setup.sh) to get more information about the possible commands.

### Restart and update the container as deamon

    docker-compose down
    docker-compose up -d

## License

GNU Affero General Public License v3.0 as required by rainloop-webmail.
