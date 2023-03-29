FROM codeberg.org/forgejo/forgejo:1.18.5-0

COPY entrypoint.sh /entrypoint.sh
COPY run-gitea.sh /run-gitea.sh

ARG backupfile

RUN mkdir -p /backup                                && \
    mkdir -p /etc/gitea/conf                        && \
    mkdir -p /var/lib/gitea/data                    && \
    mkdir -p /var/lib/gitea/log                     && \
    mkdir -p /var/lib/gitea/repositories

RUN addgroup gitea          && \
    adduser -S -H -D \
      -h /var/lib/gitea \
      -s /bin/bash \
      gitea
      
COPY $backupfile /backup
RUN cd /backup && unzip $backupfile

RUN sqlite3 /var/lib/gitea/data/gitea.db < /backup/gitea-db.sql

RUN mv /backup/app.ini /etc/gitea/conf/app.ini                           && \
    mv /backup/data/* /var/lib/gitea/data/                               && \
    # mv /backup/log/* /var/lib/gitea/log/                                 && \
    mv /backup/repos/* /var/lib/gitea/repositories/                      && \
    chown -R gitea:gitea /etc/gitea/conf/app.ini /var/lib/gitea

RUN cat /etc/gitea/conf/app.ini | sed 's/ROOT_URL=https:\/\/git.vdx.hu\//ROOT_URL=http:\/\/localhost:3001/' \
    > /etc/gitea/conf/app.ini

RUN echo 

USER gitea

RUN /entrypoint.sh
ENTRYPOINT []
CMD ["sh", "/run-gitea.sh"]

    