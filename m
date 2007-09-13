From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 13 Sep 2007 00:06:13 +0000
Subject: Re: [PATCH 1/5]: Sequence number wrap-around when sending reset
Message-Id: <5640c7e00709121706w3513c60du4352ad027b614389@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709121535.08544@strip-the-willow>
In-Reply-To: <200709121535.08544@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Sequence number wrap-around when sending reset
>
> This replaces normal addition with mod-48 addition so that
> sequence number wraparound is respected.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
