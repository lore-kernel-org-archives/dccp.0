From: James Morris <jmorris@namei.org>
Date: Fri, 10 Nov 2006 16:24:35 +0000
Subject: Re: [PATCH] dccp: remove module exit functions
Message-Id: <XMMS.LNX.4.64.0611101122520.15046@d.namei>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
In-Reply-To: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, 10 Nov 2006, Arnaldo Carvalho de Melo wrote:

> On 11/10/06, James Morris <jmorris@namei.org> wrote:
> > The dccp ipv4 & ipv6 modules cannot be unloaded, as their control sockets
> > each maintain a couple of module references.  So, it seems like a good
> > idea to just remove the module exit functions completely.
> > 
> > Please review.
> 
> Well, I have a patch in the DCCP backlog that uses it, ressurecting
> the unload hack, for development purposes being able to destroy the
> control sockets allowing module removal is something the DCCP
> developers want :)

I wonder if this facility can be integrated more generally into the kernel 
protocol which people are developing.

Where is the patch you use?



- James
-- 
James Morris
<jmorris@namei.org>
