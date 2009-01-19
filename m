From: David Miller <davem@davemloft.net>
Date: Mon, 19 Jan 2009 05:40:33 +0000
Subject: Re: [PATCH 4/4] dccp: Debugging functions for feature negotiation
Message-Id: <20090118.214033.84916995.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1232184993-9927-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1232184993-9927-5-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Jan 2009 10:36:33 +0100

> Since all feature-negotiation processing now takes place in feat.c, functions
> for producing verbose debugging output are concentrated there.
> 
> New functions to print out values, entry records, and options are provided,
> and also a macro is defined to not always have the function name in the
> output line.
> 
> Thanks a lot to Wei Yongjun and Giuseppe Galeota for help and discussion with an
> earlier revision of this patch.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied for 2.6.30
