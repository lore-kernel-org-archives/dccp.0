From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 09:27:05 +0000
Subject: Re: [PATCH 1/5] CCID 4: Adds Kconfig, Makefile, and new CCID to include/linux/dccp.h
Message-Id: <5640c7e00709250227l4e74a704x30de416121fac08d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920112021.GB1288@kikai.katei.fi>
In-Reply-To: <20070920112021.GB1288@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/25/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Ian McDonald wrote:
> |   + * 16-20ms to match the typical multimedia inter-frame interval
> |  > + * 100ms as a reasonable compromise [default]
> |  > + * 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
> |  > +
> |
> |  But Linux actually uses 250 ms for TCP here, not 1000 ms. You might
> |  want to add that.
> |
> The others are not guilty of this change - the text was copied verbatim from the CCID3 menu.
> And the CCID3 menu was copied from emails on dccp@ietf. I think Colin Perkins suggested the
> lower, frame-based value, whereas 100ms were suggested by Mark Handley. Good to know about
> the Linux value -- this is all meant for experimentation, maybe the 1000ms can then go?
> I have been using the default of 100ms for a long while, but not done feedback loss tests.

I've just cced you all in on something I dug up through the iccrg list
not so long ago. Makes interesting reading.

Regards,

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
