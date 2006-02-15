From: Ian McDonald <imcdnzl@gmail.com>
Date: Wed, 15 Feb 2006 17:48:06 +0000
Subject: Re: [PATCH] 1/1 dccp: transmit buffering
Message-Id: <cbec11ac0602150948g3f1b1364vc171e08a8e90aa86@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
In-Reply-To: <cbec11ac0602061504y3507004dnf8b13d089d9fceba@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> > Still bit short of time but tested some more and found it clashed with
> > feature negotiation so will need more work :-( One of the problems is
> > with the code stopping the retransmit timer in feature negotiation.
> > Removing that fixes it for standard test cases but it then fails with
> > delay of 50 ms and 10% loss using netem where it worked without
> > feature negotiation for me. Might be bottom half locking perhaps -
> > haven't tested changes to that yet.
>
> Andrea, can you take a look at this one?

It may yet be a race I think. You can wait until I test my code with
bh locks (it only happens when my code is merged...)
>
> Well, it checks, look at its usage of mod_timer to see if the timer was
> pending and if not drop the lock, i.e. no refcount leakage here, if you
> are worried about races that is why we use the timer routine under
> bh_lock_sock()/bh_release_sock(), look at ccid3_hc_tx_no_feedback_timer.

That is my exact worry - races - so that solves it now for me. Thanks
a lot Arnaldo.

--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
