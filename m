From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Apr 2008 13:10:47 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080428131047.GB14346@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | > True, but we need to get something working first. There is no point
| > | > exporting an API which only works half.
| > |
| > | You can never assume that the API is feature complete. Even if it "works
| > | half" at the beginning (which is I guess quite normal) it should be easy
| > | to make it "work full" without breaking compatibility when it's not
| > | necessary.
| >
| > No I don't agree. Things that work half are worse than constant failures,
| > since it is never clear when they will fail next. But maybe you didn't mean
| > that.
| >
| I mean that what we are currently discussing (only priorities) is in itself 
| useful ("works half"). Adding more features (expiry times) would be a nice 
| but non essential feature ("work full").
| 
It seems I misunderstood you, and agree that with regard to API it is
better to have a little too much discussion than too little, there are
many aspects to consider.



| (a bit of reordering)
| > So we can reduce this to the other question "is 32 bit enough for priority
| > information".
| >
| That is an important question. But I'm afraid the answer is no (even though I 
| thought otherwise when writing previous mail). When we want to add packet 
| expiry times we will need a field for timestamp. Which is quite big (64 
| bits?). But note that it is only needed for in-kernel implemetation. 
| Userspace can write this information on as low as 16 bits. This leads me to 
| conclusions stated below.
| 
I had the same thoughts - it is easy to end up with a wide range of
possible structs, numbers, etc. that are not related and require 20
different APIs. 
But the basic line of thought is 
 * the queue size is always limited since afaik the amount of skbs that 
   can be queued depends on the socket's write memory (wmem);
 * hence a strict priority ordering can be done even with u8 (up to 255)
   in not-too-extreme case
 * for timeouts, it is not necessary to use struct time{val,spec} (as
   also above); if really required, a conversion can be done by a
   library (but not a kernel) routine.


| > So it only remains to see whether to use a field in dccp_skb_cb, or to
| > use skb->priority. I think the latter has advantages, since this field
| > is only set/used for the SO_PRIORITY field (in socket(7)).
| >
| I think we should distingish two things:
| 1. How do we pass data along with each packet from userspace to kernelspace.
| 2. How do we store data in in-kernel skb for internal use.
<snip>
| 
| Ad 1. In this case we need not care about sizes etc. Clean and extensible 
|       interface is very important. We can also have very different priority data 
|       representantion from what is later stored in skb.
| Ad 2. In this case sizes do matter. We can use whichever fields we want. In 
|       particular we need not keep all the data passed from userspace application in 
|       one chunk but we can distribute it among arbitrary skb fields.
| 
| So this could look like that:
| Userspace application fills in a structure:
| struct dccp_packet_info {
| 	s8 priority; //as it is now
| 	u16 expire_after; //up to 65s with 1ms accuracy
| }
| and passes it to sendmsg(..., struct dccp_packet_info pktinfo), which passes 
| it to qpolicy_push which passes it to qpolicy_prio_push which does the tricky 
| stuff with CMSG and does:
| skb->priority=pktinfo->priority;
| skb->tstamp=now()+pktinfo->expire_after;
| (possibly other things that could potentially store data in dccp_skb_cb)
I notice you have discovered another skb field that could be reused :)
The idea looks good, if you decide to go ahead with it, please just make
sure to document it (and that is a reminder for myself too).
| 
| This would allow us to:
| 1. Use existing skb fields in a clean way. I mean according to their names 
|    (priority, tstamp).
| 2. Have a clean userspace interface not affected by internal kernel 
|    implementation details.
| 
| What do you think of such decoupling?
| -- 
Yes, great. The concept is good, it is some of the details that need
some more work. In (2) you mention distributing the information among
several skb fields. With regard to above comment, I think we need to do
this with some care, to avoid interactions with other subsystems. 

At the moment I have no concrete idea of how to implement a timeout-based
policy ... probably this is something along the line of Ian's patches
and what you sketched above.

Also in (2) is the size question. The bottom line is if 2^32-1 different
numbers are sufficient to represent a range of policies, then we can
work with skb->priority for the moment.

My understanding of the above is
 * the per-policy data is an opaque bitstring whose only requirement
   is that it fits within 32 bits;
 * how the bitstring is interpreted depends on the chosen policy;
 * not necessary to always use the full 32 bits (also in your example
   above).

I have a tidied-up version of the changes so far which will be posted
later, also with comments on your patch.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

