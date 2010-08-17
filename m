From: gerrit@erg.abdn.ac.uk
Date: Tue, 17 Aug 2010 11:37:25 +0000
Subject: Re: Problems with idle DCCP connections
Message-Id: <54673.148.187.160.35.1282045045.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
In-Reply-To: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> | I do, however, see a bunch of messages like the following
>> | in /var/log/messages when using CCID-3: "dccp_sane_rtt: RTT sample
>> | 8644424 out of bounds!"
>> |
>> This message warns that the network has an unusually high RTT (8.64
>> seconds).
>>
>> The warning is issued whenever the RTT exceeds 3 seconds, to avoid that
>> the
>> sending rate of CCID-3 is reduced too much (since X is proportional to
>> s/RTT).
>>
>>  #define DCCP_SANE_RTT_MAX       (3 * USEC_PER_SEC)
>
> My network RTT is nowhere near 8 seconds; it should be ~1ms... I'm
> running my tests between VMs on the same machine... This must be a
> result of the TFRC algorithm you mentioned that penalizes connections
> with idle periods?
>
I am very interested in further details -- in particular, was it at the
receiver where this happened? If yes, then it is a bug in the way RTTs
are measured, and I would like to isolate its causes.

I think it very likely that this happened at the receiver: the sender
uses proper timestamps, which on (virtual) LANs with small RTTs are
rounded up to 0.1 millisecond.

What I think the bug is:
 * receiver uses CCVal window counter to estimate RTT
 * sender idles between sends
 * nofeedback timer triggers at sender, reduces rate, increases packet gap
 * receiver sees the inter-packet gap doubling and wrongly interprets this
   as inflated RTT

I'd be grateful for any more information to verify this.

