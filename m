From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 19 Sep 2006 21:19:54 +0000
Subject: Re: [PATCH 6/10]: [DCCP] CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <20060919211954.GA3180@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <20060914171207.GG20651@mandriva.com>
In-Reply-To: <20060914171207.GG20651@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Sep 20, 2006 at 09:04:12AM +1200, Ian McDonald wrote:
> Remember Dave merged my tx queueing recently so this is available now

I don't think tx queueing immedeately "helps" solving this problem.  It's an
architectural change that I'm proposing.  In the current API, DCCP is the
"master" and asks the CCID if it can send.  The CCID either says yes, or says
"ask me again in X time".  I don't think this is great because some CCIDs don't
really have a concept of time.  In rate based protocols, perhaps there is a way
to say "OK I can send after X time" but in window based protocols it's "upon the
reception of the next ack".  OK one can give an esitmate of time [rtt/cwnd?] but
it still isn't great.

By reversing the architecture, I think this problem is solved quite neatly.  In
this case, it is the CCID which drives DCCP.  The API would be: CCID tells DCCP
"hey, you can send" and DCCP sends happilly.  Not a poll & push model as before,
but rather a pull model from CCID's perspective.

To make this even more efficient, CCID could say, "hey you can send X packets".
This way, with a single notification from CCID, DCCP may drain its tx queue.
There needs to be a mechanism for CCID to stop "pulling" from DCCP.  For
example, when DCCP doesn't want to send anything, CCID shouldn't say "hey u can
send X packets".  CCID can either infer this by noting that DCCP didn't send
anything after a notification, or DCCP may explicitly turn notifications off
when it's queue size is 0.  Perhaps the latter is better.

To summarize, the API would be as follows.  DCCP would implement:
void pull(int x); /* Called by CCID, indicating that DCCP may send x packets */

CCID would implement:
void notify(int true); /* if true, CCID will pull from DCCP, else not */
