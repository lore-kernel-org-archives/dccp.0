From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
Date: Thu, 04 Jan 2007 03:04:28 +0000
Subject: Re: [PATCH 4/4][NEW]: More to see in dccp_probe
Message-Id: <20070104.120428.111144640.yoshfuji@linux-ipv6.org>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00701031339u20f7ad2hf416821257f44214@mail.gmail.com>
In-Reply-To: <5640c7e00701031339u20f7ad2hf416821257f44214@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In article <5640c7e00701031339u20f7ad2hf416821257f44214@mail.gmail.com> (at Thu, 4 Jan 2007 10:39:18 +1300), "Ian McDonald" <ian.mcdonald@jandi.co.nz> says:

> On 1/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > [CCID 3]: More to see in dccp_probe
> >
> > This removes the `size' field from output (which would report the constant buffer size),
> > and adds a few more fields of interest to /proc/net/dccpprobe, the following output ensues:
> >
> I would like the size field kept. This is not constant if you are
> sending different size packets like I am :-) It is only constant if
> you are using something like iperf/ttcp.

I agree, and please do not insert new fields
but add them to the tail of old fields.

--yoshfuji
