From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Wed, 11 Apr 2007 15:10:42 +0000
Subject: Re: [PATCH 39/43]: Protect against Reset/Sync floods due to buggy
Message-Id: <461CFA72.3030607@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200704051637.18198@strip-the-willow>
In-Reply-To: <200704051637.18198@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> Quoting Ian McDonald:
> |  Will have to read more about rate limiting though as I'm
> |  not convinced normally about rate limiting schemes etc as they
> |  invariably end up causing problems when doing things like running a
> |  huge server with lots of connections.

We pictured the rate limit (if implemented) as per connection, not for the 
whole stack, which is what Gerrit has done.  If the rate limit is considered 
too expensive it's fine to take out, of course; it is only a SHOULD.

Eddie


> |  However as I said, haven't read
> |  it yet so might be wrong on your intent.
> RFC 4340. 7.5.4 says that this rate-limiting is a SHOULD. I had similar
> thoughts in mind regarding the overhead that this mechanism incurs. That
> is why it is kept as simple as possible. Something like xrlim_allow is
> already too complicated (cf. comments).
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
