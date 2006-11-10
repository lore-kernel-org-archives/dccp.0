From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 10 Nov 2006 18:32:16 +0000
Subject: Re: [PATCH] dccp: remove module exit functions
Message-Id: <39e6f6c70611101032v5f0be644ta65069cf533b3385@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
In-Reply-To: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/10/06, James Morris <jmorris@namei.org> wrote:
> On Fri, 10 Nov 2006, James Morris wrote:
>
> > I wonder if this facility can be integrated more generally into the kernel
> > protocol which people are developing.
>
> Ugh, editor screwup.  That was meant to be
>
> I wonder if this facility can be integrated more generally into the kernel
> as a kernel hacking option, as this is not the only protocol which people
> are developing.
>

See:
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09a_release_ctl_socket_at_exit.diff

This one requires a bit more thinking, so I'm postponing it for now to
get the simple bits in Gerrit's patch queue cherrypicked and sent for
Dave.

- Arnaldo
