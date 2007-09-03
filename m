From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 03 Sep 2007 23:02:50 +0000
Subject: Re: [PATCH 3/6] DCCP: Introduce CCID3 extensions
Message-Id: <5640c7e00709031602v42ebef8bq87fd31a2ed5443b9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200708291134.45030.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291134.45030.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> A style comment - I like the idea of the extensions and can see your point.
> To be true, if the code were analysed for extensions then the rfc344bis-00
> extensions would probably also count, as well as the erratum for the SYN
> RTT sample.

Yes, that was the intention - to pick up other uses over time as appropriate.
>
> When using a one-bit flag (which automatically behaves like a Boolean type),
> such as
>         /* @ccid3hctx_faster_restart_on: whether Faster Restart is enabled */
>         /* ... */
>         u8                              ccid3hctx_faster_restart_on:1;
>
> the testing and setting code would be smaller - if a little less elegant.

Understand what you're saying. When/if it gets merged I'll see what
code style Arnaldo wants and go with whichever style he prefers. I
don't mind which one is used.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
