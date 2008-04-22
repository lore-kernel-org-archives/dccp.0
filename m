From: David Miller <davem@davemloft.net>
Date: Tue, 22 Apr 2008 22:06:48 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080422.150648.158484938.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 22 Apr 2008 22:45:53 +0200

> Maybe I wasn't clear enough with my question. I understand that
> these two memsets would have to be readded. But my question is: did
> you identify any bugs that were caused by junk in skb->cb before
> applying your patch? If so, do you have any test cases? It could
> help to check code for correctness if one day more space in skb->cb
> will be needed (which of course doesn't have to be in the nearest
> future).

I think Patrick noticed it because it broke netfilter.
