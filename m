From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 14 Dec 2007 13:56:07 +0000
Subject: Re: DCCP source code
Message-Id: <20071214135607.GC5329@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <026F8EEDAD2C4342A993203088C1FC050671452F@esealmw109.eemea.ericsson.se>
In-Reply-To: <026F8EEDAD2C4342A993203088C1FC050671452F@esealmw109.eemea.ericsson.se>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| It was suggested that should email you regarding open source code for DCCP. We are looking for open source code for DCCP for a master thesis which will start in february. In particular we are looking for implementations that support CCID4 and faster restart.
| Any help on this matter is welcome.
| 
The following may be useful
	http://www.linux-foundation.org/en/Net:DCCP
	http://www.linux-foundation.org/en/Net:DCCP_Testing
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/
	http://wand.net.nz/~iam4/dccp/

There is a CCID4 subtree written by Tommi Saviranta and Leandro Melo de Sales - contact them for
further information; the tree can be checked out via

	git checkout -b ccid4 master	# pull a recent netdev-2.6 first
	git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp ccid4

Ian McDonald has written an implementation of Faster Restart (contact Ian for further information);
this was also in form of a subtree. It is not currently online, but if there is interest, I am happy
to put up the patches as Faster-Restart subtree again. In any case, ask Ian what he is intending to do.
