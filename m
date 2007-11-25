From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 25 Nov 2007 16:53:18 +0000
Subject: Re: TX history patches was: Re: Test tree patch inventory - update
Message-Id: <20071125165318.GB5783@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071122203015.GE17441@ghostprotocols.net>
In-Reply-To: <20071122203015.GE17441@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > Also did you test this code? The patch on which this is based has been
| > subjected to some extensive regression-testing. I can't tell if it will
| > perform as intended.
| 
| I performed testing, not exhaustive as the code should be equivalent to
| what you had done, or can you find, from code inspection, something
| suspicious?
|  
Probably not - the code looks correct. I am probably paranoid, but after
some bad experiences I test everything I do even if the change is a trivial
one.

| > The main intention of this patch set has been to separate more clearly between ccid3.c,
| > loss_interval.c, and packet_history.c. If RTT measurement is done in the above way, then
| > we don't gain much from the new patches.
| 
| Well we gain the fact that it is now uses a single linked list, that is
| what I tried to do in simplifying this patch.
| 
Sorry I think you got me wrong. You have done a great job in making this patch even simpler and I
fully agree with that -- the general idea is that with this simplification it is much better now.
I think I was just being picky about details.

| > 	int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
| > 	{
| > 	       struct tfrc_tx_hist_entry *entry = tfrc_tx_find_entry(head, ackno);
| > 
| > 	       if (entry != NULL) {
| > 		       *stamp = entry->stamp;
| > 		       tfrc_tx_hist_purge(&entry->next);
| > 		       return 1;
| > 	       }
| > 	       return 0;
| > 	}
| > 
| > One of the main problems in the TFRC/CCID3 code has been (and to some extent still is)
| > that the code is so deeply intertwined that it is almost impossible to keep functionality separate.
| 
| I have no problem with this.
| 
| So we do:
| 
| 1. convert the TX history to use a single linked list and use
|    just one slabcache.
| 
| 2. hide the internal TX history implementation details, since
|    what the CCIDs are interested in is the time the packet
|    being acknowledged or the extreme case where it couldn't find it
|    in whatever data structure the TX history implementation uses.
|
Point (1) is your addition to the patch and as said, I really like this.
With the second point I also agree, and also thought this over: I had a problem with
a missing RTT value somewhere else (retransmission of Close/CloseReq).
If only we had a way of performing RTT measurement in the main module, the entire
TX list could go. But until then it would be great to just hide away the TX history
implementation details as you suggest.

| > The comment below has the same background, but I suspect that you did
| > this only as a temporary solution to make the module compile?
| 
| Yes, see below.
|  
I almost expected this so please forget the comment.
