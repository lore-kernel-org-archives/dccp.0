From: Andreas Schwab <schwab@linux-m68k.org>
Date: Sun, 26 Jul 2020 07:08:42 +0000
Subject: Re: get rid of the address_space override in setsockopt v2
Message-Id: <87imea3g91.fsf@linux-m68k.org>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Jul 26 2020, Christoph Hellwig wrote:

> From 6601732f7a54db5f04efba08f7e9224e5b757112 Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Sun, 26 Jul 2020 09:00:09 +0200
> Subject: mISDN: remove a debug printk in data_sock_setsockopt
>
> The %p won't work with the new sockptr_t type.  But in the times of
> ftrace, bpftrace and co these kinds of debug printks are pretty anyway,

I think there is a word missing after pretty.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 7578 EB47 D4E5 4D69 2510  2552 DF73 E780 A9DA AEC1
"And now for something completely different."
