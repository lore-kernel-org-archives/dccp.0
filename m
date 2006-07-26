From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 26 Jul 2006 04:10:58 +0000
Subject: Re: Help: how to get the latest code?
Message-Id: <5640c7e00607252110m445214fvbdb610c7c34da916@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
In-Reply-To: <c583c3410607250521t1501d5f6i76e3c62e532c225a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there again,

On 7/26/06, Ma Lin <gavin.malin@gmail.com> wrote:
> Thanks lan!
>
> I am planning to change something in CCID2 for research purpose. I am
> quite novice in coding in the kernel level. Last night i got 2.6.27-1
> installed, and am happy to find that CCID2 is included in the DCCP
> package.

I presume you mean 2.6.17?

You will probably also want patches from here as DCCP CCID2 has needed
improving and Andrea Bittau has worked on this:
http://darkircop.org/dccp/

> But I get confused by the list of files in the package.
> Can you guys enlighten me a bit about what is every file mainly for?

Come back to us in a few days once you have tried to work it out as it
will make sense.

Maybe you are not looking at the relevant part of the tree - try
looking at files under net/dccp directory.
>
> My planned change in CCID2 is something to do with the sequence
> number, the non-cumulative ACK, and the moving of congestion window.
> Which files am I suppose to look at?
>
I'm not the CCID2 expert. Andra might be able to help you with it.

Please try to keep the discussion on the dccp mailing list as I'm not
the only (and certainly not the best!!) dccp progammer.

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
