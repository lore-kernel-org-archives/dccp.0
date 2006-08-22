From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 22 Aug 2006 03:29:11 +0000
Subject: Re: [BUG] CCID3 - loss not detected if in order
Message-Id: <5640c7e00608212029p7dff4b5eha0ea22f8ecba9bd9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
In-Reply-To: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/19/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > Yes it is a work in progress. I've actually fixed the receiver up and
> > now need to get the transmitter going at the correct rate. I'll try
> > and post my interim fixes to web later today and get some proper ones
> > early next week.
> >
> OK newer patches are at http://wand.net.nz/~iam4/dccp/patches/
>
> Apply all apart from bestpacketnext - the order is listed at series.
> --
I've just updated this patch set and uploaded and CCID3 performance is
now working properly for the first time (it has never worked totally
correctly).

I'm now going to spend the next day or two tidying this all up and
then I'll post to this list.

Arnaldo - how is your time looking as many of these are fixes that
would be cool in 2.6.18?
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
