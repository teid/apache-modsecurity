FROM debian:stretch
LABEL maintainer="Timothée Eid <timothee.eid@erizo.fr>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apache2 \
        modsecurity-crs \
        libapache2-mod-security2 \
        libcap2-bin \
    && rm -r /var/lib/apt/lists/*

# Add default apache conf
ADD conf/apache/apache2.conf /etc/apache2/apache2.conf

# Add Apache modsecurity module conf
ADD conf/apache/security2.conf /etc/apache2/mods-available/security2.conf

# Add the WAF conf
ENV WAF_MOD="detect"
RUN cat /etc/modsecurity/modsecurity.conf-recommended \
    | sed 's#^SecAuditLog .*#SecAuditLog /dev/stdout#g' \
    | sed 's/^SecAuditEngine .*/SecAuditEngine Off/g' \
    > /etc/modsecurity/modsecurity-detect.conf
RUN cat /etc/modsecurity/modsecurity-detect.conf \
    | sed 's/^SecRuleEngine .*/SecRuleEngine On/g' \
    > /etc/modsecurity/modsecurity-block.conf

# Create the runtime volume
RUN mkdir -p /run/apache2
RUN chown -R www-data:www-data /run/apache2
VOLUME /run/apache2

# Site volume
RUN rm /etc/apache2/sites-enabled/*
ADD conf/apache/default-site.conf /etc/apache2/sites-enabled/default.conf
VOLUME /etc/apache2/sites-enabled/

# Allow apache to bind on registered ports (80 and 443) as non root user
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/apache2

EXPOSE 80
EXPOSE 443

# Add the start script
ADD run.sh /run.sh
RUN chmod 555 /run.sh
USER www-data
CMD [ "/run.sh" ]
