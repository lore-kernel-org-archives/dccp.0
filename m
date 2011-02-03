From: Leandro Melo de Sales <leandroal@gmail.com>
Date: Thu, 03 Feb 2011 22:00:54 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <AANLkTimuYxHd5AtGSB2+wg2JE7LEKPjGssoQZuOWYrw-@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Just forwarding my reply to the list netdev and dccp lists, the text
was in HTML format and Majordomo rejected it...

---------- Forwarded message ----------
From: Leandro Melo de Sales <leandroal@gmail.com>
Date: Thu, Feb 3, 2011 at 2:48 PM
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org, therbert@google.com,
Angelo Perkusich <Angelo.Perkusich@gmail.com>, Hyggo Almeida
<hyggo.almeida@gmail.com>


On Wed, Feb 2, 2011 at 10:07 PM, David Miller <davem@davemloft.net> wrote:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> I've left the DCCP code to keep using RFC3390 logic, if they
> wish to adopt this change in their code they can do so by
> simply deleting the rfc33390_bytes_to_packets() function and
> using TCP_INIT_CWND in their assignment.
>
> =A0include/net/tcp.h =A0 =A0 =A0| =A0 12 +++---------
> =A0net/dccp/ccids/ccid2.c | =A0 =A09 +++++++++
> =A0net/ipv4/tcp_input.c =A0 | =A0 =A02 +-
> =A03 files changed, 13 insertions(+), 10 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 9179111..7118668 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -196,6 +196,9 @@ extern void tcp_time_wait(struct sock *sk, int state,=
 int timeo);
> =A0/* TCP thin-stream limits */
> =A0#define TCP_THIN_LINEAR_RETRIES 6 =A0 =A0 =A0 /* After 6 linear retrie=
s, do exp. backoff */
>
> +/* TCP initial congestion window */
> +#define TCP_INIT_CWND =A0 =A0 =A0 =A0 =A010
> +
> =A0extern struct inet_timewait_death_row tcp_death_row;
>
> =A0/* sysctl variables for tcp */
> @@ -799,15 +802,6 @@ static inline __u32 tcp_current_ssthresh(const struc=
t sock *sk)
> =A0/* Use define here intentionally to get WARN_ON location shown at the =
caller */
> =A0#define tcp_verify_left_out(tp) =A0 =A0 =A0 =A0WARN_ON(tcp_left_out(tp=
) > tp->packets_out)
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
> =A0extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
> =A0extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
>
> diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
> index e96d5e8..fadecd2 100644
> --- a/net/dccp/ccids/ccid2.c
> +++ b/net/dccp/ccids/ccid2.c
> @@ -583,6 +583,15 @@ done:
> =A0 =A0 =A0 =A0dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
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
> =A0static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct ccid2_hc_tx_sock *hc =3D ccid_priv(ccid);
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index eb7f82e..2f692ce 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -817,7 +817,7 @@ __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_e=
ntry *dst)
> =A0 =A0 =A0 =A0__u32 cwnd =3D (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
>
> =A0 =A0 =A0 =A0if (!cwnd)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cwnd =3D rfc3390_bytes_to_packets(tp->mss_c=
ache);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cwnd =3D TCP_INIT_CWND;
> =A0 =A0 =A0 =A0return min_t(__u32, cwnd, tp->snd_cwnd_clamp);
> =A0}
>
> --
> 1.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

David and others,
=A0=A0=A0 I don't think this change will make sense for DCCP, once IW10 is
for the cases of short-lived flows. DCCP is used on scenarios for
multimedia flows, which are, in general, long-lived flows. So, IMO the
way how we calculate IW for DCCP is appropriate, at least considering
a quick answer. In fact, nowadays we need better congestion control
algorithms for DCCP, and in this sense we are working on adapt TCP
Cubic for DCCP as a CCID, and also we started some work to make DCCP
support TCP pluggable mechanism , which will allow us to use TCP
congestion control algorithms in DCCP.
=A0=A0=A0 I've been following all the discussions about IW10 in the TCPM
discussion list and also been reading all materials in this context
(papers and ppts) provided by Tom Herbert and Nandita Dukkipati (along
with other researchers from Networking Research Lab at North Carolina
State University), but although the results is really great (at least
for scenarios they've experimented and regardless to all opinions
expressed at TCPM), DCCP should calculate its IW as specified in
RFC3390 rather than set it to IW10. For the moment, I understand that
for DCCP, we have to discuss more about this in a separated thread.

Leandro.

--
Leandro Melo de Sales
Professor at Institute of Computing at Federal University of Alagoas, Brazil
PhD candidate in Computer Science
Pervasive and Embedded Computing Laboratory, UFCG
