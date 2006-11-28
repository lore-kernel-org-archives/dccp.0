From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Nov 2006 20:46:56 +0000
Subject: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> |  Will look at it tomorrow (along with performance testing existing
> |  changes in tree) as meant to be preparing coursework and working on
> |  PhD today.... Agree MSS is problematic at present without PMTU. My
> |  thoughts were to have moving average and explicit s setting as two
> |  options available to user. If they don't set s then use moving
> |  average. I agree with Eddie that users should be able to define s if
> |  they want to.
> .... but then it needs support in the API as well. The broken socket API is what really
>      worries me - there would be this one socket option which is only for CCID 3 and only for
>      experimental work.
>
Why is it broken? The RFC says that the user can have the option of
setting the packet size s, so it is not experimental. Yes it is only
for CCID3 but there are already lots of things that are CCID2 or CCID3
only.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
