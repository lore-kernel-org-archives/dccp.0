From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 06:38:04 +0000
Subject: Re: Kernel version of Arnaldos Net Git tree
Message-Id: <200708210738.05395@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
In-Reply-To: <5bc4c4570708191944j789a4e31u9ef23d55512e420b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Ian, Leandro

I fully sympathise with your experiences, having just been through much hel=
l of
rebasing the test tree to track Arnaldo's recent changes (dont' worry, it w=
orks
and I will post the changes) and then finding out that 2 out of 3 computers=
 no longer
even boot due to changes somewhere else in the tree.=20

I am open to suggestions as to when to resynchronise the tree.=20

What I will do, in any case, is put up a diff from a working version online.

The test tree was synchronised yesterday against davem-2.6

Gerrit

Quoting Ian McDonald:
|  > =A0 =A0I tested using Linus and David Miller and the problem of watchd=
og
|  > didn't happen. But using both Arnaldo or Gerrit I got the watchdog
|  > problem! :( How often gerrit sync his git repository into Arnaldo git
|  > and how often Arnaldo do this into David Miller netdev git tree?
|  >
|  > Leandro.
|  >
|  If it's any consolation then I went to test on one of my machines and
|  it won't boot either. I'm running an older version of Gerrit's tree
|  modified a lot (for faster restart testing).
| =20
|  So I'll try doing the same sort of thing as you too now, but first
|  I'll try Gerrit's more recent tree. Basically Gerrit and Arnaldo and
|  Dave sync their trees when they feel like it. Generally before
|  submitting upstream people tend to resync to check their patches still
|  apply. Gerrit and Arnaldo and I will often sync off Dave M's release+1
|  tree (currrently 2.6.24) as this is where networking changes go if the
|  merge window is not currently open (Linus only allows changes up to
|  rc1 of any release).
| =20
|  What you and I might have to do is take Gerrit's tree and pull his
|  changes out of the tree (they are the most recent patches) and apply
|  them to Linus' latest tree. I don't know the syntax for this yet but
|  will tell you if I have to do this (please tell me the syntax if you
|  do it first!!). We will need Linus' tree rather than Dave
|  M's/Arnaldo's tree (even if they rebase) as at the moment with
|  Arnaldo's recent patch set I'm pretty sure Gerrit's patches won't
|  apply cleanly any more until he reworks his patch set. The joys of
|  distributed development!
