From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 18:49:14 +0000
Subject: Re: [PATCH 9/9]: API to query the current TX/RX CCID
Message-Id: <5640c7e00710011149y1b7ac511p295e6947894463be@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.35654@strip-the-willow>
In-Reply-To: <200709281630.35654@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: API to query the current TX/RX CCID
>
> This provides function to query the current TX/RX CCID dynamically, without
> reliance on the minisock value, using dynamic information available in the
> currently loaded CCID module.
> This query function is then used
>  (a) to provide the getsockopt part for getting/setting CCIDs via sockopts;
>  (b) replaces the current use in dccp_probe.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

I presume this is to support more CCIDs in future as currently makes
the code more complicated...

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
