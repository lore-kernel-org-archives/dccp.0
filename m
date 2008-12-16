From: David Miller <davem@davemloft.net>
Date: Tue, 16 Dec 2008 21:32:00 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081216.133200.229085084.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 16 Dec 2008 09:19:08 -0200

> I guess that looking at tcp_set_congestion_control() could be a good
> start. 8-)

Certainly.

But it seems to me we are dealing with a different situation here
in DCCP.

On the TCP side we have:

1) A default congestion control module, already loaded and
   which has been selected by the admin via a sysctl setting.

2) A socket option facility to select a non-default congestion
   control algorithm to use.

These are both outside of the fast path.

Whereas the DCCP case is right in the connection creation fast path
and unconditionally executes, because it is trying to figure out what
CCID algorithms it can advertise.
