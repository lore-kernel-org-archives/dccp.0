From: David Miller <davem@davemloft.net>
Date: Sat, 11 Oct 2008 18:07:33 +0000
Subject: Re: v3 [PATCH 0/5] dccp: Feature negotiation, Part I - Underlying
Message-Id: <20081011.110733.43368493.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20081011073113.GA9205@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081011073113.GA9205@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 11 Oct 2008 09:31:13 +0200

> Thank you for taking the time to look through.
> 
> If we could keep this set going on as a low-key background process, that
> would be great. I found the pace not only more reviewer-friendly, but also
> more submitter-friendly, so it is in fact a good choice.

Well, just FYI at this point, networking is closed for the 2.6.28
merge window.

So all of this stuff will have to wait until 2.6.29 and I'm won't be
creating a net-next-2.6 tree for 2.6.29 for at least a few weeks while
people should be fixing bugs in 2.6.28.

So all of this screwing around caused all of the pending DCCP work to
miss the 2.6.28 merge window.
