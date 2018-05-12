Docker Apache-Modsecurity
===================

A Docker image running [Apache2](https://httpd.apache.org/) with [Modsecurity](https://www.modsecurity.org/) on Debian stable ("stretch" at the moment).

It allows you to serve your application behind a WAF

*This image is able to run with a read-only filesystem with an unpriviledged user (`www-data`)*

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

To enable the engine, set the `WAF_MOD` environment variable to `block`.

The [recommanded rules](https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-%28v2.x%29#a-recommended-base-configuration) are used by default with some ajustments to fit in the docker environment.

You can override the rules by changing the following files:

* `/etc/modsecurity/modsecurity-detect.conf` (used if the container is in detection mod)
* `/etc/modsecurity/modsecurity-block.conf` (used if the container is configured to block the suspicious requests)

Usage
-----

To try the container, use the following command. It will start the container with a static page where you can try to execute some malicious requests (like: `http://localhost/?q=%27%20OR%20%271%27=%271`):

    docker run -d \
    -p 80:80 \
    -v /run/apache2 \
    -e WAF_MOD=detect \
    --read-only \
    apache-modsecurity

You can then use it with your applications, SSL and enabled modsecurity engine:

    docker run -d \
    -p 80:80 \
    -p 443 \
    -v /run/apache2 \
    -v /var/www/html:/my-apps-docs
    -v /etc/apache2/sites-enabled:/my-apps-conf \
    -v /etc/my-certs:/my-certs \
    -e WAF_MOD=block \
    --read-only \
    apache-modsecurity
