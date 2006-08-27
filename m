From: David Miller <davem@davemloft.net>
Date: Sun, 27 Aug 2006 04:45:24 +0000
Subject: Re: [PATCH 0/7] [DCCP]: Fixes and enhancements
Message-Id: <20060826.214524.89039745.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <200608241516.34448.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200608241516.34448.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 27 Aug 2006 15:46:58 +1200

> On 8/27/06, David Miller <davem@davemloft.net> wrote:
> > >
> > > I would love 3, 4, 5 to go into 2.6.18 as these resolve long standing CCID3
> > > issues that have been in the DCCP tree since inception and have caught a
> > > number of people.
> >
> > Ok, I'll toss 1-5 into 2.6.18
> 
> Thanks for that. Are 6 and 7 going into 2.6.19 or do you want Arnaldo
> to have a bit more of a look? 6 in particular is trivial.

Those patches are already in net-2.6.19

> Basically the implementation in the DCCP code was buggy and was
> transmitting too fast so I have made it conform to the RFC much
> closer.

Thanks for the explanation.
