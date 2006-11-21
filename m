From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 21 Nov 2006 04:25:17 +0000
Subject: Re: [PATCH 2/2] [RESENT]: Add annotations for socket structure
Message-Id: <5640c7e00611202025g54a0e7c8o7cab237e6ff6cb46@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611201605.39786@strip-the-willow>
In-Reply-To: <200611201605.39786@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> ==> Note: ccid3hcrx_tstamp_last_feedback and
>            ccid3hcrx_tstamp_last_ack
>            are updated at the same time and serve an identical purpose.
>            => merge these into one field ???
>
I'll have to have a look at this. They aren't updated at same time
always as ccid3_hc_rx_send_feedback has multiple callers so
last_feedback gets updated more often than last_ack as I read it.

But it does look on the surface like two variables aren't needed but
just need to study some more.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
