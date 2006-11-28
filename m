From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 28 Nov 2006 12:34:21 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <39e6f6c70611280434j1e2ca7a1v3002d0bc68962a9e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/28/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Eddie Kohler:
> |  Gerrit:
> |
> |  I am able to read code.  When I look at the existing Linux code and patches
> |  for CCID 3, I see a lot of corner cases designed to handle the
> |  TFRC_SSTATE_NO_FBACK state.
> |
> |  That state may not need to exist.  CCID 3 always has an RTT estimate, provided
> |  by the request/response exchange.  Removing this state would improve the code.
> |    You think the state is required for standards compliance.  Well, the
> |  standard's author is trying to tell you differently.  This is not about
> |  "experimental" features, this is about interpretations of the core spec.  You
> |  seem to think that only you can interpret the core spec correctly; this is not
> |  so.  And if an erratum is published, following that erratum will be required
> |  for "standards compliance".
> |
> |  The "nominal packet size" is not "experimental" either, it is explicitly
> |  allowed by the spec.
> |
> |  Thanks for your work on DCCP, which I **really do appreciate**.  However, I
> |  really do NOT appreciate your tone.
> I am not going to argue, you are entitled to your own opinion and who am I to say whether
> it is wrong or right? And if you can walk away from this discussion with material to provide
> an erratum for future implementers and ideas for improving the specifications, then this
> discussion has in fact been constructive.

Indeed constructive, even if at times too, humm, "nervous" :)

> Good for you - but it does not solve the issues with the Linux implementation, which remains
> as yet another half-completed attempt.

I guess its more than 60% after last month 8-)

> I think it would suit your and our purposes better if instead of debating the latest erratums
> and how X could also be implemented using method Z (while X is at least working without failure),
> there were some concerted effort to achieve at least _one_ completed implementation. Otherwise,
> it takes only 3 more years and then there will be a sad anniversary of 10 years of TFRC/DCCP research
> without even a single completed implementation.

<bad joke>
The ultimate irony is a half completed DCCP implementation on top of IPv6 ;-)
</bad joke>

> This is was the email below says - sorry if you did not appreciate the tone of it.

Lets get over it :-)

Take a look at the state of DaveM's tree today, its completely in sync
with mine and has most things merged, except for the packet size and
TRFC equation patches, that I thought a day or two would be nice for
further discussion.

- Arnaldo
