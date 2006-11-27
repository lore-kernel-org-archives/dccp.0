From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 27 Nov 2006 19:08:06 +0000
Subject: Re: [PATCHv2 8/10] [UPDATE]: Larger initial windows
Message-Id: <5640c7e00611271108v1d512d4bl487249572f953135@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611271211.01961@strip-the-willow>
In-Reply-To: <200611271211.01961@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/28/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This is an update which improves on the previous version by
>  * doing the necessary adjustments in ccid3_hc_tx_packet_recv
>  * rather than in ccid3_update_x; thus reducing the numberof instructions.
>
> Ian you acked the previous version - I haven't added an Acked-by line as
> in the other patches (where provided), would be glad if you could have a look
> at it.
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
