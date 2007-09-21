From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Fri, 21 Sep 2007 03:52:56 +0000
Subject: Re: [PATCH 4/4] CCID4: Replaces the hard-coded 1460 nominal packet size by a #define
Message-Id: <5bc4c4570709202052g4a7e0c0dsac6b8e03a443ffd7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201055m200ca6enbcc7d33070f7e792@mail.gmail.com>
In-Reply-To: <5bc4c4570709201055m200ca6enbcc7d33070f7e792@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/20, Tommi Saviranta <wnd@iki.fi>:
> On Thu, Sep 20, 2007 at 14:55:09 -0300, ツ Leandro Sales wrote:
> > diff -uprN dccp-ccid4.base/net/dccp/ccids/ccid4.h
>
> > +#define NOM_PACKET_SIZE                 1460
>
> Agreed, using a define for hardcoded value is the way to go. I think
> nominal packet size is somewhat private information to ccid4.c, so I'd
> rather put the define in the c-file. What does the Linux-kernel coding
> convention (or common sense) say about this?
>
>

Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>

Adjust patch #4 to be cleanly applied without generate "hunk" due to
patch #3 update.

diff -uprN dccp-ccid4.base/net/dccp/ccids/ccid4.c
dccp-ccid4/net/dccp/ccids/ccid4.c
--- dccp-ccid4.base/net/dccp/ccids/ccid4.c	2007-09-21 00:30:35.000000000 -0300
+++ dccp-ccid4/net/dccp/ccids/ccid4.c	2007-09-21 00:33:40.000000000 -0300
@@ -494,7 +494,7 @@ static void ccid4_hc_tx_packet_recv(stru
 	}
 	/* perform step (4) of draft rfc3448bis, section 4.3 */
 	if (hctx->ccid4hctx_p > 0)
-		hctx->ccid4hctx_x_calc = tfrc_calc_x(1460,
+		hctx->ccid4hctx_x_calc = tfrc_calc_x(NOM_PACKET_SIZE,
 						     hctx->ccid4hctx_rtt,
 						     hctx->ccid4hctx_p);
 	ccid4_hc_tx_update_x(sk, &now);
@@ -805,7 +805,7 @@ static u32 ccid4_first_li(struct sock *s
 		}
 	}

-	fval = scaled_div(1460, hcrx->ccid4hcrx_rtt);
+	fval = scaled_div(NOM_PACKET_SIZE, hcrx->ccid4hcrx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);

diff -uprN dccp-ccid4.base/net/dccp/ccids/ccid4.h
dccp-ccid4/net/dccp/ccids/ccid4.h
--- dccp-ccid4.base/net/dccp/ccids/ccid4.h	2007-09-21 00:30:35.000000000 -0300
+++ dccp-ccid4/net/dccp/ccids/ccid4.h	2007-09-21 00:32:57.000000000 -0300
@@ -65,6 +65,9 @@
 /* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
 #define TFRC_T_MBI		   64

+/* The nominal packet size to be used into TFRC equation as per CCID-4 draft*/
+#define NOM_PACKET_SIZE                   1460
+
 enum ccid4_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
