From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 20:31:12 +0000
Subject: Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <200611282031.12818@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611281435.05466@strip-the-willow>
In-Reply-To: <200611281435.05466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  On 11/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > Quoting Ian McDonald:
|  > |  I think I didn't explain my point well here. You can't change to u32
|  > |  but need to be unsigned int (not u64).
|  > Don't get this: u32 is a 32-bit unsigned value and therefore looks sufficient - and you
|  > are proposing `unsigned int' to have easier conversion to skb->len, right?
|  >
|  OK. On 64 bit platform unsigned int = 64 bits and we are passing a 64
|  bit argument (skb->len) into a 32 bit parameter. We either need to
|  explicitly typecast or change wherever you have put u32 to unsigned
|  int.
|  
|  Arnaldo probably knows which way is better from his experience.
My suggestion then is
 a) remove third arg of send_packet(), use skb->len directly
 b) implement `unsigned int' as third parameter of packet_sent()

=> Arnaldo what do you think?

|  > Would really appreciate if you could at some time have a look at the moving-average patch. Have communicated
|  > with Eddie again about it, and using MSS would at the moment be much more complicated.
|  >
|  Will look at it tomorrow (along with performance testing existing
|  changes in tree) as meant to be preparing coursework and working on
|  PhD today.... Agree MSS is problematic at present without PMTU. My
|  thoughts were to have moving average and explicit s setting as two
|  options available to user. If they don't set s then use moving
|  average. I agree with Eddie that users should be able to define s if
|  they want to.
.... but then it needs support in the API as well. The broken socket API is what really
     worries me - there would be this one socket option which is only for CCID 3 and only for
     experimental work. 
