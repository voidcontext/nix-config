FROM codeberg.org/forgejo/forgejo:1.19.0-2

COPY regen-hooks.sh /regen-hooks.sh

RUN rm /etc/s6/gitea/setup
COPY run-gitea.sh /etc/s6/gitea/run
RUN cat /etc/templates/sshd_config                                       | \
    sed 's/\(AllowUsers.*\)/\1 gitea/' > /etc/templates/sshd_config.new && \
    mv /etc/templates/sshd_config.new  /etc/templates/sshd_config 


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
      gitea                 && \
    echo "gitea:*" | chpasswd -e

      
COPY $backupfile /backup
RUN cd /backup && unzip $backupfile

RUN sqlite3 /var/lib/gitea/data/gitea.db < /backup/forgejo-db.sql

RUN mv /backup/app.ini /etc/gitea/conf/app.ini                           && \
    mv /backup/data/* /var/lib/gitea/data/                               && \
    # mv /backup/log/* /var/lib/gitea/log/                                 && \
    mv /backup/repos/* /var/lib/gitea/repositories/

RUN cat /etc/gitea/conf/app.ini                                                |\
    # sed 's/SSH_PORT=\d\+/SSH_PORT=7022/'                                        |\
    sed 's/ROOT_URL=https:\/\/git.vdx.hu\//ROOT_URL=http:\/\/localhost:3001/'   \
    > /etc/gitea/conf/app.ini.new                                            && \
    mv /etc/gitea/conf/app.ini.new /etc/gitea/conf/app.ini

RUN chown -R gitea:gitea /etc/gitea/conf/app.ini /var/lib/gitea

ENV GITEA_CUSTOM /var/lib/gitea

RUN /regen-hooks.sh

