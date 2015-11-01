From: David Miller <davem@davemloft.net>
Date: Sun, 01 Nov 2015 22:01:38 +0000
Subject: Re: [PATCH] [DCCP]: Use 64-bit timekeeping
Message-Id: <20151101.170138.358342779450639583.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Tina Ruchandani <ruchandani.tina@gmail.com>
Date: Fri, 30 Oct 2015 01:24:56 -0700

> This patch changes the use of struct timespec in
> dccp_probe to use struct timespec64 instead. timespec uses a 32-bit
> seconds field which will overflow in the year 2038 and beyond. timespec64
> uses a 64-bit seconds field. Note that the correctness of the code isn't
> changed, since the original code only uses the timestamps to compute a
> small elapsed interval. This patch is part of a larger attempt to remove
> instances of 32-bit timekeeping structures (timespec, timeval, time_t)
> from the kernel so it is easier to identify where the real 2038 issues
> are.
> 
> Signed-off-by: Tina Ruchandani <ruchandani.tina@gmail.com>

Applied, thanks.
