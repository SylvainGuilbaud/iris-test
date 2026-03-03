ARG IMAGE=mcr.microsoft.com/mssql/server:latest
FROM $IMAGE

USER root

# Installer dépendances et mssql-tools (dépot Microsoft)
# Compatible pour images basées sur Debian/Ubuntu. Si ton image est RHEL/CentOS, me le dire et j'adapte.
RUN apt-get update && apt-get install -y curl gnupg2 apt-transport-https && \
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl -sSL https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev mssql-tools && \
    # nettoyer pour gagner de l'espace disque
    apt-get remove -y curl gnupg2 apt-transport-https && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ajouter /opt/mssql-tools/bin au PATH pour root et mssql
ENV PATH="${PATH}:/opt/mssql-tools/bin"

COPY entrypoint.sh /entrypoint.sh
COPY scripts /scripts

RUN chmod 777 /entrypoint.sh &&\
    chmod -R 750 /scripts

USER mssql

ENTRYPOINT ["/entrypoint.sh"]