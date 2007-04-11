From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Apr 2007 08:12:52 +0000
Subject: Re: [PATCH 39/43]: Protect against Reset/Sync floods due to buggy applications
Message-Id: <200704110912.52445@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704051637.18198@strip-the-willow>
In-Reply-To: <200704051637.18198@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  Will have to read more about rate limiting though as I'm
|  not convinced normally about rate limiting schemes etc as they
|  invariably end up causing problems when doing things like running a
|  huge server with lots of connections. However as I said, haven't read
|  it yet so might be wrong on your intent.
RFC 4340. 7.5.4 says that this rate-limiting is a SHOULD. I had similar
thoughts in mind regarding the overhead that this mechanism incurs. That
is why it is kept as simple as possible. Something like xrlim_allow is
already too complicated (cf. comments).
