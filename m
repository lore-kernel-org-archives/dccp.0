From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 08:12:40 +0000
Subject: Re: [PATCH 0/25] Towards CCID3/CCID4 code integration
Message-Id: <20071108081240.GA6071@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1193810064.7357.249.camel@embedded-ephone1.embedded.ufcg.edu.br>
In-Reply-To: <1193810064.7357.249.camel@embedded-ephone1.embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > As it is done currently, I can't see much benefit: there are only three
| > functions in tfrc_ccids.c:
| >
| >  * rfc3390_initial_rate
| >  * tfrc_hc_tx_idle_rtt
| >  * tfrc_hc_tx_update_win_count
| >
| > The first and last of the above functions are declared inline. Inlines inside a
| > source file are not often considered a good idea; according to current wisdom one
| > should leave it to gcc to decide whether to make a function inline or not.
| >
| 
| The inline declarations were done just to maintain the current code,
| which was current using inline. But, in fact I can remove the inline
| declaration.
| 
These functions were originally declared locally in ccid3.c, as `static
inline'. The situation is now different - this file is a library, and
the symbols are exported with EXPORT_SYMBOL. When the functions were
first introduced for ccid3.c there were some discussions as to what to
inline and what not; I believe that the current mixture in ccid3.c is
fairly consistent, but the situation is different when functions are
moved/shared. Actually, all three of the above could appear in a header
file, since tfrc_hc_tx_idle_rtt is also really short.


| The idea of my patches is to propose an initial code sharing between
| ccid3/ccid4 ("towards ccid3/4 integration"). After these patches, we
| can work to share more code between ccid3/ccid4 to tfrc_ccids.c, like
| you suggested using generic code.
| 
Again, I think it is better for the moment if you use whatever helps you
to get your implementation going, and leave aside the desire to merge

As far as I can see, the CCID4 code is not even finished yet.
Then there are several other things which will change, too:
 * rfc3448bis is currently being revised, next IETF will probably see a
   new version, then people will discuss, and even more changes;
 * these changes will somehow influence CCID4, too (code and specification);
 * the CCID4 draft is a moving target, too rev01 came out in June, but
   Floyd's webpage already has a new revision online.

I think that there is absolutely no harm if you start off with code
duplication, there is even a quote by Torvalds that "duplicated code
is good". While you are implementing, you will automatically note the
patterns and identify where the same thing happens twice. 

But doing this at the start is likely to just create confusion. 

An example is in the two nearly empty header-files ccid{3,4}.h: why do
you want to keep these for "future use"? If redundant, they can go, but
if you keep things for future use they will pile up and in the end no
one knows why it is still there.
