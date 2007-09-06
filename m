From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:44:50 +0000
Subject: Re: [PATCH 8/10]: Use maximum-RTO backoff from DCCP spec
Message-Id: <5640c7e00709052144n13ef9306mf4158d987af033ea@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Use maximum-RTO backoff from DCCP spec
>
> This removes another Fixme, using the TCP maximum RTO rather than the value
> specified by the DCCP specification. Across the sections in RFC 4340, 64
> seconds is consistently suggested as maximum RTO backoff value; and this is
> the value which is now used.
>
> I have checked both termination cases for retransmissions of Close/CloseReq:
> with the default value 15 of `retries2', and an initial icsk_retransmit = 0,
> it takes about 614 seconds to declare a non-responding peer as dead, after
> which the final terminating Reset is sent. With the TCP maximum RTO value of
> 120 seconds it takes (as might be expected) almost twice as long, about 23
> minutes.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
