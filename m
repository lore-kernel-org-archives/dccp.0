From: David Miller <davem@davemloft.net>
Date: Mon, 28 Apr 2008 07:39:06 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080428.003906.43331329.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Apr 2008 08:21:28 +0100

> Since I can currently not see the last point happen within DCCP, I think
> that the use of skb->priority for layer 4 (DCCP) is safe.

Ok.

> So the remaining question was whether maintainers would be okay with
> this "overloading" of the field (Arnaldo seems ok with it). 

I'm okay with it, thanks for the explanation and analysis.
