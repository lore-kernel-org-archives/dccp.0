From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 23 Sep 2007 07:48:48 +0000
Subject: Re: Ack Vectors, feature negotiation and preview of new patches
Message-Id: <5640c7e00709230048j767ca705x1ed764a80bf00aca@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709201605.31605@strip-the-willow>
In-Reply-To: <200709201605.31605@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/21/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I am happy to announce that feature negotiation now works, which resolves the above problem. Below is
> a log dump which shows the successful negotiation of CCID and dependent features during the handshake.
> Exchanging NN features during an established connection is also possible (as used e.g. by Ack Ratio for
> CCID2). I'll be sending the patches next week after some more testing.
>
Sounds awesome.

> The other news is a patch for wireshark to
>  * decode all feature-negotiation options
>  * decode CCID3's X_recv and Loss Event Rate
> This is on http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/wireshark-options-decoding.diff
>

That sounds useful too. Have you sent it upstream?

Lots of good work. Look forward to reviewing the patches in due course.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
