From: David Howells <dhowells@redhat.com>
Date: Wed, 29 Mar 2023 14:39:33 +0000
Subject: Re: [RFC PATCH v2 48/48] sock: Remove ->sendpage*() in favour of sendmsg(MSG_SPLICE_PAGES)
Message-Id: <518631.1680100773@warthog.procyon.org.uk>
List-Id: <dccp.vger.kernel.org>
References: <20230329141354.516864-49-dhowells@redhat.com>
In-Reply-To: <20230329141354.516864-49-dhowells@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hannes Reinecke <hare@suse.de> wrote:

> > [!] Note: This is a work in progress.  At the moment, some things won't
> >      build if this patch is applied.  nvme, kcm, smc, tls.

Actually, that needs updating.  nvme and smc now build.

> Weelll ... what happens to consumers of kernel_sendpage()?
> (Let's call them nvme ...)
> Should they be moved over, too?

Patch 42 should address NVMe, I think.  I can't test it, though, as I don't
have hardware.

There should be no callers of kernel_sendmsg() by the end of this patchset,
and the only remaining implementors of sendpage are Chelsio-TLS, AF_TLS and
AF_KCM, which as stated in the cover, aren't yet converted and won't build.

> Or what is the general consensus here?
> 
> (And what do we do with TLS? It does have a ->sendpage() version, too ...)

I know.  There are three things left that I need to tackle, but I'd like to
get opinions on some of the other bits and I might need some help with AF_TLS
and AF_KCM.

That said, should I just remove tls_sw_do_sendpage() since presumably the data
is going to get copied(?) and encrypted and the source pages aren't going to
be held onto?

David
