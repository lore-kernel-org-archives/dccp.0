From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 03:31:10 +0000
Subject: Re: [PATCH 10/11]: Limit feature negotiation to connection setup phase
Message-Id: <5640c7e00709302031m325ce812xc3664aeb671f6b69@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Limit feature negotiation to connection setup phase
>
> Although it is theoretically possible to perform feature negotiation at any time (and RFC 4340
> supports this), this is practically very complicated, since during feature negotiation the traffic
> needs to be put on hold.
>
> This patch disables anytime negotiation, subsequent patches work out full feature negotiation
> support for connection setup. (The limitation is later lifted, but requires a different concept first).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
