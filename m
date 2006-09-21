From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 21 Sep 2006 23:37:17 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <5640c7e00609211637v3ef96b54kf6efe6c6c13a4e76@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/22/06, Gorry Fairhurst <gorry@erg.abdn.ac.uk> wrote:
> Let, me add a few more thoughts, and see what others think...
>
> * I also have a problem with how to find "s" when thinking about an
> "unknown" application. I'm not really sure how this is intended to work for
> variable-sized packets. Calculating an average value for an application that
> naturally varies the size doesn't seem to me to be straight-forward.
>
> One value of "s" that makes sense, is possibly the largest segment size sent
> by the session. This is at least conservative - for fixed-sized flows it is
> identical to the optimum "s". For bursty flows, it is safe.
>
It is actually the opposite of what you say here. If you do the maths
and set s large then you can send more packets per second than what
you should be able to.

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
