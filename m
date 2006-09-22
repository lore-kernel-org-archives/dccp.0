From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 17:54:58 +0000
Subject: Re: [PATCH 7/7] [DCCP]: Remove socket option
Message-Id: <5640c7e00609221054u7fd04b3er15ebbdd6fb74a307@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200609221433.48612.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221433.48612.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> I would like to suggest a compromise: retaining an experimental patch which allows
> this socket option and can be used for people interested in experimenting with these
> ideas, to gain new insights; and to leave the main kernel API as simple as it can
> possibly be made.

That is exactly what my patch is. The socket option is not required so
much of the debate is pointless!

You could argue over the correct default for a socket but my patch
doesn't alter that.

After seeing all the discussion I would still like the patch in.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
