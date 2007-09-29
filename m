From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 29 Sep 2007 03:43:45 +0000
Subject: Re: [PATCH 3/11]: Ignore feature negotiation on Data packets
Message-Id: <5640c7e00709282043s707c395am1107fa9eded058f5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709271520.52147@strip-the-willow>
In-Reply-To: <200709271520.52147@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Ignore feature negotiation on Data packets
>
> This implements [RFC 4340, p. 32]: "any feature negotiation options received
> on DCCP-Data packets MUST be ignored".
>
> Also added a FIXME for further processing, since the code currently (wrongly)
> classifies empty Confirm options as invalid - this needs to be resolved in
> a separate patch.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
