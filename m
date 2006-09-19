From: David Miller <davem@davemloft.net>
Date: Tue, 19 Sep 2006 20:05:46 +0000
Subject: Re: [PATCH 2/10]: [DCCP] ackvec: Fix how
Message-Id: <20060919.130546.18283143.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 14:09:08 -0300

> Fix the way state is masked out.  DCCP_ACKVEC_STATE_NOT_RECEIVED is
> defined as appears in the packet, therefore bit shifting is not
> required.  This fix allows CCID2 to correctly detect losses.
>
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

Applied.
