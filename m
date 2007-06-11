From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 08:39:08 +0000
Subject: Re: [PATCH 3/3]: Update computation of X to use newer timeofday interface
Message-Id: <200706110939.08144@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091933.09514@strip-the-willow>
In-Reply-To: <200706091933.09514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  This looks OK but...
|  > -static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
|  > +static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
|  >
|  I don't see callers updated. Is this what you mean by patches being
|  interdependent?
That is right - the callers are updated in the next bundle of patches. This
set contains 29 patches in total, divided into the following sets:
 1. ktime_t update                   [sent]
 2. RTT and timestamping patches     [sent]
 3. CCID3 TX history - locking and migration to singly-linked list
   (suggestion by Arnaldo)                          => to be sent
 4. Update of computation wrt draft rfc3448bis-00   => to be sent
 5. Miscellaneous CCID3 patches                     => to be sent
 6. Miscellaneous DCCP patches                      => to be sent

The callers are updated in subset (4) - I will send that later today.

These patches are first and foremost meant for the upcoming `experimental' tree,
I was thinking that sending one or two bundles at a time is better than sending
the whole 29 patches at once. 

Once they are in the tree, after going through this stage, the relationships are
easier to see. 

Thus, interdependencies are unavoidable at this stage, but they have been minimised
to quite a great degree: with some labour, 5 patches that overlapped with others
were merged across 50 or so patches. 

Doing even more integration would make them less readable.
