From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 31 Jan 2006 16:59:46 +0000
Subject: feature negotiation patch for linux
Message-Id: <20060131165946.GA13272@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

http://128.16.66.93/acme-dccp-feat.diff

[no domain name because it's expiring today =( ]

It's my initial "mega-patch, rough" implementation of feature negotiation for
linux, based on acme's tree.

It supports CHANGE_L, CHANGE_R via setsockopt from userland.
It will change / confirm.
It supports mandatory options.  [no support from userland yet though].
It supports re-transmission of change options.

TODO:
* getsockopt to poll for option status.
* setsockopt with a flag for mandatory options.
* actually change the option in the protocol itself.  Until now they are only
  negotiation and an empty function is called =D


Any comments are welcome.  I'll try to contact acme now, and hopefully stuff
will start getting merged.
