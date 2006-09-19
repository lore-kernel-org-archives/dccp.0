From: David Miller <davem@davemloft.net>
Date: Tue, 19 Sep 2006 20:05:03 +0000
Subject: Re: [PATCH 1/10]: [DCCP] ACKVEC: fix ackvector length calculation
Message-Id: <20060919.130503.102906258.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20060914170823.GB20651@mandriva.com>
In-Reply-To: <20060914170823.GB20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 14:08:25 -0300

> Fix ackvector length calculation upon receiving an "ack-of-ack".  This patch
> avoids the ackvector from growing too large which causes it to not be inserted
> into packets.
> 
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

Applied.
