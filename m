From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Thu, 22 Jun 2006 03:48:39 +0000
Subject: Re: [PATCH 1/1] [DCCP]: Fix default sequence window size
Message-Id: <39e6f6c70606212048k3bb2c55amfc3e5f4adb423452@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <449A1199.1080404@jandi.co.nz>
In-Reply-To: <449A1199.1080404@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/22/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> When using the default sequence window size (100) I got the following in
> my logs:
> Jun 22 14:24:09 localhost kernel: [ 1492.114775] DCCP: Step 6 failed for
> DATA packet, (LSWL(6279674225) <= P.seqno(6279674749) <> S.SWH(6279674324)) and (P.ackno doesn't exist or LAWL(18798206530) <> P.ackno(1125899906842620) <= S.AWH(18798206548), sending SYNC...
> Jun 22 14:24:09 localhost kernel: [ 1492.115147] DCCP: Step 6 failed for
> DATA packet, (LSWL(6279674225) <= P.seqno(6279674750) <> S.SWH(6279674324)) and (P.ackno doesn't exist or LAWL(18798206530) <> P.ackno(1125899906842620) <= S.AWH(18798206549), sending SYNC...
>
> I went to alter the default sysctl and it didn't take for new sockets.
> Below patch fixes this.
>
> I think the default is too low but it is what the DCCP spec specifies.
>
> As a side effect of this my rx speed using iperf goes from about 2.8
> Mbits/sec to 3.5. This is still far too slow but it is a step in the
> right direction.

Agreed, minor nitpick below...

> Compile tested only for IPv6 but not particularly complex change.
>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
>
> ---
>
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index f2c011f..3119804 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -32,6 +32,8 @@ #include "ccid.h"
>   #include "dccp.h"
>   #include "feat.h"
>
> +extern int dccp_feat_default_sequence_window;
> +

Could you please add this one in feat.h? Then I'll be OK with this one
and will ask Dave to merge it.

Thanks,

- Arnaldo

>   /*
>    * This is the global socket data structure used for responding to
>    * the Out-of-the-blue (OOTB) packets. A control sock will be created
> @@ -505,8 +507,7 @@ int dccp_v4_conn_request(struct sock *sk
>         ireq = inet_rsk(req);
>         ireq->loc_addr = daddr;
>         ireq->rmt_addr = saddr;
> -       req->rcv_wnd    = 100; /* Fake, option parsing will get the
> -                                 right value */
> +       req->rcv_wnd    = dccp_feat_default_sequence_window;
>         ireq->opt       = NULL;
>
>         /*
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 65e2ab0..aa147f4 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -33,6 +33,8 @@ #include <net/xfrm.h>
>   #include "dccp.h"
>   #include "ipv6.h"
>
> +extern int dccp_feat_default_sequence_window;
> +

See? :-)
