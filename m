From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 22 Jun 2006 04:55:04 +0000
Subject: Re: Locking validator output on DCCP
Message-Id: <5640c7e00606212155p167e1f07p8b4740b08ccd607a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
In-Reply-To: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/21/06, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> > > Can someone tell me whether I am correct in my thinking or not? If I
> > > am then I will work out how to tell the lock validator not to worry
> > > about it.
> >
> > I agree, this looks bogus.  Ingo, could you please take a look?
>
> sure - Ian, could you try Arjan's fix below?
>
>         Ingo
>
> ------------------------------------------------------------
> Subject: lock validator: annotate vlan "master" device locks
> From: Arjan van de Ven <arjan@linux.intel.com>
>
The fix you sent here was the incorrect one but I did test Arjan's as
per previous e-mail.

Real dumb question time. The lock validator is testing for recursive
lock holding. Given that this is a lock at a different address can we
eliminate all such cases? Or are you trying to detect code here that
keeps on locking same type of lock in case of error and we should
explicitly flag...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
