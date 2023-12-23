Once Biboumi is installed you can use any XMPP client software to join IRC channels. Any IRC channel is seen as a standard XMPP chatroom (aka MUC) with a special name.  
The the name is formatted like this: `#channelname%ircservername@biboumi.yourdomain.tld`.

For example, if you have a YunoHost server hosting domain *example.net* and you want to join the channel *#yunohost* on *irc.freenode.net* you simply need to join the MUC `#yunohost%irc.freenode.net@biboumi.example.net`.

* You can configure Biboumi with the file `/etc/biboumi/biboumi.cfg`.
