From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 13 Nov 2006 20:17:08 +0000
Subject: Re: [PATCH 0/7]: Retransmission & Sequence Numbers
Message-Id: <5640c7e00611131217g5e4ee2d7o5f811c1ac8151411@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611131327.24492@strip-the-willow>
In-Reply-To: <200611131327.24492@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Ian what about your memsysctl patches - it would be useful to have them
> and I could change patch 3/4 to match that, but they have not been submitted yet.
>
> -- Gerrit
>
I will rename them to match this when I work on them next. My current
thinking is that I will change memory limits to be packet based rather
than byte based as it makes more sense for a datagram based protocol.
I'm not sure when I'll pick this up next. Of course you are free to
take my code and use if you want. It is ugly though at present.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
