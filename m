From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Dec 2008 10:54:22 +0000
Subject: Re: [RFC] [Patch 4/4] dccp: Integrate the TFRC library (dependency)
Message-Id: <20081223105422.GA8209@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20081220080826.GE3853@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081220080826.GE3853@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Arnaldo,

thanks a lot for the replies. The patches that I have sent were also
bona fide 'RFC', i.e. they also need more work. I am in the process
of revising the patches again, but will probably not finish before
the holidays.

The plan is to address the comments, combine that with your patch
and then resubmit the tidied-up results.

| I.e. IP_DCCP_TFRC_LIB is also deleted, and in
| net/dccp/ccids/libs/Makefile we do simply:
|
| dccp-$(CONFIG_IP_DCCP_CCID3) += tfrc.o tfrc_equation.o packet_history.o loss_interval.o
|
At first I didn't like the removal of 'IP_DCCP_TFRC_LIB', but I also don't like
TFRC. If there is consensus to forget the expired CCID-4 then we can remove it,
otherwise we probably need to keep IP_DCCP_TFRC_LIB for the sake of CCID-4.

I tried above suggestion in different variations: the problem is that kbuild considers
objects for dccp-y/dccp-objs only from within the Makefile in net/dccp, i.e. the above
does not compile (lost a lot of time about it).

Hence I will revert to the previous solution which is similar to the above and worked
fine.

| P.S. It just feels wrong that TCP, that was not designed with multiple
| congestion modules in mind have in Linux a plugabble congestion control
| infrastructure, one idea that was something that BSD also adopted after
| Linux became a more easy platform to try new congestion algorithms.
| 
| Now DCCP, that was specifically designed with such infrastructure in
| mind will not have such facility :-\
| 
Yes, at the moment it is sad to see the loading and locking code go, in
particular since a lot of thought had been put into its design. Frankly,
I think that this code is too good/much/rich for the present situation.

The situation is that at the moment we only have a handful of CCIDs which
still need a lot more work (after the work that went in already) before they
could be considered a serious alternative to UDP/TCP/SCTP.

And I think that David Miller is right here - for those two CCIDs we don't
need elaborate locking/loading.

At the moment there are also no Internet Drafts specifying CCIDs. As soon
as there is one, the new CCID either becomes a potential new builtin CCID
or reaches the current state of CCID-4 ('expired').

But the 'builtin' solution also has a natural limit: each new CCID module
will increase the size of dccp.ko. A connection can only use 1 CCID (since
mixing different CCIDs for RX/TX is not practicable/supported), so loading
the code of 9 CCIDs where only one is used means a "size" overhead.

When and if this situation is reached it again would make sense to use
loadable modules, where the loading/locking scheme is then needed again.

Once this feature-negotiation patch set is over, we are one step ahead of TCP,
which was not designed for negotiating capabilities (e.g. the "negotiation"
of timestamp usage in RFC1323).

