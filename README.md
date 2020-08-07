# uServer Mailer

A mail microservice stack containing SMTP, IMAP and POP servers (see [docker-mailserver](https://github.com/tomav/docker-mailserver)) as also a webmail client (see [rainloop-webmail](https://github.com/RainLoop/rainloop-webmail)).

It's part of the [uServer](https://github.com/users/ferdn4ndo/projects/1) stack project.


## Setup

### Environment

Copy both `mail/.env.template` and `webmail/.env.template` to `mail/.env` and `webmail/.env`, respectively, and then edit them to match your server configuration.


### Start Containers
    docker-compose up --build

### Create your mail accounts

    docker exec -it mail sh -c "./setup.sh email add <user@domain> <password>"

### Generate DKIM keys

    docker exec -it mail sh -c "./setup.sh config dkim"

As the keys are generated, you can configure your DNS server by just pasting the content of `config/opendkim/keys/domain.tld/mail.txt` in your `domain.tld.hosts` zone.

### Restart and update the container as deamon

    docker-compose down
    docker-compose up -d

## License

GNU Affero General Public License v3.0 as required by rainloop-webmail.
