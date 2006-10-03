From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 03 Oct 2006 19:57:24 +0000
Subject: Re: [PATCH 0/7] [DCCP]: Further fixes and enhancements
Message-Id: <5640c7e00610031257s62697c7di9f3b665442d65c7e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200609221425.16349.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221425.16349.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> I think it would be good for Arnaldo or another person to sign off on 5, 6
> and 7 after a bit more of a look. These fix up packet size setting for
> CCID3 and also change them to work on half connections as you may have
> different packet sizes for each. I've tested myself thoroughly but others
> might have an opinion on the style of these. These three patches need to be
> applied in order.
>
Please don't merge patches 5-7 now as per other threads going on.
These aren't needed I believe. I will still verify that is the case
but can't yet do that.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
