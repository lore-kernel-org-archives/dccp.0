From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 19 Aug 2007 20:53:15 +0000
Subject: Re: About pluggable congestion control infrastructure in DCCP
Message-Id: <5640c7e00708191353h6cbe5e44h6b1742d338865cc7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e3c7f9e80708190627y3e883241gb1def650e37965c0@mail.gmail.com>
In-Reply-To: <e3c7f9e80708190627y3e883241gb1def650e37965c0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/20/07, Shahiduzzaman <shahid21st@gmail.com> wrote:
> Hi all,
>
> This may be a redundant or very naive question - sorry in advance for
> that. Can anybody tell me, whether the current Linux kernel DCCP
> implementation is done in a fashion like TCP pluggable congestion
> avoidance modules infrastructure (http://lwn.net/Articles/128681/) ?
>
>
> Thanks.
>
>
> Shahid

The short answer is yes and no!

No that the in-tree version does not support it.

Yes in that for CCID2 (TCP like) there was an out of tree version that
could use the different TCP congestion control methods.

If you mean a simple way to plug in new CCIDs like CCID4 etc then the
answer is no. However two people are working on CCID4 which may make
the code more modular.

Hope this helps,

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
