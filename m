From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Sep 2008 04:24:50 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080903042450.GA4105@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > So I'd like to wait and give him the chance to provide that feedback.
| 
| 
| Hi,
| 
| 	Thanks Dave, but now there is also Wei looking over this patch
| set, I'll try to get back to this soon, but I'm busy with other stuff, so if
| you think it is ok don't wait too much for me :-)
| 
| 	I just would love if the core code doesn't get things that are
| specific to a particular CCID implementation, as I saw in this patchset in
| the net/dccp/feat.c file. struct ccid and ccid_operations were designed
| to avoid that.
| 
So how long should we wait? I am willing to address all reasonable
comments, but it is not true that there has been no time for providing
feedback. The patches were first submitted last October, and if this
means waiting for another year while the patches in the test tree keep
piling up then I will need to draw a line.
Dave what would you like to do?

Arnaldo, I am answering the point raised above as a separate answer in
the thread were it was originally raised. The suggestion to separate out
the dependency table is something which only arose last week. In fact
the current format of the dependency table is thanks to your comments in
http://www.mail-archive.com/dccp@vger.kernel.org/msg02548.html
(October 2007), where this split was not suggested.

Gerrit
