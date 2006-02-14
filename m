From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 14 Feb 2006 08:20:08 +0000
Subject: Re: [BUG] Problem with feature negotiation
Message-Id: <20060214082008.GA6572@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602131606r3db89cbcp2fba640d61b92447@mail.gmail.com>
In-Reply-To: <cbec11ac0602131606r3db89cbcp2fba640d61b92447@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Feb 14, 2006 at 01:06:47PM +1300, Ian McDonald wrote:
> If either of you too can fix that it'd be cool otherwise I'll add it
> to my list of rainy day bugs....

I'll look into it myself.  I've been caught up on other stuff, so I wasn't able
to do much DCCP work lately.  I will very soon though [towards the end of the
week].

The last thing I was playing with was trying to fix the module reference count.
For some reason, I think there is an invalid reference count for client sockets.
This does not let you unload the module, which is painful for development.


Also, does anyone know if there is the equivalent of BSD divert sockets for
Linux?  I was planning to use those for making a DCCP test suite.  The
motivation is that you can intercept, inspect and drop packets.
