From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 08 Apr 2008 09:27:17 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <20080408092717.GB6265@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have not a big understanding of netfilter and so got several things
wrong in the last posting. Thank you for patience in clarifying these.

>>  * just curious about timeout for OPEN state: it is set to    a full 
>> working week (5 * 24 * 3600 seconds). There is this
>>    wrap-around of DCCP timestamps after 11.2 hours, so maybe
>>    the Open state can be curtailed.
>
> I just copied this part from the TCP helper because I didn't
> find a better value. Does the wraparound affect the maximum
> lifetime of a connection? Maybe it would make sense to decrease
> it in any case, I would expect applications using DCCP not
> to idle as long as TCP connections might.
>
DCCP uses a clock with a resolution of 0.00001 seconds (RFC 4340, 13.1).
It thus wraps around much faster than the TCP suggestion of using 1ms
timestamps (RFC 1323, 4.2.2(b)) that wrap around every 24.8 days.

It seems like this: timestamp is a 4-byte number, the 2^32 numbers need
to be split into two halves ("before", "after"), each number stands for
10 microseconds, so the maximum timespan without wrap-around is about
5.96 hours. When the timespan is longer than that, "after" can become
"before", i.e. there will be a glitch in RTT estimation and other parts
that rely on timestamps. The full wrap-around, where the clock reaches
the same value again, is after 11.9 hours.

However, the question is already resolved by the module's sysctl for
the Open state.


>> 	State Transitions in the original direction
>> 	=====================>>
>>  * DCCP-Request:
>>    - in state Respond (sRS -> sRS), the Request is illegal (Respond is server state)
>
> Yes, this is one of the differences that comes from sitting in
> the middle :) In the reply direction we transition from sRQ to
> sRS when receiving a Response. However, that response might not
> make it to the client or simply be late, in which case the request
> is retransmitted.
>
Yes that was my error and the transition is clearly correct.

I have a question regarding the original direction - currently it is
linked to the client which actively initiates a connection. DCCP 
suffers from the problem that peer-to-peer NAT traversal is not
really possible just because of this client/server division. There
is a proposal which effects a pseudo simultaneous open, by letting
the server send an initiation packet, to fix this problem (TCP
peer-to-peer NAT traversal also favours simultaneous-open). I wonder
if this would be possible, but it is really a future-work question.
   

>> 	State Transitions in the reply direction
>> 	====================
>>
>>  * DCCP-CloseReq:
>>    - the transition from sCG is a simultaneous-close, which is possible
>>      (both sides performing active-close, server sends CloseReq after client has
>>       sent a Close) and has been seen on the wire, cf.
>>       http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/ )
>>    - use "ignore" here?
>
> In case the client needs to respond with another Close it should
> probably move to sCR. Otherwise I'd change it to stay (explicitly)
> in sCG. Ignore is mainly for resyncing.
>
Staying in sCG makes sense, in particular since RFC4340, 8.3 asks that a
Close must be sent in reply to each CloseReq (even when in state Closing).
So the client would retransmit its Close, which again would leave it in
sCG. When the server gets the second Close, it may already have received
the first one, thus it will respond with a Reset, Code 3 ("No Connection"),
which would then resolve the simultaneous-close into sTW.    

Gerrit


The University of Aberdeen is a charity registered in Scotland, No SC013683.

