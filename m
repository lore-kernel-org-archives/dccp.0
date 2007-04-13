From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 13 Apr 2007 09:48:46 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <5640c7e00704130248u579e17f6w7e1f7544160254f0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Cool it Ian.
>
> I think you are interpreting something into the email I sent which is not in
> there. This is exactly the kind of talk I was asking for and I am glad that
> Dave reviewed this.

The mistake I made was that I didn't change the subject of the email
as it didn't apply to this patch really. You are correct in that.
>
> Please read that email again.
>
> I am asking for fair technical review here and rather than calling me names you
> could put some care into what you write.

Well I would have much rather discussed in private but a) you've told
Eddie not to reply in public and the way stated seems to imply I
shouldn't either b) you said that we were unreasonably holding up your
patches in public. It warranted a response but I'm done with my name
calling (for now).
>
> If for instance you read the documentation accompanying that patch, there is a
> difference between 100 usec ... 1msec between skb_get_timestamp and taking the timestamp
> in the CCID3 receiver. It all adds up.
>
I think we need to look at whether the protocol is right for LANs but
I think if we carry out Eddie's suggestions it may well be right.
Against earlier code a couple of months ago with a couple of my
patches I was achieving around 90 Mbits/sec on iperf which matched TCP
performance and it was stable. It responded gracefully to loss also.

I have not tested lately and tried to replicate but I know that the
state of tree before current patches couldn't do that any more... As
time permits I will redo the work.

DCCP CCID3 has proven stable in simulations in ns2 I understand and it
has been stable previously as well (though not in Linus' tree ever) so
rather than say all these inaccuracies are causing problems we need to
work on the solutions.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
