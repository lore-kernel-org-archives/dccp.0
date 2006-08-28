From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Mon, 28 Aug 2006 07:05:34 +0000
Subject: Re: Fwd: CCID2 patches
Message-Id: <20060828070534.GA47640@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00608271718wce9b5fbwf5ecb33c62a8ab94@mail.gmail.com>
In-Reply-To: <5640c7e00608271718wce9b5fbwf5ecb33c62a8ab94@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Aug 28, 2006 at 12:18:33PM +1200, Ian McDonald wrote:
> It does raise the question though is whether the dccp mailing list is
> worth keeping separate? Thoughts?

I'm registered on dccp only because netdev is too noisy =D  I personally think
DCCP should gain more momentum before entering netdev.  Also, I still need to
understand if stuff can go directly to dave or through arnaldo, especially when
arnaldo gets killed with work.

> You need a description of each patch and signed off line in each
> patch. They can't be accepted in this form. Alternatively they could
> be resubmitted.

The proper email, patch and log description was sent a while back in the DCCP
mailing list.  About resubmitting, I hate insisting.  If people drop mail, there
probably is a reason.  It's one of my stubburn principles =P.

> Please state whether the target is 2.6.18 (bug fixes only) or 2.6.19
> (enhancements)

Some are bug fixes, but I'd send it all to .19.  It's a milestone patchset:
enable DCCP to do gbit [with ccid2 at least].

> Please state any dependencies between patches.

just apply them sequentially.  Most are independent.  I specifically put them in
an order "most likeley to be accepted -> most likeley to be rejected".  If you
notice, the early patches are bug fixes.  The latest patches are stuff like
"lets add profilin support".

> In patch 01_ackvec_opt:
> -int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
> +u64 dccp_ackvec_parse(struct sock *sk, u64 ackno,
>                      const u8 opt, const u8 *value, const u8 len)
> 
> This becomes a one line function. This is only used in one place that I can
> see so this should go and that code should go there... Also there is some

yea I agree.  I'll do it once I see that the first patch set starts getting
processed.

> weird shit going on as this is also defined as inline with return -1 in
> ackvec.h. This needs fixing as well.

I dunno wtf that is =D  That's some old debris that needs to get killed.

> In patch 05_ccid2_seq_alloc I don't get this code:
> If you are allocating an array of structures in effect you shouldn't
> need to set next/prev pointers as they are allocated contiguously. If

I am allocating records in a double linked list.  They will be moved around in
time, so I need the pointers to keep them in the order I wish.

> you are allocating groups of arrays, which I suspect you are, I still
> think the design is a bit ugly and wastes memory.

I agree it's ugly, but I'm not a guru.  I wouldn't know how to do it otherwise
[without spending time on it].  I maintain my own free-list of structures and
reuse them as necessary.  I don't think it wastes that much memory.  I do one
malloc for a bunch of structures.  Then I shove that pointer into a "recycle
bin" so I can free it at the end.  What would the alternative be?  One malloc
per structure?  That would probably waste more memory and CPU.

> In 06_ccid2_ssthresh you don't justify why ssthresh can be infinite to
> start off with. And if it is allowed then I don't think you should do

I think by definition you exist slow start when you hit packet loss.  I believe
this maps to an infinite sshtresh.

> this by just picking a random high number. Change it to something like
> ~0

I agree.  [The number is not random; the original choice I made was too low so I
had to repeat the digit.]

> In 07_ccid2_send_poll - changing to 1 msec poll is not nice. I now you
> said this should be dequeued. I've just added tx queuing to 2.6.19
> tree now so you can do this. Up to Dave/Arnaldo if this is OK as a
> short term solution.

I personally think CCID should call-back to DCCP, "yo dude, you can send".  What
polling frequency should I put there?  Intuitively it should be
time_when_next_ack_arrives - now.  But when is that time?  RTT/cwnd?

> In 08_ccid2_cwnd:
> I think that should be a ccid2_pr_debug not a dccp_pr_debug

agree.

> in 10_ccid2_change:
> in ccid2_change_srtt why do you do the test there because you are
> going to take twice as many instructions if you are going to alter. Is
> this to minimise sets?

yea to lower profiling information.  Many times the srtt doesn't change.  [Well
in lab environments.]

> in 11_ccid2_profile:
> in ccid2_profile_time the code there is ugly. I am guessing you are
> assuming 32 bit intel vs 64 bit intel. The world doesn't revolve
> around intel. If you need something architecture specific that should
> be put into the arch subtree not here.

I don't expect this to be merged.  Using a kprobe in the "change_X" functions
does the same.  I discovered kprobes later.  The refactoring to the change_X
methods chould be kept though.

> in ccid2_hc_tx_init why are you using 6000? What is the significant.
> Make it a constant defined somewhere.

Random number.  Again, the profiling was a hack to "see" CCID2.  It turned out
to be really useful when testing the high speed stuff
[tcp_cong_whateveritscalled].

Dude, thanks for ur time in this.  I'll address the issues I agreed on in this
mail when I see arnaldo, or anyone, playing and hopefully commiting these
patches.
