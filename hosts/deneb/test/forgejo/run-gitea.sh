#!/bin/bash

exec su-exec gitea /app/gitea/gitea -c /etc/gitea/conf/app.ini -C /var/lib/gitea/ -w /var/lib/gitea/ web
