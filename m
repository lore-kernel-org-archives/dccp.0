From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 21:44:47 +0000
Subject: Re: [PATCH 9/25] Adapt CCID-4 according to the latest changes to CCID-3
Message-Id: <5bc4c4570711011444p44e91ac2i48fb7e2c8641ec7d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.35629.leandroal@gmail.com>
In-Reply-To: <200710312130.35629.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/11/1, Tommi Saviranta <wnd@iki.fi>:
> On Wed, Oct 31, 2007 at 21:30:35 -0300, Leandro wrote:
> > [CCID-4] Adapt CCID-4 according to the latest changes to CCID-3
> >
> > Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
>
> Another hit from whitespace police. This isn't really about Leandro's
> code, but generally about whitespace usage in Linux kernel. Obviously
> people prefer aligning things:
>
> >       .ccid_owner                = THIS_MODULE,
> >       .ccid_hc_tx_obj_size       = sizeof(struct ccid4_hc_tx_sock),
> >       .ccid_hc_tx_init           = ccid4_hc_tx_init,
>
> Sometimes tabulators are used to fill up most of the gap, followed by
> spaces (like in this case). Sometimes only spaces are used, even for
> gaps longer seven characters. Is there a general consensus about this?
> Do the spaces/tabs just get mixed as the code evolves?
>
> > Index: leandro.new/net/dccp/ccids/ccid4.h
> > =================================> > --- leandro.new.orig/net/dccp/ccids/ccid4.h
> > +++ leandro.new/net/dccp/ccids/ccid4.h
> > @@ -128,10 +128,9 @@ struct ccid4_hc_tx_sock {
> >
> >  static inline struct ccid4_hc_tx_sock *ccid4_hc_tx_sk(const struct sock *sk)
> >  {
> > -     void *ccid4_tx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
> > -
> > -     BUG_ON(ccid4_tx_priv = NULL);
> > -     return ccid4_tx_priv;
> > +    struct ccid4_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
> > +    BUG_ON(hctx = NULL);
> > +    return hctx;
> >  }
> >
> >  /* CCID4 receiver states */
> > @@ -177,10 +176,9 @@ struct ccid4_hc_rx_sock {
> >
> >  static inline struct ccid4_hc_rx_sock *ccid4_hc_rx_sk(const struct sock *sk)
> >  {
> > -     void *ccid4_rx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
> > -
> > -     BUG_ON(ccid4_rx_priv = NULL);
> > -     return ccid4_rx_priv;
> > +    struct ccid4_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
> > +    BUG_ON(hcrx = NULL);
> > +    return hcrx;
> >  }
>
> At least this is obvious. Tabulators should be used for indentation
> here. These inline functions finally ended up in lib/tfrc_ccids.h.
>
>

I think that we can now concentrate our efforts on the ccid-4
implementation and pay attention for the next coding. As you said,
many of the code is from ccid-3, then my suggestion is to focus the
job on the ccid-4 implementation and ccid-3/4 code sharing. After
we can quickly solve issues related to code style, what do you think?

Leandro
