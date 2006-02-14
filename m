From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Date: Tue, 14 Feb 2006 15:12:34 +0000
Subject: [PATCH/RFC]: Re: Problem with feature negotiation
Message-Id: <39e6f6c70602140712k5579e1bfy2445f45e9c97f966@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/14/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> On Tue, Feb 14, 2006 at 01:06:47PM +1300, Ian McDonald wrote:
> > If either of you too can fix that it'd be cool otherwise I'll add it
> > to my list of rainy day bugs....
>
> I'll look into it myself.  I've been caught up on other stuff, so I wasn't
> able to do much DCCP work lately.  I will very soon though [towards the end of
> the week].

Take a look at my tree, I guess its fixed now by setting the defaults according
to the selection of CCIDs in the kernel config, i.e. if CCID2 is built
it is the default,
as the spec states, but if it isn't CCID3 becomes the default and an #error is
spit if no CCID has been selected for compilation.

Please test and report results, then I'll push for Dave to get it into 2.6.17

>
> The last thing I was playing with was trying to fix the module reference
> count.
> For some reason, I think there is an invalid reference count for client
> sockets.
> This does not let you unload the module, which is painful for development.

I'll try to reproduce this here, perhaps I haven't noticed because in my tests
I use mostly qemu and when building a new kernel I just reboot the whole
virtual machine, not reloading the modules explicitely.

>
> Also, does anyone know if there is the equivalent of BSD divert sockets for
> Linux?  I was planning to use those for making a DCCP test suite.  The
> motivation is that you can intercept, inspect and drop packets.

Look at the netfilter documentation, I guess its something called ulog.

- Arnaldo
