From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 26 Mar 2007 02:33:30 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <5640c7e00703251933r60687293q936c6f4a31ec67ef@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/22/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Avoid accumulation of large send credit
>
> Problem:
> --------
>  Large backlogs of packets which can be sent immediately currently accumulate
>  when (i) the application idles, or (ii) the application emits at a rate slower
>  than the allowed rate X/s, or (iii) due to scheduling inaccuracy (resolution
>  only up to HZ). The consequence is that a huge burst of packets can be sent
>  immediately, which violates the allowed sending rate and can (worst case)
>  choke the network.
>  NB: Corresponding paragraph on send credits recently added to rfc3448bis
>
> Fix:
> ----
>  Avoid any backlog of sending time which is greater than one whole t_ipi. This
>  permits the coarse-granularity bursts mentioned in [RFC 3448, 4.6], but disallows
>  the disproportionally large bursts.

I think we should be going with greater than max(t_ipi, t_gran) as per
discussion on IETF list and proposal by Sally Floyd
http://www1.ietf.org/mail-archive/web/dccp/current/msg02281.html

I do know that Gerrit has some reservations around the whole
granularity of scheduling issue and I will try and address these at
some point but Eddie/Sally seem to be siding around allowing packet
bursts as per how we read RFC spec.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
