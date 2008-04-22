From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Apr 2008 17:30:50 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080422173050.GC6039@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| If inet{,6}_skb_parm is used only outside DCCP code then why at all should it 
| be placed in struct dccp_skb_cb taking up quite a lot of valuable space? Why 
| not put it directly in struct sk_buff? Especially that it is present in 
| struct udp_skb_cb, struct tcp_skb_cb as well.
| 
With or without inet{,6}_sbk_parm there are a further unused 32 bits in the cb -- by
restricting the 48-bit sequence/ack numbers from their current u64 type to 48 bit
only.  This requires to change the parts which rely on DCCP_PKT_WITHOUT_ACK_SEQ,
but that seems possible to do. 
So we can reduce this to the other question "is 32 bit enough for priority information".


| > | While we are developing in the test tree compatibility is not important
| > | at all. But real world needs compatibility, especially if it's not that
| > | expensive. Otherwise people will get weird behaviour without any messages
| > | indicating what is wrong. And it's certainly not how code should be
| > | written. It can't be that binary package of VLC (or any other streaming
| > | server) cannot use newer kernel version because we added a new field.

| >
| > True, but we need to get something working first. There is no point
| > exporting an API which only works half.
| >
| You can never assume that the API is feature complete. Even if it "works half" 
| at the beginning (which is I guess quite normal) it should be easy to make 
| it "work full" without breaking compatibility when it's not necessary.
| 
No I don't agree. Things that work half are worse than constant failures, since
it is never clear when they will fail next. But maybe you didn't mean that.


| > In this regard, another problem with the patch has arisen: the type of
| > passing priority information will not work on 64-bit architectures in
| > compatibility mode.
| >
| > Thanks to an answer by David Miller I found this out today. You can
| > verify this problem by running the patch e.g. on a sparc64 system: no
| > packets will be sent, sendmsg() returns with EINVAL.
| >
| I don't have any 64 bit system at hand...
| Does David's suggestion mean that changes are only required in userspace 
| application or on the kernel side as well?
| 
In both -- I will send an update in reply to this message and a link to
some user code. Very busy right now.


| > | struct dccp_packet_info
| > | {
| > | 	s8	priority;
| > | 	u16	timeout_mantissa:10;
| > | 	u16	timeout_exponent:6;
| > | }
| > | ? That would still fit in 32-bit integer (so could be stored in
| > | skb->priority), but would provide a much cleaner interface.
| > | --
| >
| > Yes that is possible. It need not be a struct, the same effect can be
| > achieved with bit shifts and bitmasks (this is the way the Ack Vectors
| > are encoded).
| >
| Yes, it can be achieved by bit operations. But to me a structure is a much 
| cleaner way. And that is especially important when designing interfaces. 
| Final effects should be the same but when using structure it is the compiler 
| that takes care of low level bit operations.
| 
You are free to use what you think is best. But I think both ways are
equivalent, using e.g. typecasts to get from one to the other. I.e. 
I think we have no disagreement here.

| > Semantically there is no restriction of what the u32 number represents. And
| > it is a large space. I don't think that a larger size is required.
| >
| Ok, for now 32 bits are enough and I can't think of the need to use more bits. 
| I wouldn't be so sure about future though. But ok, if it turns up that we 
| need more space in the future then we will see, there is no need to worry 
| about it now. We can indeed assume 32 bits for now.
| -- 
So it only remains to see whether to use a field in dccp_skb_cb, or to
use skb->priority. I think the latter has advantages, since this field
is only set/used for the SO_PRIORITY field (in socket(7)).


The University of Aberdeen is a charity registered in Scotland, No SC013683.

