Docker Apache-Modsecurity
===================

A Docker image running [Apache2](https://httpd.apache.org/) with [Modsecurity](https://www.modsecurity.org/) on Debian stable ("stretch" at the moment).

It allows you to serve your application behind a WAF

*This image is able to run with a read-only filesystem.*

Interfaces
----------

The image exposes the HTTP (80) and HTTPS (443) ports

Volumes
----------------

The image needs 2 volumes:

* /etc/apache2/sites-enabled: Contains your configurations files to serve the application
* /run/apache2: Contains the runtime files. This volume is required to allow the container to run with a read-only filesystem

Configuration
----------------

By default, to prevent any disruptive beharior, the [Modsecurity engine](https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-%28v2.x%29#SecRuleEngine) does not take any action upon suspicious requests. So does this image.

To enable the engine, set the `MODSEC_SecRuleEngine` environment variable to `On`.

The [recommanded rules](https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-%28v2.x%29#a-recommended-base-configuration) are used by default with some ajustments to fit in the docker environment.

You can override the rules by adding a configuration file in those folders:

* `/etc/modsecurity/rules.pre` (Configurations imported before the default one)
* `/etc/modsecurity/rules.post` (Configuration imported after the default one)

For instance you can bypass a rule for a specific path

```apacheconf
# /etc/modsecurity/rules.post/app-ignore-sqlinj.conf
<LocationMatch "^/app/">
    # Ignore SQLInj in /app/*
    SecRuleRemoveById 942100
</LocationMatch>
```

Usage
-----

To try the container, use the following command. It will start the container with a static page where you can try to execute some malicious requests (like: <http://localhost/?q=%27%20OR%20%271%27=%271>):

    docker run \
    --rm --name apache-modsecurity \
    -p 80:80 \
    -v /run/apache2 \
    --read-only \
    teid/apache-modsecurity

You can then use it with your applications, SSL and enabled modsecurity engine:

    docker run \
    --rm --name apache-modsecurity \
    -p 80:80 \
    -p 443:443 \
    -v /run/apache2 \
    -v /var/www/html:/my-apps-docs
    -v /etc/apache2/sites-enabled:/my-apps-conf \
    -v /etc/my-certs:/my-certs \
    -e MODSEC_SecRuleEngine=On \
    --read-only \
    teid/apache-modsecurity
