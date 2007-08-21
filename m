From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Tue, 21 Aug 2007 18:41:25 +0000
Subject: Re: Kernel version of Arnaldos Net Git tree
Message-Id: <5bc4c4570708211141p68f04f5cl4496c3b1a29e880e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
In-Reply-To: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/8/21, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> Ian, Leandro

Hi Gerrit and Ian,

>
> I fully sympathise with your experiences, having just been through much hell of
> rebasing the test tree to track Arnaldo's recent changes (dont' worry, it works
> and I will post the changes) and then finding out that 2 out of 3 computers no longer
> even boot due to changes somewhere else in the tree.
>

Yes, this is my case and yesterday I used linus-git with your dccp
code and everything worked fine. Today I pulled from your git tree and
also worked, but my laptop froze to times and I need to reboot it, I
don't now why!

> I am open to suggestions as to when to resynchronise the tree.
>

I don't have any particular opinion about that... I think that if we
report some malfunction (like this with watchdog, APIC, and so on) in
your tree and you merge your tree with the latest linus-git (or davem)
it is enough.

> What I will do, in any case, is put up a diff from a working version online.
>
> The test tree was synchronised yesterday against davem-2.6
>

Good from now!

> Gerrit
>
> Quoting Ian McDonald:
> |  > I tested using Linus and David Miller and the problem of watchdog
> |  > didn't happen. But using both Arnaldo or Gerrit I got the watchdog
> |  > problem! :( How often gerrit sync his git repository into Arnaldo git
> |  > and how often Arnaldo do this into David Miller netdev git tree?
> |  >
> |  > Leandro.
> |  >
> |  If it's any consolation then I went to test on one of my machines and
> |  it won't boot either. I'm running an older version of Gerrit's tree
> |  modified a lot (for faster restart testing).
> |
> |  So I'll try doing the same sort of thing as you too now, but first
> |  I'll try Gerrit's more recent tree. Basically Gerrit and Arnaldo and
> |  Dave sync their trees when they feel like it. Generally before
> |  submitting upstream people tend to resync to check their patches still
> |  apply. Gerrit and Arnaldo and I will often sync off Dave M's release+1
> |  tree (currrently 2.6.24) as this is where networking changes go if the
> |  merge window is not currently open (Linus only allows changes up to
> |  rc1 of any release).
> |
> |  What you and I might have to do is take Gerrit's tree and pull his
> |  changes out of the tree (they are the most recent patches) and apply
> |  them to Linus' latest tree. I don't know the syntax for this yet but
> |  will tell you if I have to do this (please tell me the syntax if you
> |  do it first!!). We will need Linus' tree rather than Dave
> |  M's/Arnaldo's tree (even if they rebase) as at the moment with
> |  Arnaldo's recent patch set I'm pretty sure Gerrit's patches won't
> |  apply cleanly any more until he reworks his patch set. The joys of
> |  distributed development!
>
