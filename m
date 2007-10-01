From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 20:16:07 +0000
Subject: Re: [PATCH 2/11]: Increase the scope of variable-length htonl/ntohl functions
Message-Id: <5640c7e00710011316m1a608256ja45da328ba2ff1c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.14022@strip-the-willow>
In-Reply-To: <200710011518.14022@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Increase the scope of variable-length htonl/ntohl functions
>
> This extends the scope of two available functions, encode|decode_value_var,
> to work up to 6 (8) bytes, to match maximum requirements in the RFC.
>
> These functions are going to be used both by general option processing and
> feature negotiation code, hence declarations have been put into feat.h.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
