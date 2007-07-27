From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 27 Jul 2007 04:51:56 +0000
Subject: Re: [PATCH 2/5]: Tidy-up -- minisock initialisation
Message-Id: <5640c7e00707262151j3f50c629r2ce2a8e0c40a5309@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.39826@strip-the-willow>
In-Reply-To: <200707261356.39826@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/27/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Tidy-up -- minisock initialisation
>
> This
>  * removes a declaration of a non-existent function __dccp_minisock_init;
>  * shifts the initialisation function dccp_minisock_init() from options.c
>    to minisocks.c, where it is more naturally expected to be.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
