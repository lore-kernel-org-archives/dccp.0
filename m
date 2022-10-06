From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 06 Oct 2022 13:07:24 +0000
Subject: Re: [f2fs-dev] [PATCH v1 3/5] treewide: use get_random_u32() when possible
Message-Id: <CAHmME9r2u86Ga1UL_yD6x44OX84UJbRQyfhhDjF1daXyaYsbEw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
In-Reply-To: <Yz7Rl7BXamKQhRzH@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Oct 6, 2022 at 7:01 AM Andy Shevchenko
<andriy.shevchenko@linux.intel.com> wrote:
>
> On Thu, Oct 06, 2022 at 06:33:15AM -0600, Jason A. Donenfeld wrote:
> > On Thu, Oct 06, 2022 at 10:43:31AM +0200, Jan Kara wrote:
>
> ...
>
> > > The code here is effectively doing the
> > >
> > >     parent_group = prandom_u32_max(ngroups);
> > >
> > > Similarly here we can use prandom_u32_max(ngroups) like:
> > >
> > >             if (qstr) {
> > >                     ...
> > >                     parent_group = hinfo.hash % ngroups;
> > >             } else
> > >                     parent_group = prandom_u32_max(ngroups);
> >
> > Nice catch. I'll move these to patch #1.
>
> I believe coccinelle is able to handle this kind of code as well

I'd be extremely surprised. The details were kind of non obvious. I
just spent a decent amount of time manually checking those blocks, to
make sure we didn't wind up with different behavior, given the
variable reuse.

Jason
