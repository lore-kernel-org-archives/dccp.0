From: Ian McDonald <imcdnzl@gmail.com>
Date: Tue, 31 Jan 2006 01:21:19 +0000
Subject: Re: [RFC] TCP MTU probing
Message-Id: <cbec11ac0601301721g73e99d8y49725f3bcb318b5a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/31/06, David S. Miller <davem@davemloft.net> wrote:
> From: John Heffner <jheffner@psc.edu>
> Date: Tue, 06 Dec 2005 14:42:53 -0500
>
> > I'd like to get a few people at least to look this over, and maybe give
> > it a try.  One remaining item to consider is how best to cache the state
> > between connections.  Are there any major concerns or reservations about
> > this approach, or the patch itself?
>
Just having a read of this now (missed first time round) and I see
that PMTUD as per this RFC is also allowed by DCCP in it's spec
(Section 14.1).

> and then I'll happily at this in for net-2.6.17

At some future stage we should merge this into the DCCP tree too.
Looking at the code there are quite a few places where it has TCP in
there where maybe it would be better to have IP in there to save
further changes when DCCP starts to use the code....

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
