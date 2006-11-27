From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Mon, 27 Nov 2006 13:48:36 +0000
Subject: Re: [PATCH 2/6]: Simplify control flow in the calculation of t_ipi
Message-Id: <39e6f6c70611270548x46e2a073jb46c8527c2920f96@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.18544@strip-the-willow>
In-Reply-To: <200611211545.18544@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On 11/27/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  For now I'm merging the patch changing just the commit log not to stat=
e that the
> |  comment was wrong, i.e. I think its just superfluous :-)
> |
> |  As I'm putting these csets in the 'ccid3' branch of my net-2.6.20 git
> |  tree if you disagree about any of the things I change today (Sunday)
> |  we can always go back and fix it before sending the whole lot to Dave.
> If you haven't committed these (they are not in your tree yet), can you p=
lease

Its in the 'ccid3' branch, look at the bottoom of:

http://www.kernel.org/git/?p=3Dlinux/kernel/git/acme/net-2.6.20.git;a=3Dsum=
mary

Or directly in:

http://www.kernel.org/git/?p=3Dlinux/kernel/git/acme/net-2.6.20.git;a=3Dsho=
rtlog;h=CCid3

But as I said in one of my messages yesterday, this one was just a
first stab at merging your ccid3 work, I'm now getting back to getting
the ones where there was general agreement to submit to Dave, then
look again at the others.

> consider the attached update where I have corrected commit message?

I'll use the updated one.

> Will put this online, too.

Thanks,

- Arnaldo
