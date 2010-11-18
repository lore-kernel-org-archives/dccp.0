From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 18 Nov 2010 06:42:00 +0000
Subject: Re: net-next-2.6 [PATCH 0/6]: dccp ccid-2: Ack Vector patch set
Message-Id: <20101118064200.GA5457@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1289802547-5617-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1289802547-5617-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Some of the new functions you added had some coding style quirks,
> for example the openning brace for dccp_ackvec_clear_state()
> has an unnecessary space before it on that line.
> 
> Please fix those sorts of things up, thanks.

I am sorry, this glitch must have occurred since I last ran checkpatch.pl.  

Please find a fix attached. I have checked all patches again, line-by-line
and using checkpatch.pl. I found only this one occurrence, checking twice.

It is also on top today's copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

(I tried to put up the patches on top of this, but this did not work cleanly,
 due to inter-dependencies. I apologize for this.)

>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    
dccp ccid-2: whitespace fix-up

This fixes whitespace noise introduced in commit "dccp ccid-2: Algorithm to
update buffer state", 5753fdfe8bd8e9a2ff9e5af19b0ffc78bfcd502a, 14 Nov 2010.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>  
---
 ackvec.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -282,7 +282,7 @@ void dccp_ackvec_input(struct dccp_ackvec *av, struct sk_buff *skb)
  * packet of group (2) in 11.4.2.
  */
 void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno)
- {
+{
 	struct dccp_ackvec_record *avr, *next;
 	u8 runlen_now, eff_runlen;
 	s64 delta;
