From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 10:35:19 +0000
Subject: Re: [PATCH 0/10] [RFC]: CCID 3 updates
Message-Id: <200611271035.20152@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.04691@strip-the-willow>
In-Reply-To: <200611241619.04691@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  On Fri, Nov 24, 2006 at 04:19:04PM +0000, Gerrit Renker wrote:
|  > I have cut this into 10 small pieces to make reviewing easier. 
|  > 
|  > If everyone is happy with it, I can re-send it as one piece.
|  
|  I'll look at it probably tomorrow (saturday), but please, please don't
|  combine patches (even less the ones you already splitted), keep it as
|  small and doing just one thing, that is always best for reviewing when
|  merging and, more importantly, afterwards, when we have to look back :-)
Thank you, I wasn't clear about that one and it is necessary. I have had some
time to go over what I have sent and over the CCID 3 code and I can find more
things that need tending to. Ian has done a lot of work getting the scaled-integer
operations right, but --horror-- there are more subtle bugs in this. For instance,
usecs_div is not used for calculating the one packet per second threshold, s/t_mbi
For instance,
  hctx->ccid3hctx_x = max_t(u32, ... 
					       (hctx->ccid3hctx_s /
					        TFRC_MAX_BACK_OFF_TIME));

TFRC_MAX_BACK_OFF_TIME is 64. If hctx->ccid3hctx_s < 64 bytes (which is frequent on
audio or VoIP packets, then integer division says `send at most 0 bytes per second'.
So I think it is best to go through the entire code and check each of these cases; maybe
use a set of `fixpoint' computation routines as used by the Kame patch.

Thank you and Ian for your feedback - I will check through this first and update patches
accordingly.
