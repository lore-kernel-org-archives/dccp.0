From: gerrit@erg.abdn.ac.uk
Date: Wed, 04 Mar 2009 11:45:39 +0000
Subject: Re: [PATCH] dccp: ensure gap does not become unsigned -1
Message-Id: <35998.148.187.160.35.1236167139.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <49AD9217.8020206@gmail.com>
In-Reply-To: <49AD9217.8020206@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[added missing copy to netdev@vger]

> Is this maybe necessary?
> ------------------------------>8-------------8<---------------------------------
> if packets is 0, becomes -1, but since gap is unsigned, the test 'gap > 0'
> does not work.
>
Thank you for looking through. It is not necessary, see below.

> --- a/net/dccp/ackvec.c
> +++ b/net/dccp/ackvec.c
> @@ -207,7 +207,11 @@ static inline int
> dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
>  	if (av->av_vec_len + packets > DCCP_MAX_ACKVEC_LEN)
>  		return -ENOBUFS;
>
> -	gap	 = packets - 1;
> +	if (packets > 0)

Why 'gap < 0' <=> packets < 0 can not happen:

/*
 * If several packets are missing, the HC-Receiver may prefer to enter
multiple
 * bytes with run length 0, rather than a single byte with a larger run
length;
 * this simplifies table updates if one of the missing packets arrives.
 */
static inline int dccp_ackvec_set_buf_head_state(struct dccp_ackvec *av,
                                                 const unsigned int packets,
                                                 const unsigned char state)

This is a static routine which is called in one place only in
net/dccp/ackvec.c, in dccp_ackvec_add():
//...
} else if (after48(ackno, av->av_buf_ackno)) {
                const u64 delta = dccp_delta_seqno(av->av_buf_ackno, ackno);

                /*
                 * Look if the state of this packet is the same as the
                 * previous ackno and if so if we can bump the head len.
                 */
                if (delta = 1 &&
                    dccp_ackvec_state(av, av->av_buf_head) = state &&
                    dccp_ackvec_len(av, av->av_buf_head) <
DCCP_ACKVEC_LEN_MASK)
                        av->av_buf[av->av_buf_head]++;
                else if (dccp_ackvec_set_buf_head_state(av, delta, state))
                        return -ENOBUFS;

=> We thus have:
 1) after48(a, b) => sequence number `a' is `after' b
 2) sequence number `a' is `after' `b' =>  dccp_delta_seqno(b, a) > 0
 3) hence delta > 0
 4) hence delta - 1 = gap >= 0
 5) The subsequent `else' in dccp_ackvec_add() catches the case
    of !after48(a, b), note the reversed order of arguments to
    dccp_delta_seqno, so that a positive value is returned:

    } else {
                /*
                 * A.1.2.  Old Packets
                 *
                 *      When a packet with Sequence Number S <= buf_ackno
                 *      arrives, the HC-Receiver will scan the table for
                 *      the byte corresponding to S. (Indexing structures
                 *      could reduce the complexity of this scan.)
                 */
                u64 delta = dccp_delta_seqno(ackno, av->av_buf_ackno);


    => But this is in an entirely different block of code outside the
        one to which this patch was meant.

Hence it is not necessary.



