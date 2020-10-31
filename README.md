# Biboumi for YunoHost

[![Integration level](https://dash.yunohost.org/integration/biboumi.svg)](https://dash.yunohost.org/appci/app/biboumi) ![](https://ci-apps.yunohost.org/ci/badges/biboumi.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/biboumi.maintain.svg)  
[![Install biboumi with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=biboumi)

> *This package allows you to install Biboumi quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview

Biboumi is an XMPP gateway for the IRC network.

Once biboumi_ynh is installed you can use any XMPP client software to join IRC channels. Any IRC channel is seen as a standard XMPP chatroom (aka MUC) with a special name.  
The the name is formatted like this: `#channelname%ircservername@biboumi.yourdomain.tld`.

For example, if you have a YunoHost server hosting domain *example.net* and you want to join the channel *#yunohost* on *irc.freenode.net* you simply need to join the MUC `#yunohost%irc.freenode.net@biboumi.example.net`.

**Shipped version:** 8.3

## Configuration

You can configure Biboumi with the file `/etc/biboumi/biboumi.cfg`.

## Documentation

 * Official documentation: https://lab.louiz.org/louiz/biboumi/blob/8.3/doc/biboumi.1.rst

#### Supported architectures

* x86-64 - [![](https://ci-apps.yunohost.org/ci/logs/biboumi%20%28Community%29.svg)](https://ci-apps.yunohost.org/ci/apps/biboumi/)
* ARMv8-A - [![](https://ci-apps-arm.yunohost.org/ci/logs/biboumi%20%28Community%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/biboumi/)

## Limitations

* Currently, Biboumi is only tested with one domain and it must be the main domain of your YunoHost server.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/biboumi_ynh/issues
 * App website: https://biboumi.louiz.org/
 * Upstream app repository: https://lab.louiz.org/louiz/biboumi/-/issues
 * YunoHost website: https://yunohost.org/

 ---

## Developer info

Please send your pull request to the [testing branch](https://github.com/YunoHost-Apps/biboumi_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/biboumi_ynh/tree/testing --debug
or
sudo yunohost app upgrade biboumi -u https://github.com/YunoHost-Apps/biboumi_ynh/tree/testing --debug
```
