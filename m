From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 08 Apr 2008 18:20:07 +0000
Subject: Re: [RFC][PATCH 10/12][NETNS][DCCPV6]: Move the dccp_v6_ctl_sk on
Message-Id: <20080408182007.GB8192@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <47FBAB09.9000305@openvz.org>
In-Reply-To: <47FBAB09.9000305@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Apr 08, 2008 at 03:18:04PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Tue, Apr 08, 2008 at 09:27:37PM +0400, Pavel Emelyanov escreveu:
> > And replace all its usage with init_net's socket.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >  
> > -/* Socket used for sending RSTs and ACKs */
> > -static struct sock *dccp_v6_ctl_sk;
> > +/* dccp_v6_ctl_sk is used for sending RSTs and ACKs */
> 
> Wrong comment?
>   

Other than this:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

for the whole series.

- Arnaldo
