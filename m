From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Mar 2008 15:01:03 +0000
Subject: Re: packet priorities
Message-Id: <20080310150103.GE7984@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Alessio:
| 
| > > Two ideas with regard to reproducing:
| > >  1. The excellent little D-ITG traffic generator
| > >     http://www.grid.unina.it/software/ITG/
| > >     It has DCCP support and packet timing can be set as a random variable,
| > >     which can be bound to a random seed (to reproduce test runs).
| > > 
| > That might be useful. I'll just have to check if it is possible to count which 
| > packets arrived at the destination end so that mixed audio/video stream 
| > simulation can be done.
| 
| 
| For sure it is. Both D-ITG sender and receiver can log different
| information (i.e. packet id, sending and receiving time, and size) 
| for each sent and received packet.
| Please, have a look at it and do not hesitate to contact me for any
| question.
| 
I think that we can use your input in this matter. From the application
perspective, what alternatives do you see in specifying an upper bound
on the packet lifetime.

The problem is that with the current socket API and a non-constant
inter-packet gap, all packets which are submitted "too early" will
suffer EAGAIN and then be dropped.

So the current dropping policy of the internal TX buffer is "tail drop".
By specifying priorities this can be improved to "drop worst packet
first".

The question here is, when the interpacket gap value is, say `IPG',
and IPG is distributed according to some distribution, is is possible to
specify a timeout value `timeout', i.e. setting
	      IPG' = IPG + timeout?

One could set this up such that timeout/IPG < delta, where delta is
the maximum error, say 5%?

Does this make sense - are there other/better suggestions?
