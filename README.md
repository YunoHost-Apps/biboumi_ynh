# Biboumi app for Yunohost


<!--
[![Integration level](https://dash.yunohost.org/integration/biboumi_ynh.svg)](https://ci-apps.yunohost.org/jenkins/job/REPLACEBYYOURAPP%20%28Community%29/lastBuild/consoleFull)
[![Install biboumi_ynh with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=REPLACEBYYOURAPP)
-->

> *This package allows you to install biboumi quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview

Biboumi is an XMPP gateway for the IRC network.

Once biboumi_ynh is installed you can use any XMMP client software to
join IRC channels. Any IRC channel is seen as a standard XMMP chatroom
(aka MUC) with a special name.  
The the name is formatted like this: `#channelname%ircservername@biboumi.yourdomain.tld`.

For example, if you have a yunohost server hosting domain *example.net*
and you want to join the channel *#yunohost* on *irc.freenode.net* you
simply need to join the MUC `#yunohost%irc.freenode.net@biboumi.example.net`.

**Shipped version:** 8.0

## Configuration

How to configure this app: by an admin panel, a plain file with SSH, or any other way.

## Documentation

 * Official documentation: https://lab.louiz.org/louiz/biboumi/blob/8.0/doc/biboumi.1.rst

## Limitations

* Currently, biboumi is only tested with one domain and it must be the main domain of your yunohost server.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/biboumi_ynh/issues
 * App website: Link to the official website of this app
 * YunoHost website: https://yunohost.org/
