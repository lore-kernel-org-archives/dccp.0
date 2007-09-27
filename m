From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 27 Sep 2007 19:39:13 +0000
Subject: Re: [PATCH 2/11]: Make code assumptions explicit
Message-Id: <5640c7e00709271239p95503b9uf5ea4f4b8ed482eb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709271520.48914@strip-the-willow>
In-Reply-To: <200709271520.48914@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Make code assumptions explicit
>
> This removes several `XXX' references which indicate a missing support
> for non-1-byte feature values: this is unnecessary, as all currently known
> (standardised) SP feature values are 1-byte quantities.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
