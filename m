From: Alessio <a.botta@unina.it>
Date: Tue, 11 Mar 2008 23:00:01 +0000
Subject: Re: packet priorities
Message-Id: <1205276401.26089.146.camel@coroglio.comics.unina.it>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


On Mon, 2008-03-10 at 15:01 +0000, Gerrit Renker wrote:
> Quoting Alessio:
> | 
> | > > Two ideas with regard to reproducing:
> | > >  1. The excellent little D-ITG traffic generator
> | > >     http://www.grid.unina.it/software/ITG/
> | > >     It has DCCP support and packet timing can be set as a random variable,
> | > >     which can be bound to a random seed (to reproduce test runs).
> | > > 
> | > That might be useful. I'll just have to check if it is possible to count which 
> | > packets arrived at the destination end so that mixed audio/video stream 
> | > simulation can be done.
> | 
> | 
> | For sure it is. Both D-ITG sender and receiver can log different
> | information (i.e. packet id, sending and receiving time, and size) 
> | for each sent and received packet.
> | Please, have a look at it and do not hesitate to contact me for any
> | question.
> | 
> I think that we can use your input in this matter. From the application
> perspective, what alternatives do you see in specifying an upper bound
> on the packet lifetime.
> The problem is that with the current socket API and a non-constant
> inter-packet gap, all packets which are submitted "too early" will
> suffer EAGAIN and then be dropped.
> 
> So the current dropping policy of the internal TX buffer is "tail drop".
> By specifying priorities this can be improved to "drop worst packet
> first".
> 
> The question here is, when the interpacket gap value is, say `IPG',
> and IPG is distributed according to some distribution, is is possible to
> specify a timeout value `timeout', i.e. setting
> 	      IPG' = IPG + timeout?
> 
> One could set this up such that timeout/IPG < delta, where delta is
> the maximum error, say 5%?
> 
> Does this make sense - are there other/better suggestions?

Implementing the timeout mechanism in D-ITG should be quite simple. And
calculating the timeout as a percentage of the IPG is also simple.
However, I think this approach can slow down a bit the generation
process. In the sense that, for each packet, a different timeout may be
specified, which causes calling some set_timeout function very
frequently for high packet rates. 

Moreover, from a real application point of view, the usefulness of
having a timeout that is a percentage of the IPG is not clear to me.
Roughly speaking, D-ITG extract the IPG from a random number generator,
waits for that IPG, and then issues a "send" putting the packet into the
socket buffer. This is to emulate the behavior of the applications (e.g.
VoIP or WEB clients) which perform "send" function calls according to
certain models (e.g a constant time for VoIP or a kind of random for
other applications). Setting the timeout as a percentage of the IPG will
surely help D-ITG to be more accurate in replicating the application
behavior, which is good for a traffic generator. However, it could be
not as good for a real application, e.g. a VoIP client, which should
prefer to have a fixed timeout for all its packets, regardless of the
IPG. What do you think ?

AB

