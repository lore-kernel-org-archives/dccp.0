From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 May 2008 10:02:46 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080522100246.GB4827@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| But when it gets into mainline people should be able to write applications 
| that will be forward and backward compatible (as far as possible) with 
| various kernel versions.
| 
The main answer to that is below, but compare for instance with TCP -
few socket options need runtime discovery. The type of their parameters
and their option values are all described in a manpage. On the other
hand, I like your approach of trying to come up with a novel solution.

| > DCCP is full of half-finished things. 
| That's why I'm trying to finish the qpolicy framework. Without providing 
| runtime information it will turn out that application developers will be 
| afraid to use new features just because the application won't be able to 
| check if given parameter is supported or not.
| 
And you have done a good job so far, it is a very useful addition.


| > I would much prefer to keep this 
| > as simple as at all possible, to have time/room to fix the missing parts
| > (such as no ECN support) in DCCP.
| >
| I understand that there might be some missing features in DCCP that are more 
| important than yet another informational getsockopt. But these features are 
| IMO highly independent and can be developed in parallel.
| 
Agreed.

| > As a possible suggestion, I came up with a minimalistic variant of
| > querying the interface - only 7 lines, including documentation.
| >
| > This is attached and it works by exploiting that
| >  * policy IDs are just numbers;
| >  * so that we could use the highest supported ID instead of an array;
| I don't like the "highest supported ID" approach. But if you don't like arrays 
| a simple "bool getsockopt" would do, we could just ask the kernel if it 
| supports given qpolicy. Like (in pseudocode):
| bool supports_prio=getsockopt(sk,DCCP_SOCKOPT_QPOLICY_AVAILABLE,QPOLICY_PRIO);
| Would that be ok?
| 
What I sent is just a sketch, nothing set in stone. I am happy to take
my patch out of the repository if there are better solutions.


| >  * parameters are tied to the individual policy, so that a second
| >    query (about which parameters are supported) is not necessary.
| >
| Can you guarantee that nobody ever will add a parameter? In fact even today I 
| can think of two parameters that could be added: the previously discussed 
| timeout and my new concept - the identity or category parameter (which is a 
| subject for a separate thread).
| 
During the design phase it is almost certain to change several times.

When the design phase is over, it will have some parts that will not
likely change.

Hence I am trying to figure out - how much change is due to re-designing
things and how much change is de facto required for a useful dynamic
interface?

| BTW, the somewhat big code was meant to act as a framework for other features. 
| Like getting information about percent of dropped packets in prio qpolicy 
| queue.
| -- 
Ah - didn't understand what the qpolicy-specific getsockopt hooks were for.

I think there is a way of doing this, but it requires a bit more work. 
This would be to use netlink sockets to communicate/request/poll information. 

The two alternatives I am aware of are

 * kernel/userspace connector
   [ Documentation/connector/connector.txt ]
 * generic netlink interface
   http://www.linux-foundation.org/en/Net:Generic_Netlink_HOWTO

If done well, the interface could be very useful for several other
things in DCCP:
 * querying qpolicy interface (with regard to this email thread)	
 * querying the CCIDs (available, set preference list)
 * getting much-needed runtime statistics into user-space
   - this is a feature missing in UDP (and partly also TCP)
   - so far only via CCID-3 getsockopt (tx_info/rx_info)
   - there is research which says it would be nice to have the
     current RTT, loss statistics etc in user-space
 * thus calling for a generic solution.

What do you think about this alternative?

- Gerrit
