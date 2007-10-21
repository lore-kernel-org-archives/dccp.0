From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 21 Oct 2007 01:30:51 +0000
Subject: Re: [PATCH 7/8]: Remove unused inline function
Message-Id: <5640c7e00710201830r59a91701i8945e5d455092f3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/9/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Remove unused inline function
>
> The function follows48(), which is a special-case of dccp_delta_seqno(),
> is nowhere used in the DCCP code, thus removed by this patch.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
