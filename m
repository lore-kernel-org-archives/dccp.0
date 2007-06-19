From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 19 Jun 2007 00:04:01 +0000
Subject: Re: [PATCH 3/6]: Ignore trivial amounts of elapsed time
Message-Id: <5640c7e00706181704t7137ad69gfc6f28e76ccdd00a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091958.18116@strip-the-willow>
In-Reply-To: <200706091958.18116@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/17/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> The processing all happens in softirq context and the flow of function calls
> is in the processing path of the handler.

OK - makes more sense. When grepping around in code I see CCID2 also
makes calls to elpased time fn. Haven't checked whether this can be
removed also...

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

> The only way I can see that we will get a delay is in the case when skb allocation
> fails in dccp_send_ack. This is something to be considered, but this (memory allocation
> failture) seems to be an exception-case, not a rule-case. Hence it is implicitly added
> to the processing/RTT delay of the host. To me this seems right: if the host is struggling
> to get memory for skbs, it doesn't seem `right' to indicate to the other side that
> the elapsed time = time to find an unallocated skb is negligible.
> Thoughts?
>
Agree - if you are failing to allocate memory there are far bigger
issues and exact RTT timing is probably the least of your issues!

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
