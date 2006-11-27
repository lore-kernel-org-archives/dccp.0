From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 27 Nov 2006 13:33:14 +0000
Subject: Re: [PATCHv2 8/10] [UPDATE]: Larger initial windows
Message-Id: <20061127133313.GD11605@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <200611271211.01961@strip-the-willow>
In-Reply-To: <200611271211.01961@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Nov 27, 2006 at 12:11:01PM +0000, Gerrit Renker wrote:
> This is an update which improves on the previous version by 
>  * doing the necessary adjustments in ccid3_hc_tx_packet_recv 
>  * rather than in ccid3_update_x; thus reducing the numberof instructions.
> 
> Ian you acked the previous version - I haven't added an Acked-by line as
> in the other patches (where provided), would be glad if you could have a look
> at it.
> 

I'm going over the ones Ian acked, and that I had previously put into
the 'ccid3' branch, i.e. the ones I had as well acked, and push to
David, then we get back to the other ones.

- Arnaldo
