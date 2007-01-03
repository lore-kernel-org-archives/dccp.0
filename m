From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Jan 2007 21:39:18 +0000
Subject: Re: [PATCH 4/4][NEW]: More to see in dccp_probe
Message-Id: <5640c7e00701031339u20f7ad2hf416821257f44214@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: More to see in dccp_probe
>
> This removes the `size' field from output (which would report the constant buffer size),
> and adds a few more fields of interest to /proc/net/dccpprobe, the following output ensues:
>
I would like the size field kept. This is not constant if you are
sending different size packets like I am :-) It is only constant if
you are using something like iperf/ttcp.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
