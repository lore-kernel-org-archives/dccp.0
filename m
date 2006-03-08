From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Wed, 08 Mar 2006 16:08:53 +0000
Subject: Re: Report: feat negot state
Message-Id: <440F0195.70002@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
In-Reply-To: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi guys!

Andrea Bittau wrote:
> good.  only 2 queues:  one for "pending changes" and one for confirms.  You
> might have wondered why i had a "confirm" inside the pending change queue
> itself, and then a seperate confirm queue.
> 
> Basically, because i coded server priority features first, and then
> non-negotiable.  With NN features, you need to send confirms even for stuff you
> don't know about [or something like that] so i didn't know where to shove the
> confirm =D

I don't quite understand this.  If you don't know about the feature, then how 
can you tell whether it is NN?

> Anyway, it's much better like this [i was planning to do it at some point, but i
> just "died"]
>  
>  
>  	/* Check if nothing is being changed. */
> -	if (ccid_nr = new_ccid_nr)
> +	/* XXX handle multibyte values */
> +	if (ccid_nr = *val)
>  		return 0;
> 
> 
> ccid can only be 1 byte.  kill comment.  assert(len = 1);

It is worth pointing out here that ALL server-priority features specified in 
DCCP so far use one byte values.  So I'd just hold off implementing multi-byte 
SP features.

> +	rc = dccp_feat_change(dmsk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
> +			      &dmsk->dccpms_ack_ratio, 1, gfp);
> 
> ack ratio is 2 bytes i think.

Yep.

> 1) Merge it
> 2) I'll try to re-write the multi-byte feature support patch.  I believe this is
>    important functionality which is missing.

For NN features, yes.

> So now feature negotiation is moved into the minisock stuff.  I don't know what
> it means exactly, but i think the minisock stuff is the socket created upon
> receiving a SYN... i.e. a half open connection.  The idea is to keep as little
> state as possible in order to avoid SYN floods and other lame dos attacks.
> 
> While I was writing feature negotiation, I spotted quite a nice dos attack.
> Actually, probably it sucks, but here it is.
> 
> The idea is that when you send a REQUEST, you can include your CHANGE options.
> The server will RESPOND with the various CONFIRM options.  Here are the nice
> implications of this:
> 
> * The server must remember which CONFIRMs it sent.  [In fact, the previous code
>   was bugged because of this I think---it would remember the features of ALL
>   clients in a single socket... anyway.]
> 
>   This means that the server must not trash memory, it has to hold some state,
>   and potentially even setup those options.  E.g. it might have to load a CCID,
>   etc etc.

The Init Cookie option lets the server package up all that state, send it to 
the client, and forget it.  The server might still have to load a CCID, but 
that doesn't worry me -- we only have 3 CCIDs.

> * The server must actually calculate the CONFIRMS.  With server priority, the
>   calculation works as follows:  Given preference list C and S of the client and
>   server respectively, the winning value is the first value which appears in S
>   and also in C.
> 
>   Basically:
> 
>   for each s in S
>     for each c in C
>       if (s = c)
>         w00t();

It's not that bad.  (1) All feature negotiation options are limited to 252 
bytes of feature value at most.  (2) All current SP features are one-byte 
valued.  So you can do this.

     uint32_t bitmap[8] = { 0, 0, 0, 0, 0, 0, 0, 0 }; // 256 bits
     for each c in C
       turn on corresponding bit in bitmap;
     for each s in S
       if corresponding bit in bitmap is true
         w00t();

O(n^2) -> O(n).

For multi-byte SP features (if they ever exist), this trick doesn't work, but 
the DOS is less serious, since the maximum preference list length is 1/2 (1/3, 
1/4...) as long.

E
