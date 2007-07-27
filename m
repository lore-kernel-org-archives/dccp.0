From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 27 Jul 2007 15:21:05 +0000
Subject: Re: [PATCH 5/5]: Revert use of MSS instead of s
Message-Id: <200707271621.05523@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.53153@strip-the-willow>
In-Reply-To: <200707261356.53153@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  I want to think about this. In particular the reference to VoIP - go
|  look at CCID4 and that's EXACTLY what they do in effect (but standard
|  frames - not jumbo).
 The reference to VoIP/jumbo frames is not relevant in this context, what is
relevant is thatthe code did not correspond to the current state of what 
several documents specify to use as default for `s'. That's enough justification
for me.

I don't understand the above comment about VoIP.

|  I'm heading down the patch that we should set 3448bis via a socket
|  option as well as faster restart but maybe that's a question we should
|  ask on the IETF list. 
If you want to do this and come back with some usable results to this list, feel free
to do this. I'd like to hear the results, but don't want to participate in IETF discussions.
I have lots of other work to do and am doing the DCCP/CCID3 work on top of it / aside
of it. That means for me `technical support yes' but `research discussions on the IETF
list (which is a specification list): no'. 

|  It really depends on whether existing TFRC is meant to be phased out and 
|  replaced or whether the application can choose - like a lot of TCP 
|  enhancements e.g. SACK. I think 3448bis should be the default but whether 
|  the only option is another question...
I disagree with the idea. It is already the case that the many documents (3448, 4340,
4342, rfc3448bis, Faster Restart draft) all make related, but in a subtle way different
interpretations of the same thing. I recall that when I did the patches, I would spend
reading up to two or three hours the different drafts, because they are all not really
consistent. What you are proposing is a parallel implementation of both the orthodox
RFC 4342/3448 if I understand you correctly. With that you only increase the number of
nightmares, since now you need not only align drafts, but also track sub-changes of 
different drafts in the code.

My suggestion is to keep the most common-sense collection of features as default and
to do everything else on a case-by-case or experimental basis. Already the code is not
really orthodox RFC 4342, we have for instance the Request/Response RTT sample which
is not part of the document, and there are several other features (can list them if
needed) that make the code not a true RFC 3448/4342 implementation.

We could fork subtrees for such features, how about this? That would keep defaults
and new features separate, at least for a while, and they can be integrated when the
specification gains maturity.


So what is your stance regarding the `s' vs `MSS' issue? This patch is according
to the book, I sent it to make your Faster Restart work a bit easier, and you
are saying you don't want it?
