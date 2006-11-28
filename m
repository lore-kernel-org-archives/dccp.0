From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 11:32:34 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <200611281132.34735@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Eddie Kohler:
|  Gerrit:
|  
|  I am able to read code.  When I look at the existing Linux code and patches 
|  for CCID 3, I see a lot of corner cases designed to handle the 
|  TFRC_SSTATE_NO_FBACK state.
|  
|  That state may not need to exist.  CCID 3 always has an RTT estimate, provided 
|  by the request/response exchange.  Removing this state would improve the code. 
|    You think the state is required for standards compliance.  Well, the 
|  standard's author is trying to tell you differently.  This is not about 
|  "experimental" features, this is about interpretations of the core spec.  You 
|  seem to think that only you can interpret the core spec correctly; this is not 
|  so.  And if an erratum is published, following that erratum will be required 
|  for "standards compliance".
|  
|  The "nominal packet size" is not "experimental" either, it is explicitly 
|  allowed by the spec.
|  
|  Thanks for your work on DCCP, which I **really do appreciate**.  However, I 
|  really do NOT appreciate your tone.
I am not going to argue, you are entitled to your own opinion and who am I to say whether
it is wrong or right? And if you can walk away from this discussion with material to provide
an erratum for future implementers and ideas for improving the specifications, then this
discussion has in fact been constructive. 

Good for you - but it does not solve the issues with the Linux implementation, which remains
as yet another half-completed attempt.

I think it would suit your and our purposes better if instead of debating the latest erratums 
and how X could also be implemented using method Z (while X is at least working without failure), 
there were some concerted effort to achieve at least _one_ completed implementation. Otherwise,
it takes only 3 more years and then there will be a sad anniversary of 10 years of TFRC/DCCP research
without even a single completed implementation.

This is was the email below says - sorry if you did not appreciate the tone of it.
  

|  Gerrit Renker wrote:
|  > Quoting Eddie Kohler:
|  > |  Hi Gerrit, Ian,
|  > |  
|  > |  I am not sure I am completely following this discussion, but there is one 
|  > |  point I wanted to bring up.  DCCP senders DO have an estimate of the 
|  > |  round-trip time even BEFORE the first feedback packet, namely from the 
|  > |  Request-Response exchange.  RFC 4342 senders and receivers can use the RTT 
|  > |  measured by the core DCCP protocol.  Reading over RFC 4342, this is extremely 
|  > |  not clear (sorry), but it was our intention.  (Sally, this is right, yes?)  We 
|  > |  will put together an erratum for the RFC Editor.
|  > This is an experimental feature and also appears in draft-ietf-dccp-rfc3448bis-00.txt,
|  > section 4.2:
|  >     "If the sender does have a round trip sample when it is ready to
|  >      first send data (e.g., from the SYN exchange or from a previous
|  >      connection [RFC2140]), the initial transmit rate X is set to
|  >      W_init/R, and tld is set to the current time."
|  > 
|  > However, this is a draft, still under revision and subject to further change. 
|  > 
|  > The Linux CCID 3 module is at present not even compliant with 3448 / 4342, and we are having
|  > enough work getting that done. There is therefore at the moment little point in thinking
|  > about what could be done and what should be done: what we are implementing is RFC 4342/3448, 
|  > not more.
|  > 
|  > And if what is in the specification was not your intention, then this is certainly not our problem!
|  > 
|  > You are suggesting and requesting features for which there is no support currently in the RFCs
|  > (see e.g. your earlier suggestion to re-introduce a socket option for packet sizes). 
|  > 
|  > What you are suggesting is helpful only for yourself as a writer of specifications, but it is not
|  > helpful for those who have to implement these specifications. If we give in to suggestions which
|  > are not documented by IETF-reviewed and IETF-approved standards documents, then we end up doing 
|  > experimental work while the main target (a standards-compliant DCCP stack) is not even finished.
|  > 
|  > Therefore, let me put it very clearly: I am against implementing anything which is not stated in 
|  > RFCs 3448, RFC 4340, RFC 4341, and RFC 4342. About the rest we might talk when the Linux implementation
|  > matches these RFCs, but before we have accomplished that: please stop sending feature requests or
|  > annotations which are not part of the publicly and IETF-approved RFCs. For these purposes, please
|  > use dccp@ietf instead. 
|  > 
|  > I am sure we can work out a constructive way of dealing with your interests as well, but it is certainly
|  > not via the avenue of implementing feature requests which you state without contributing in work or in
|  > funding.
|  > 
|  > Gerrit
|  > 
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
