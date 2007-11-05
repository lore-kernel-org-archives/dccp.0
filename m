From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Mon, 05 Nov 2007 14:51:33 +0000
Subject: Re: [PATCH 0/25] Towards CCID3/CCID4 code integration
Message-Id: <5bc4c4570711050651s49ad868fwd88fade89307249f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1193810064.7357.249.camel@embedded-ephone1.embedded.ufcg.edu.br>
In-Reply-To: <1193810064.7357.249.camel@embedded-ephone1.embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit,

2007/11/3, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> I've had a look at the recent set of patches, some more detailed comments below.
> Basically, I think it is too early to think of merging: it will constrain your
> work, at the moment there is really not much being shared, and to me it is not
> clear what shape the CCID4 code will eventually take.
>
> As it is done currently, I can't see much benefit: there are only three
> functions in tfrc_ccids.c:
>
>  * rfc3390_initial_rate
>  * tfrc_hc_tx_idle_rtt
>  * tfrc_hc_tx_update_win_count
>
> The first and last of the above functions are declared inline. Inlines inside a
> source file are not often considered a good idea; according to current wisdom one
> should leave it to gcc to decide whether to make a function inline or not.
>

The inline declarations were done just to maintain the current code,
which was current using inline. But, in fact I can remove the inline
declaration.

> If you do want to declare these two inline, you can put them into the header file --
> which then leaves you with only a single function in tfrc_ccids.c.
>

The idea of my patches is to propose an initial code sharing between
ccid3/ccid4 ("towards ccid3/4 integration"). After these patches, we
can work to share more code between ccid3/ccid4 to tfrc_ccids.c, like
you suggested using generic code.

> If there is really not more that you want to share between the CCIDs, then
> there is not much benefit in allocating an extra file; on the contrary, it just
> increases the confusion ("what is this file doing?"). Besides, there is already
> such a file for this purpose -- check net/dccp/ccids/lib/tfrc_module.c
>

But it exists. One example is the function which handles
DROPPED_PACKET_OPTION, that you mentioned. I just didn't try to share
more function because I intended to make all of you check the code and
discuss the directions and see if it is worthy to continue the job or
not.

> With regard to header files, there is a similar observation: due to putting
> everything into tfrc_ccids.h, ccid3.h now becomes a one-liner:
>         #include "lib/tfrc_ccids.h",
> so that you might as well remove ccid3.h entirely; ccid4.h has three more lines,
> when these are instead put at the top of ccid4.c, then ccid4.h is also no longer
> necessary.
>

I maintain the ccid{3/4}.h in case we need to use them eventually in the future.

> There is a disparity: almost no code is shared, while CCID3 and CCID4 use an
> exactly identical socket structure. When two different pieces of code share the same
> underlying data structure, then it is likely possible to share more code currently done.
>

Yes, this is the idea. The patches just starts up the job! :)

> Hence I am asking you what your plans are: keep the strategy of only sharing functions
> that previously appeared in both ccid3.c and ccid4.c -- in this case the number of new
> files can be reduced; or extend the work to also share functions which have the same
> functionality in both files.
>

The idea is to extend the work to also share functions which have the
same functionality, but for archive this, it is necessary to analyze
more carefully the code, as you mentioned below.

> Individual points:
> >  1 - Certify whether the function is common (checking just the functions
> >      in ccid-4 copied from ccid-3);
> >
> >  2 - Certify whether both functions (in ccid-3 and ccid-4) still common;
> >      (Me or Tommi can already changed it for ccid-4)
> Looking at the code, this seems to be just one category, of those functions which are
> 100% identical in both files.
>
> >  3 - Certify whether the both functions doesn't call a ccid specific function;
> >      i.e: ccid3_hc_tx_packet_sent could be shared, but it calls
> >      ccid3_hc_tx_update_s, which is a ccid-3 specific function.
> >      Then ccid3_hc_tx_packet_sent is not a candidate to be shared
> >      between ccid-{3/4}.  i.e: ccid3_hc_rx_packet_recv i.e:
> >      ccid3_hc_rx_insert_options
> It is possible to still share code here; by using a generic function which takes
> a function pointer to the CCID-specific function as argument. Realising this will
> reduce the amount of duplicated functionality, but requires careful analysis. May
> be able to help here, depending on how things progress.
>

Ok.

> >  4 - Certify whether the function has a low probability to be changed
> >  for ccid-4 implementation in the future;
> >
> >      * although ccid3_hc_tx_send_packet could be common, ccid-4 will
> >        probably have a particular way to decide when send a packet;
> >      * ccid4_first_li will certainly change because the short loss interval
> >        length is calculated as N/K, instead of using just N (ccid3_first_li);
> Ok, these functions really do different things and so keeping them separate seems the
> right thing to do.
>

Ok.

> >      * ccid3_hc_tx_parse_options could be common, but until the IETF
> >        folks do not decide if DROPPED_PACKET_OPTION will be into the ccid-3,
> >        I decided to NOT share it.
> Can't see the point: CCID3 does not use the experimental Dropped Packets Option
> (since it doesn't even use Loss Intervals), so there would be no harm in sharing
> this function -- at worst code which is not executed; whereas in the other case
> you have an almost identical function in two different places.
>

Yes, I can say that I was in doubt whether to share this function or
not and I you are right on this, I will submit a patch to share this
function.

>
> >  5 - Common sense: functions such as ccid3_hc_tx_init and ccid3_hc_tx_exit
> >      are very particular, probably we will want to have specific
> >      procedures to go into ccid-3, different to ccid-4 and vice-versa.
> So same category as the first two in (4).
>

Ok.

> To conclude and repeat, I think that it is better at this stage if you focus on getting y
> our CCID4 implementation to work; and decide afterwards about what to share and what not.
>
> It will be much easier to do: as it is often better to write the `introduction' section
> to some document _after_ the document has been constructed/written, since only then it is
> fully clear what the document is all about.
>

Ok, good decision! :)

> Last comment - I think that future changes to ccid3.c/ccid4.c are regrettably unavoidable,
> as the standardisation still depends on many work-in-progress Internet Drafts
> (such as rfc3448bis, ccid4 draft) which are constantly changing (hence "work in progress").
>

Leandro.
