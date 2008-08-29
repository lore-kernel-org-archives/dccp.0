From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 29 Aug 2008 05:54:36 +0000
Subject: Re: [PATCH 06/37] dccp: Limit feature negotiation to connection
Message-Id: <20080829055436.GC3557@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > This patch starts the new implementation of feature negotiation:
| >  1. Although it is theoretically possible to perform feature negotiation at any
| >     time (and RFC 4340 supports this), in practice this is prohibitively complex,
| >     as it requires to put traffic on hold for each new negotiation.
| >  2. As a byproduct of restricting feature negotiation to connection setup, the
| >     feature-negotiation retransmit timer is no longer required. This part is now
| >     mapped onto the protocol-level retransmission.
| >     Details indicating why timers are no longer needed can be found on
| >     http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/\
| > 	                                      implementation_notes.html
| > 
| > This patch disables anytime negotiation, subsequent patches work out full
| > feature negotiation support for connection setup.
| 
| While I agree that its better to initially support only negotiation at
| connection startup, I wonder if the response to feature negotiation
| after connection startup should be plainly ignore the request or if we
| should reset the connection, telling the other side that what it wants
| to do is not implemented currently.
| 
The implementation will ignore any peer-attempt at feature negotiation
as soon as the connection has reached established (OPEN/PARTOPEN) state.

This is done in dccp_feat_parse_options() which is shown for reference below.

Considering doing a reset is something we could consider when it comes
to Interoperability tests; it may be that the current policy of ignoring
is sufficient.

There are two main points that I think are important here:
 1. At the begin of the connection, both endpoints really negotiate their
    capabilities, i.e. A says to B "I want to do X, but could do Y" and
    B says to A "can't do X, so will settle for Y".
    Doing the same in the middle of an established connection seems mad
    to me - for example changing the CCID in mid-connection.
 2. There is an actual need for exchanging feature negotiation options
    even when the connection is established. But this is past the
    checking-capabilities phase and the only known uses require NN
    (non-negotiable) options. In this case, if the peer does not
    understand, the reset will happen as a consequence of receiving an
    empty Confirm. However, in a well-behaved connection this will not
    occur, since both peers have negotiated their capabilities in (1).

The second point is actually not part of this patch set, it is in the
second set which I wanted to send after this one. 

Here is the parse routine as it is currently in the test git tree:

int dccp_feat_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
                            u8 mandatory, u8 opt, u8 feat, u8 *val, u8 len)
{
        struct dccp_sock *dp = dccp_sk(sk);
        struct list_head *fn = dreq ? &dreq->dreq_featneg : &dp->dccps_featneg;
        bool server = false;

        switch (sk->sk_state) {
        /*
         *      Negotiation during connection setup
         */
        case DCCP_LISTEN:
                server = true;                  /* fall through */
        case DCCP_REQUESTING:
                switch (opt) {
                case DCCPO_CHANGE_L:
                case DCCPO_CHANGE_R:
                        return dccp_feat_change_recv(fn, mandatory, opt, feat,
                                                     val, len, server);
                case DCCPO_CONFIRM_R:
                case DCCPO_CONFIRM_L:
                        return dccp_feat_confirm_recv(fn, mandatory, opt, feat,
                                                      val, len, server);
                }
                break;
        /*
         *      Support for exchanging NN options on an established connection
         *      This is currently restricted to Ack Ratio (RFC 4341, 6.1.2)
         */
        case DCCP_OPEN:
        case DCCP_PARTOPEN:
                return dccp_feat_handle_nn_established(sk, mandatory, opt, feat,
                                                       val, len);
        }
        return 0;       /* ignore FN options in all other states */
}

==> The first two cases are for the initial phase and allow
     full/unrestricted negotiation.
     The dccp_feat_handle_nn_established() is part of the second patch
     set and basically allows dynamic updates of NN (Sequence Window and 
     Ack Ratio).
     In all other cases, 0 is returned to dccp_parse_options(), which means
     that the option is merely eaten up, but not reacted on.
