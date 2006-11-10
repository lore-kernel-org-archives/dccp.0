From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 10 Nov 2006 13:55:08 +0000
Subject: Re: [PATCH] dccp: remove module exit functions
Message-Id: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/10/06, James Morris <jmorris@namei.org> wrote:
> The dccp ipv4 & ipv6 modules cannot be unloaded, as their control sockets
> each maintain a couple of module references.  So, it seems like a good
> idea to just remove the module exit functions completely.
>
> Please review.

Well, I have a patch in the DCCP backlog that uses it, ressurecting
the unload hack, for development purposes being able to destroy the
control sockets allowing module removal is something the DCCP
developers want :)

- Arnaldo
