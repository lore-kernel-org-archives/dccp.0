From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 27 Jul 2007 05:02:25 +0000
Subject: Re: [PATCH 5/5]: Revert use of MSS instead of s
Message-Id: <5640c7e00707262202o6d9b71cds33ad6e52c6ec62f8@mail.gmail.com>
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
> This updates the CCID3 code with regard to two instances of using `MSS' in place of `s':
>
>  1. The RFC3390-based initial rate. Both rfc3448bis as well as the Faster Restart
>     draft now consistently use `s' instead of MSS. Swapping MSS for s had been done
>     shortly after revision 01 of rfc3448bis, but that change subsequently disappeared.
>
>  2. According to section 4.2 of rfc3448bis: "If the sender is ready to send data when
>     it does not yet have a round trip sample, the value of X is set to s bytes per
>     second, for segment size s [...]"
>
> Apart from tracking documents, this change makes sense: in particular, it avoids gross
> over-estimation if the packet size `s' is small (imagine a VoIP application with sd
> bytes and MSS according to Ethernet jumbo frames).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Hmm,

I want to think about this. In particular the reference to VoIP - go
look at CCID4 and that's EXACTLY what they do in effect (but standard
frames - not jumbo).

I'm heading down the patch that we should set 3448bis via a socket
option as well as faster restart but maybe that's a question we should
ask on the IETF list. It really depends on whether existing TFRC is
meant to be phased out and replaced or whether the application can
choose - like a lot of TCP enhancements e.g. SACK. I think 3448bis
should be the default but whether the only option is another
question...

Ian

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
