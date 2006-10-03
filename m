From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 03 Oct 2006 19:54:41 +0000
Subject: Re: PACKET_SIZE option and congestion control on variable-length packets
Message-Id: <5640c7e00610031254q6ad01599ic5e0a88cb433f1ea@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200610021108.57676@strip-the-willow>
In-Reply-To: <200610021108.57676@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 10/3/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > |  > Strategy
> > |  > ----------
> > |  > 1/ Remove the PACKET_SIZE socket options as they don't help with the problem;
> > |  >     I have therefore updated Ian's patch to be used standalone [attached].
> > |
> > |  NAK this patch. At present it just sets s to be 256 bytes where the
> > |  spec says to use the MSS. My patch is not perfect but it is better
> > |  than this as it allows you to set the size where you can't at present,
> > |  nor with this patch.
> > Oops, this is going into an entirely wrong direction! The posting is not about patches,
> > it presented a strategy for discussion, and sums up an extract of the reading I have been
> > stuck with for a couple of days.
>
> You are posting onto a development list with a patch. Of course I am
> going to discuss the patch. If you had posted to the discussion
> without the patch my answer would have been very different!
>
My apologies to you on this. I have just worked through my ideas in
another thread and proved myself wrong.

> > 1) The real problem is not in patches - RFC 4340..2 are elusive and in parts outright wrong
> >    about assumptions on the packet size. Substantial evidence that for instance using MSS
> >    as fixed `s' is detrimental was provided in the last posting.
>
> Agree 100% as you can see in my other posting. I think packet size/sec
> is better for CCID3 but not allowed.
>
> > 2) Weighted average was introduced as a strategy to resolve this in an implementable format.
>
> Agree this is better.
>
By my calculations you don't need to do this now as it calculates the
correct packet sending rate. Would be easy to verify but I don't have
my equipment available right now or the time.

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
