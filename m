From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 10 Jan 2007 11:32:32 +0000
Subject: Re: [SUMMARY]: Problems with loss interval recalculation / audit against [RFC 3448, 5.4]
Message-Id: <200701101132.32655@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701051829.20415@strip-the-willow>
In-Reply-To: <200701051829.20415@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > Hence the detection of a loss event always triggers insertion of the sequence number
|  > and timestamp at the head of the list.
|  > With regard to your above comment, we should probably change this so that I_0 is
|  > not stored on top of the list - or adapt the list handling so that I_0 can be distinguished
|  > from I_1 ... I_k (k <= 8).
|  >
|  I_0 is not stored at the head of the list. It is stored in non-loss. I
|  can understand the confusion as my code wasn't clear.
There is still some confusion here, but it is not due to your code. With regard to I_0, the
highest sequence number before the loss occurred and the accompanying CCVal is stored at the
head of the list. The interval length stored in this history entry is invalid, in your patch
the interval length is computed - which is correct.
But we do need a bit more clarification about the interval length of I_0 here:

 -> start from the highest sequence number received before the loss (as your code does) or
 -> use "the number of packets received since the last loss event" as specified in [RFC 3448, page 16]

Hence the previous email to Eddie which I hope he will be able to answer.

  
|  > So I think what we can take home as `todo' items from this is
|  >  * correct the list handling with regard to I_0
|  >  * ensure that I_1 ... I_8 all fit in the list
|  >  * compute the interval length I_0 as done for `non_loss' in Ian's patch
|  >  * change the summation loop so that it matches the one in the RFC
|  >
|  
|  I've changed all the code to match the RFC and added a few more
|  comments. I believe my logic was correct but extremely confusing as
|  I'd reversed i_tot0 and i_tot1 meanings not to mention how I had done
|  the loop counters!! I've not made it so you can read along the RFC
|  even though the same thing is done.
|
|  
|  I'm glad to tidy this up as this was a bit messy in BSD, got munted in
|  the change to Linux. Being in arrays would help clarity (but not
|  results) quite a bit further I think too.
|  
|  Patch to follow.
|  
I think you are jumping to conclusions too quickly. No one is blaming you or your patch. 
The problem is the current state of the CCID 3 module is full of bugs, some of which interact with the
code your patch takles - it is like opening a can of worms.

There are 12 bugs in the loss handling alone (and maybe I have missed some?), cf.
http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/detect_loss_algorithm/summary_of_loss_handling_issues.txt

Therefore, we need to be careful about what we are doing. Patches can only help at this stage if they
not only remove existing bugs, but also do not provide a hinderance in removing others. This is difficult.
