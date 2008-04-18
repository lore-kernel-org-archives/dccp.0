From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 18 Apr 2008 10:13:36 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080418101336.GA13526@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > There is a more serious problem here: apparently no one tried to compile
| > the `qpolicy' subtree since the changes on Monday. It fails with the
| > BUILD_BUG_ON.
| >
| > I tried yesterday evening and found that there is not even a possibility
| > of adding a single field to struct dccp_skb_cb: with the addition of the
| > inet{,6}_skb_parm, the struct has reached its maximum size of 48 bytes
| > (try printk("%u", sizeof(struct dccp_skb_cb));).
| >
| > There is a solution to this, will post a revised patch shortly.
| >
| What you proposed in the patch should work ok for qpolicies for now. But 
| sooner or later the need to add a field to struct dccp_skb_cb will arise. So 
| maybe we should think about it now...
| Other possibility apart from what you proposed in the patch is creating struct 
| dccp_skb_cb_ext, move to it some fields from struct dccp_skb_cb and in struct 
| add a pointer to this new struct dccp_skb_cb_ext. Ok, maybe it is not the 
| prettiest idea but in case somebody needs yet another additional field in 
| struct dccp_skb_cb_ext it would be nice to have an idea how to do it.
| 
When the patch failed to compile I thought about those alternatives.
Trying to extend the dccp_skb_cb over and above what is in there will be
messy, since the IPv4/v6 parameters are required by other subsystems.

And the parts that are already in there are needed by DCCP: sequence/Ack
number, reset code and reset data, packet type and CCVal are required 
information to build the packet.


| > With regard to your point above: I think there is a way of keeping the
| > framework open without bending over backwards to ensure the binary
| > compatibility.
| >
| While we are developing in the test tree compatibility is not important at 
| all. But real world needs compatibility, especially if it's not that 
| expensive. Otherwise people will get weird behaviour without any messages 
| indicating what is wrong. And it's certainly not how code should be written. 
| It can't be that binary package of VLC (or any other streaming server) cannot 
| use newer kernel version because we added a new field.
| 
True, but we need to get something working first. There is no point
exporting an API which only works half.

In this regard, another problem with the patch has arisen: the type of
passing priority information will not work on 64-bit architectures in
compatibility mode.

Thanks to an answer by David Miller I found this out today. You can
verify this problem by running the patch e.g. on a sparc64 system: no
packets will be sent, sendmsg() returns with EINVAL.

I am working on this and hope to have something workable tomorrow or
otherwise it will be later next week.


| > My question for you in this regard: which policy can you think of whose
| > priorities/preferences can not be mapped into an unsigned 32-bit
| > integer? I think that such a number is sufficiently expressive enough
| > to cater for a wide range of policies. It can be interpreted as
| >  * symbolic value (enum)
| >  * ascii string (similar to DCCP service code)
| >  * millisecond timeout (with room for up to 7 weeks)
| >  * microsecond timeout (with room for up to 1.19 hours)
| >  * priority values (the large range 0..2^32-1 can be partitioned)
| >  * ... ?
| >
| Putting any of those values in an integer is pretty straightforward. But when 
| you want to put both timeout and priority things get messy. Would it be 
| possible at least to use structure like that:
| struct dccp_packet_info
| {
| 	s8	priority;
| 	u16	timeout_mantissa:10;
| 	u16	timeout_exponent:6;
| }
| ? That would still fit in 32-bit integer (so could be stored in 
| skb->priority), but would provide a much cleaner interface.
| -- 
Yes that is possible. It need not be a struct, the same effect can be
achieved with bit shifts and bitmasks (this is the way the Ack Vectors
are encoded).

Semantically there is no restriction of what the u32 number represents. And
it is a large space. I don't think that a larger size is required.

And it makes the implementation much simpler, by reusing a field which is
already there and which matches the purpose.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

