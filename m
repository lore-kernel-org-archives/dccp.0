From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 31 Jul 2007 22:11:39 +0000
Subject: Re: [PATCH 5/5]: Revert use of MSS instead of s
Message-Id: <5640c7e00707311511y60ef2794wc0b73a2c3f682f6e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.53153@strip-the-willow>
In-Reply-To: <200707261356.53153@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/27/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Revert use of MSS instead of s
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
>  /*
> - * Compute the initial sending rate X_init according to RFC 3390:
> - *     w_init   =    min(4 * MSS, max(2 * MSS, 4380 bytes))
> - *     X_init   =    w_init / RTT
> + * Compute the initial sending rate X_init in the manner of RFC 3390:
> + *
> + *     X_init  =  min(4*s, max(2*s, 4380 bytes)) / RTT
> + *
> + * Note that RFC 3390 uses MSS, while TFRC uses the nominal packet size s.

Can you perhaps change this to say something like....
* Note that RFC 3390 uses MSS, while TFRC uses the nominal packet size
s and TRFCbis clarifies this to the above formula.



-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
