From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Fri, 08 Sep 2006 09:48:41 +0000
Subject: Re: Proposed socket API change
Message-Id: <20060908094841.GA12047@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <200609081031.41701@strip-the-willow>
In-Reply-To: <200609081031.41701@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Sep 08, 2006 at 10:31:41AM +0100, gerrit@erg.abdn.ac.uk wrote:
> Suggested Change: If user doesn't want to set a service code, that's fine,
>                   leave the service code associated with connection at 0.

I totally agree with you on this, but I have been killed when suggesting this on
dccp@itef.org.

> Justification: 
> In a forthcoming communication to SIGCOMM-06, the inventors of DCCP say that
> they were "motivated by keeping the basic API as simple as UDP's" and that
> "DCCP should provide applications with an API as simple as that of UDP".

I think the same authors killed me on this point.  I believe their motivation is
"we want service codes to be used" and that they are a useful thing.  I agree
with them, but I don't agree on "forcing the users to use service codes".  

In practice, I think the situation will end up just as you described:
programmers will say "what is a service code?" and all weird things will start
emerging by people setting random codes just to get their application working.
Indeed, question 1 of Linux's DCCP FAQ will end up being: "connect() returns
error HELP!  Did you set a SC?".  Most of the initial DCCP applications will be
test apps anyway, and I think the burden of "inventing" a service code or
assigning one should be avoided.
