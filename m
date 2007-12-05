From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 05 Dec 2007 14:11:22 +0000
Subject: Re: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Message-Id: <20071205141122.GE4653@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Dec 05, 2007 at 11:19:45AM +0000, Gerrit Renker escreveu:
> This fixes a problem in the initial revision of the patch: The loss interval
> history was not de-allocated when the initialisation of the packet history
> failed.  The identification of this problem is also thanks due to Arnaldo.
> 
> The interdiff to the previous revision is:
> 
> 	--- b/net/dccp/ccids/lib/tfrc_module.c
> 	+++ b/net/dccp/ccids/lib/tfrc_module.c
> 	@@ -26,7 +26,12 @@
> 	 
> 		if (rc = 0)
> 			rc = packet_history_init();
> 	+	if (rc = 0)
> 	+		goto out;
> 	 
> 	+out_free_loss_intervals:
> 	+	dccp_li_exit();
> 	+out:
> 		return rc;
> 	 }
> 

Ok, this one is kept on the series I have pending submission.

- Arnaldo
