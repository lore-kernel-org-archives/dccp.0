From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 24 Jan 2007 01:02:00 +0000
Subject: Re: [PATCH 3/7]: Handle Idle and Application-Limited periods
Message-Id: <5640c7e00701231702h416c4505u69d271698fd44eee@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701231540.56521@strip-the-willow>
In-Reply-To: <200701231540.56521@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 24/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Handle Idle and Application-Limited periods
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> +                   (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))) {

You might want to comment that this is x_recv >> 6 * 2. It is obvious
to me but maybe not to others!

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
