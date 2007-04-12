From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Apr 2007 11:40:08 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <200704121240.08923@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[not cc:ed to dccp@ietf]

There are some interesting points here, but please consider the other message
also. From an implementation point of view and in the current absence of a
normative or majority-supported view on how to deal with accumulation of send
credits which do in fact arise, I think it is safer and better to for the moment
stick with the default of one t_ipi as maximum current credit.

Quoting Ian McDonald:
|  Do we need to do some sanity checks on the rtt and adapt based on
|  that? I don't actually have the answers yet as just started thinking
|  about this and thought worthwhile kicking off a discussion as a real
|  implementation issue for CCID3 in Linux.
This sounds to me like the oscillation prevention mechanism from RFC 3448, which 
is expressly meant for networks with low statistical multiplexing (e.g. LANs). 

I have it in the pipeline but didn't want to submit until the present patches are
through, since it requires to change the computation of X, for which I would like
to have a review and decision first.
