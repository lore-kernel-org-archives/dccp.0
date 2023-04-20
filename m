From: Breno Leitao <leitao@debian.org>
Date: Thu, 20 Apr 2023 14:43:56 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <ZEFPrGSuDopUwi9V@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Apr 18, 2023 at 03:41:24PM -0400, Willem de Bruijn wrote:
> Breno Leitao wrote:
> > On Thu, Apr 13, 2023 at 10:24:31AM -0400, Willem de Bruijn wrote:
> > > > How to handle these contradictory behaviour ahead of time (at callee
> > > > time, where the buffers will be prepared)?
> > > 
> > > Ah you found a counter-example to the simple pattern of put_user.
> > > 
> > > The answer perhaps depends on how many such counter-examples you
> > > encounter in the list you gave. If this is the only one, exceptions
> > > in the wrapper are reasonable. Not if there are many.
> > 
> > 
> > Hello Williem,
> > 
> > I spend sometime dealing with it, and the best way for me to figure out
> > how much work this is, was implementing a PoC. You can find a basic PoC
> > in the link below. It is not 100% complete (still need to convert 4
> > simple ioctls), but, it deals with the most complicated cases. The
> > missing parts are straighforward if we are OK with this approach.
> > 
> > 	https://github.com/leitao/linux/commits/ioctl_refactor
> > 
> > Details
> > ===> > 
> > 1)  Change the ioctl callback to use kernel memory arguments. This
> > changes a lot of files but most of them are trivial. This is the new
> > ioctl callback:
> > 
> > struct proto {
> > 
> >         int                     (*ioctl)(struct sock *sk, int cmd,
> > -                                        unsigned long arg);
> > +                                        int *karg);
> > 
> > 	You can see the full changeset in the following commit (which is
> > 	the last in the tree above)
> > 	https://github.com/leitao/linux/commit/ad78da14601b078c4b6a9f63a86032467ab59bf7
> > 
> > 2) Create a wrapper (sock_skprot_ioctl()) that should be called instead
> > of sk->sk_prot->ioctl(). For every exception, calls a specific function
> > for the exception (basically ipmr_ioctl and ipmr_ioctl) (see more on 3)
> > 
> > 	This is the commit https://github.com/leitao/linux/commit/511592e549c39ef0de19efa2eb4382cac5786227
> > 
> > 3) There are two exceptions, they are ip{6}mr_ioctl() and pn_ioctl().
> > ip{6}mr is the hardest one, and I implemented the exception flow for it.
> > 
> > 	You could find ipmr changes here:
> > 	https://github.com/leitao/linux/commit/659a76dc0547ab2170023f31e20115520ebe33d9
> > 
> > Is this what you had in mind?
> > 
> > Thank you!
> 
> Thanks for the series, Breno. Yes, this looks very much what I hoped for.

Awesome. Thanks.

> The series shows two cases of ioctls: getters that return an int, and
> combined getter/setters that take a struct of a certain size and
> return the exact same.
>
> I would deduplicate the four ipmr/ip6mr cases that constitute the second
> type, by having a single helper for this type. sock_skprot_ioctl_struct,
> which takes an argument for the struct size to copy in/out.

Ok, that is a good advice. Thanks!

> Did this series cover all proto ioctls, or is this still a subset just
> for demonstration purposes -- and might there still be other types
> lurking elsewhere?

It does not cover all the cases. I would say it cover 80% of the cases,
and the hardest cases.  These are the missing cases, and what they do:

* pn_ioctl     (getters/setter that reads/return an int)
* l2tp_ioctl   (getters that return an int)
* dgram_ioctl  (getters that return an int)
* sctp_ioctl   (getters that return an int)
* mptcp_ioctl  (getters that return an int)
* dccp_ioctl   (getters that return an int)
* dgram_ioctl  (getters that return an int)
* pep_ioctl    (getters that return an int)


Here is what I am using to get the full list:
 # ag  --no-filename -A 20 "struct proto \w* = {"  | grep .ioctl | cut -d "=" -f 2 | tr -d '\n'

 dccp_ioctl, dccp_ioctl, dgram_ioctl, tcp_ioctl, raw_ioctl, udp_ioctl,
 udp_ioctl, udp_ioctl, tcp_ioctl, l2tp_ioctl, rawv6_ioctl, l2tp_ioctl,
 mptcp_ioctl, pep_ioctl, pn_ioctl, rds_ioctl, sctp_ioctl, sctp_ioctl,
 sock_no_ioctl

> If this is all, this looks like a reasonable amount of code churn to me.

Should I proceed and create a final patch? I don't see a way to break up
the last patch, which changes the API , in smaller patches. I.e., the
last patch will be huge, right?

> Three small points
> 
> * please keep the __user annotation. Use make C=2 when unsure to warn
>   about mismatched annotation

ack!

> * minor: special case the ipmr (type 2) ioctls in sock_skprot_ioctl
>   and treat the "return int" (type 1) ioctls as the default case.

ack!

> * introduce code in a patch together with its use-case, so no separate
>   patches for sock_skprot_ioctl and sock_skprot_ioctl_ipmr. Either one
>   patch, or two, for each type of conversion.

I am not sure how to change the ABI (struct proto) without doing all the
protocol changes in the same patch. Otherwise compilation will be broken between
the patch that changes the "struct proto" and the patch that changes the
_ioctl for protocol X.  I mean, is it possible to break up changing
"struct proto" and the affected protocols?

Thank you for the review and suggestions!

PS: I will take some days off next week, and I am planning to send the
final patch when I come back.
