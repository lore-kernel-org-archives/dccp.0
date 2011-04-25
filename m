From: Leandro Melo de Sales <leandroal@gmail.com>
Date: Mon, 25 Apr 2011 16:52:23 +0000
Subject: Re: dccp test-tree [PATCH 1/1] ccid-2: still stuck with RFC 3390
Message-Id: <BANLkTi=bFngvnfBiPhKu5KXJUq_xtDjEug@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Fri, Mar 18, 2011 at 6:06 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrot=
e:
>
> There was a discussion earlier with Leandro to keep the current status of
> using RFC 3390 initial window settings, so I am updating accordingly.
>
> Ultimately it would be great to consider larger initial windows also for
> CCID-2, perhaps as a configurable compilation option. With 1GB/10GB ether=
net,
> this would make a conceivable difference.
>
> >>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp ccid-2: move rfc 3390 function into header file
>
> This moves the initial-window function, which came back when TCP's window
> was increased, into the header file. Several patches in the test tree
> rely on this function. Until there is agreement to put larger windows
> also into CCID-2, the function needs to be available in a top-level place.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
> =A0net/dccp/ccids/ccid2.c | =A0 =A09 ---------
> =A0net/dccp/ccids/ccid2.h | =A0 =A09 +++++++++
> =A02 files changed, 9 insertions(+), 9 deletions(-)
>
> --- a/net/dccp/ccids/ccid2.c
> +++ b/net/dccp/ccids/ccid2.c
> @@ -583,15 +583,6 @@ done:
> =A0 =A0 =A0 =A0dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
> =A0}
>
> -/*
> - * Convert RFC 3390 larger initial window into an equivalent number of p=
ackets.
> - * This is based on the numbers specified in RFC 5681, 3.1.
> - */
> -static inline u32 rfc3390_bytes_to_packets(const u32 smss)
> -{
> - =A0 =A0 =A0 return smss <=3D 1095 ? 4 : (smss > 2190 ? 2 : 3);
> -}
> -
> =A0static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct ccid2_hc_tx_sock *hc =3D ccid_priv(ccid);
> --- a/net/dccp/ccids/ccid2.h
> +++ b/net/dccp/ccids/ccid2.h
> @@ -88,6 +88,15 @@ static inline bool ccid2_cwnd_network_li
> =A0 =A0 =A0 =A0return hc->tx_pipe >=3D hc->tx_cwnd;
> =A0}
>
> +/*
> + * Convert RFC 3390 larger initial window into an equivalent number of p=
ackets.
> + * This is based on the numbers specified in RFC 5681, 3.1.
> + */
> +static inline u32 rfc3390_bytes_to_packets(const u32 smss)
> +{
> + =A0 =A0 =A0 return smss <=3D 1095 ? 4 : (smss > 2190 ? 2 : 3);
> +}
> +
> =A0struct ccid2_hc_rx_sock {
> =A0 =A0 =A0 =A0int =A0 =A0 rx_data;
> =A0};
>
> --
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

Acked-by: Leandro Melo de Sales <leandro@ic.ufal.br>
