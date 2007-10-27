From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 27 Oct 2007 22:27:15 +0000
Subject: Re: [PATCH 6/6]: Larger initial windows also for CCID2
Message-Id: <5640c7e00710271527m2b2a8102hc4d2ff3c117a4a4f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710271234.37402@strip-the-willow>
In-Reply-To: <200710271234.37402@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID2]: Larger initial windows also for CCID2
>
> RFC 4341, sec. 5 states that "The cwnd parameter is initialized to at most
> four packets for new connections, following the rules from [RFC3390]", which
> is implemented by this patch.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
