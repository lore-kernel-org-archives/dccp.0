From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 00:15:55 +0000
Subject: Re: CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <5640c7e00609211715m1a3a72e0l1a0f9dbee2e9eba7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200609210930.21903@strip-the-willow>
In-Reply-To: <200609210930.21903@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Lastly, a related issue is the use of the DCCP_SOCKOPT_PACKET_SIZE socket option: this
> is a strange something, again is CCID-specific, and no current use for it can be seen
> - Ian McDonald has a patch which removes it. I am still wondering whether and if it has any
> use at all?
>
It has been used in a number of applications but it doesn't work! It
is to implement section 5.3 of RFC4342. My patch to remove it is in
the context of other patches to introduce two which do work. It is to
specify one for each half connection. I hope to post these to the list
later today.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
