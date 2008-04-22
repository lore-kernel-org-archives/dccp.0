From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 22 Apr 2008 20:45:53 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804222245.53322.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Dnia Tuesday 22 of April 2008, napisałeś:
> Tomasz Grobelny wrote:
> > Dnia Monday 21 of April 2008, Arnaldo Carvalho de Melo napisał:
> >> Nod, if we don't need the space reserved for the lower layer protocols
> >> in DCCP it is actually the best solution, as we don't need to zero the
> >> cb again before passing it to IP, it gets zeroed at alloc_skb time and
> >> that is it. If we need the space, we have to pay the price of
> >> memset before passing to IP.
> >
> > Ok, so in this case the patch for DCCP could be reverted in test tree, is
> > that right? Were these two deleted memsets zeroing all that was necessary
> > or were there any other bugs fixed by the patch?
>
> No, those two memsets became unnecessary by the addition
> of the new cb members. If you want to remove them again,
> you need to add those memsets back and additionally add
> memsets that zero the first sizeof(inet_skb_parm)/
> sizeof(inet6_skb_parm) bytes everywhere else where packets
> are passed to IP(v6).
Maybe I wasn't clear enough with my question. I understand that these two 
memsets would have to be readded. But my question is: did you identify any 
bugs that were caused by junk in skb->cb before applying your patch? If so, 
do you have any test cases? It could help to check code for correctness if 
one day more space in skb->cb will be needed (which of course doesn't have to 
be in the nearest future).
-- 
Regards,
Tomasz Grobelny
