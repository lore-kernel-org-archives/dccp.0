From: David Miller <davem@davemloft.net>
Date: Fri, 04 Sep 2009 12:42:02 +0000
Subject: Re: [PATCH 4/5] Adds options DROPPED PACKETS and LOSS INTERVALS to
Message-Id: <20090904.054202.35826460.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011945u2d82da97i7a7f2d1f12519a5f@mail.gmail.com>
In-Reply-To: <cb00fa210909011945u2d82da97i7a7f2d1f12519a5f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 04 Sep 2009 09:25:08 -0300

> 
> /* return 1 if a new loss event has been identified */
> -static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff
> *skb, u32 n3)
> +static int __two_after_loss(struct tfrc_rx_hist *h,
> +     struct sk_buff *skb, u32 n3,

Your patches are all heavily corrupted by your email client.

As seen here, long lines are chopped up with newlines, and also tab
characters have been changed into sequences of spaces.

Please fix this up and submit your patches properly.  Use
Documentation/email-clients.txt to learn how to fix these problems.

Thank you.
