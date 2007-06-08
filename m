From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 08 Jun 2007 11:44:19 +0000
Subject: PATCH/ Re: 'BUG: scheduling while atomic' during dccp transfer
Message-Id: <200706081244.19452@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_TEUaGjJJqxH5/Le"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_TEUaGjJJqxH5/Le
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I can confirm the bug - I experienced it a while ago
and I had it in my patch set for a while (attached).

The reason I didn't submit it yet was that it is buried
somewhere in my patch set, and the preceding patches
before that one are not yet submitted. Guess I should
do that soon.

Gerrit

Quoting Florian Westphal:
|  Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
|  > On 6/7/07, Florian Westphal <fw@strlen.de> wrote:
|  > >> Can you try with the attached patch?
|  > >
|  > >I haven't been able to reproduce it so far.
|  > 
|  > You mean with this patch applied?
|  
|  Yes, sorry for not being precise. I applied your
|  patch and so far I haven't seen this bug again.
|  
|  Thanks,
|  	Florian
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  

--Boundary-00=_TEUaGjJJqxH5/Le
Content-Type: text/x-diff;
  charset="ansi_x3.4-1968";
  name="15d_Misc-Tidy-Up__CCID2-Allocation-FIX.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="15d_Misc-Tidy-Up__CCID2-Allocation-FIX.diff"

[CCID2]: Allocation in atomic context

This fixes the following bug reported in syslog:

[ 4039.051658] BUG: sleeping function called from invalid context at /usr/src/davem-2.6/mm/slab.c:3032
[ 4039.051668] in_atomic():1, irqs_disabled():0
[ 4039.051670] INFO: lockdep is turned off.
[ 4039.051674]  [<c0104c0f>] show_trace_log_lvl+0x1a/0x30
[ 4039.051687]  [<c0104d4d>] show_trace+0x12/0x14
[ 4039.051691]  [<c0104d65>] dump_stack+0x16/0x18
[ 4039.051695]  [<c011371e>] __might_sleep+0xaf/0xbe
[ 4039.051700]  [<c0157b66>] __kmalloc+0xb1/0xd0
[ 4039.051706]  [<f090416f>] ccid2_hc_tx_alloc_seq+0x35/0xc3 [dccp_ccid2]
[ 4039.051717]  [<f09048d6>] ccid2_hc_tx_packet_sent+0x27f/0x2d9 [dccp_ccid2]
[ 4039.051723]  [<f085486b>] dccp_write_xmit+0x1eb/0x338 [dccp]
[ 4039.051741]  [<f085603d>] dccp_sendmsg+0x113/0x18f [dccp]
[ 4039.051750]  [<c03907fc>] inet_sendmsg+0x2e/0x4c
[ 4039.051758]  [<c033a47d>] sock_aio_write+0xd5/0x107
[ 4039.051766]  [<c015abc1>] do_sync_write+0xcd/0x11c
[ 4039.051772]  [<c015b296>] vfs_write+0x118/0x11f
[ 4039.051840]  [<c015b932>] sys_write+0x3d/0x64
[ 4039.051845]  [<c0103e7c>] syscall_call+0x7/0xb
[ 4039.051848]  =======================


The problem was that GFP_KERNEL was used; fixed by using gfp_any().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -298,7 +298,7 @@ static void ccid2_hc_tx_packet_sent(stru
 		int rc;
 
 		ccid2_pr_debug("allocating more space in history\n");
-		rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, GFP_KERNEL);
+		rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, gfp_any());
 		BUG_ON(rc); /* XXX what do we do? */
 
 		next = hctx->ccid2hctx_seqh->ccid2s_next;

--Boundary-00=_TEUaGjJJqxH5/Le--
