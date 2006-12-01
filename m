From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 08:56:56 +0000
Subject: Re: [BUG] CCID3 performance is f**ked
Message-Id: <200612010856.57092@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
In-Reply-To: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  Folks,
|  
|  CCID3 is fscked up. Sorry to put it this way but thats how I feel.
|  
|  With 2.6.19rc6 plus the patches from
|  http://wand.net.nz/~iam4/dccp/patches/ it works fine. (The only
|  significant patch here is tx_qlen - all the rest should have no
|  impact).
Thank you for this carefully worded bug report :-)

Really, with the number of bugs that are still in the code, I am actually
amazed that we get this far 8-) 

I don't think that doing performance-testing at this stage is of any use.
When you repair your car and take out half of the engine, then take it
for a spin, do you expect top-gear performance?

I am aware that at least in the RTT calculation there are still bugs.

Another thing has to do with the RTO/nofeedback-timer issue. Thank you for
forwarding this onto the IETF list. May I remind you that using the TCP default
RTO of 1 second was precisely the non-standard behaviour CCID 3 used to have 
in 2.6.19??? So here is a likely explanation #2 for the amazing performance after
initial auditing against RFCs.

I am not convinced by mere performance results of earlier patches. The CCID3 code does
not even conform to RFC 3448 -- loss event rates are calculated at the receiver,
not at the sender; the receiver does not implement the window counter value; the
generation of loss interval options is missing; part of the RTT calculation is broken;
there is no sanity-checking of feedback packets; .....

Work to do!
