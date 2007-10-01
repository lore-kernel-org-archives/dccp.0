From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 19:32:22 +0000
Subject: Re: [PATCH 1/3]: Retrieve packet sequence number for error reporting
Message-Id: <5640c7e00710011232y18e099bek896833d9b06ef1b6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Retrieve packet sequence number for error reporting
>
> This fixes a problem when analysing erroneous packets in dccp_v{4,6}_err:
>  * dccp_hdr_seq currently takes an skb
>  * however, the transport headers in the skb are shifted, due to the
>    preceding ICMPv4/v6 header.
> Fixed for v4 and v6 by changing dccp_hdr_seq to take a struct dccp_hdr as
> argument. Verified that the correct sequence number is now reported in the
> error handler.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
