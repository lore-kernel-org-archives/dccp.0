From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 19 Sep 2006 21:28:51 +0000
Subject: Re: [PATCH 6/10]: [DCCP] CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <5640c7e00609191428t45c755c3s2796de0b3b8d759f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060914171207.GG20651@mandriva.com>
In-Reply-To: <20060914171207.GG20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/20/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> On Wed, Sep 20, 2006 at 09:04:12AM +1200, Ian McDonald wrote:
> > Remember Dave merged my tx queueing recently so this is available now
>
> I don't think tx queueing immedeately "helps" solving this problem.  It's an

Understand totally. I wasn't saying tx queueing would solve world
hunger. It just helps you with the proper approach - doesn't solve it
as there is a whole lot more to do...

> To make this even more efficient, CCID could say, "hey you can send X packets".
> This way, with a single notification from CCID, DCCP may drain its tx queue.

If tx queueing doesn't help, how do you drain your tx queue when you
don't have one :-)
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
