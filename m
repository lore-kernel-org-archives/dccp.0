From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 20 Aug 2007 22:36:54 +0000
Subject: Re: Kernel version of Arnaldos Net Git tree
Message-Id: <5640c7e00708201536o72c06fd1p6535e5da88b356d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
In-Reply-To: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/21/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
>
> Hello list,

You forgot to cc list!

>    I tested using Linus and David Miller and the problem of watchdog
> didn't happen. But using both Arnaldo or Gerrit I got the watchdog
> problem! :( How often gerrit sync his git repository into Arnaldo git
> and how often Arnaldo do this into David Miller netdev git tree?
>
> Leandro.
>
If it's any consolation then I went to test on one of my machines and
it won't boot either. I'm running an older version of Gerrit's tree
modified a lot (for faster restart testing).

So I'll try doing the same sort of thing as you too now, but first
I'll try Gerrit's more recent tree. Basically Gerrit and Arnaldo and
Dave sync their trees when they feel like it. Generally before
submitting upstream people tend to resync to check their patches still
apply. Gerrit and Arnaldo and I will often sync off Dave M's release+1
tree (currrently 2.6.24) as this is where networking changes go if the
merge window is not currently open (Linus only allows changes up to
rc1 of any release).

What you and I might have to do is take Gerrit's tree and pull his
changes out of the tree (they are the most recent patches) and apply
them to Linus' latest tree. I don't know the syntax for this yet but
will tell you if I have to do this (please tell me the syntax if you
do it first!!). We will need Linus' tree rather than Dave
M's/Arnaldo's tree (even if they rebase) as at the moment with
Arnaldo's recent patch set I'm pretty sure Gerrit's patches won't
apply cleanly any more until he reworks his patch set. The joys of
distributed development!

Hope this is of some use.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
