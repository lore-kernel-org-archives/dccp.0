From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 17:52:11 +0000
Subject: Re: [PATCH-UPDATE]: Changes after retracting timestamping patches
Message-Id: <200704131852.11528@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704131825.14989@strip-the-willow>
In-Reply-To: <200704131825.14989@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

You are right, this is an oversight. I wanted to resubmit this patch to the
list anyway, since Dave had some reservations which I think originated from 
the timestamping issue.

The fix is in using dccp_timestamp, as in all other patches I have been updating
over the day. Will send this update shortly.

  
|  I think we should take the timestamp at dccp_v[46]_rcv time, into the
|  skb, that won't be  as precise as
|  skb_get_timestamp+net_enable_timestamp, but at least will eliminate
|  the time the packet sits in the backlog (if it sits at all), no?
|  
I think that this makes not a huge difference. I am preparing an email to
Eddie which says why. Essentially I think that Linux is the wrong platform
for CCID3 anyway, so if this slows down the sender, it may even be better
to keep speed within a controllable range. Many thanks for looking into this.
