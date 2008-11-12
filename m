From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Nov 2008 06:14:03 +0000
Subject: Re: [PATCH 4/4] dccp: Resolve dependencies of features on choice
Message-Id: <20081112061402.GA6405@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1225950014-6337-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1225950014-6337-5-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

David, -
| Send me something which actually compiles next time:
| 
| net/dccp/feat.c: In function ???__feat_register_nn???:
| net/dccp/feat.c:252: error: implicit declaration of function ???dccp_feat_default_value???
| net/dccp/feat.c:255: error: implicit declaration of function ???dccp_feat_push_change???
| make[2]: *** [net/dccp/feat.o] Error 1
| make[2]: *** Waiting for unfinished jobs....
| 
Apologies. This was a resubmitted set and patch 2/4, after diff-ing each
of the patches, was found to still have the old format. The set had been
changed to avoid build warnings about dependencies throughout, this
patch unfortunately had the old format.

When resubmitting next I will make sure to only use fresh copies for
each, no matter if it is the same patch. 

Will re-send the 4 from the up-to-date local copies, these are known to
compile without errors/warnings. 
