From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 16:51:03 +0000
Subject: RFC: patch backlog
Message-Id: <39e6f6c70704120951k67eae7cfuc0c14c52a770e05d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi,

       I've applied the first 29 patches in Gerrit's patch backlog at
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/, i.e. all
the way to "[CCID3]: History access is redundant when sending
feedback", aka 10d_CCID3-RX-Feedback_Sans-History-Access.diff, its now
at:

Web access:
http://git.kernel.org/?p=3Dlinux/kernel/git/acme/net-2.6.22.git;a=3Dshortlog

GIT URL:
git://git.kernel.org/pub/scm/linux/kernel/git/acme/net-2.6.22.git

      I understand there is still some disagreement over this one:

"[CCID3]: Avoid accumulation of large send credit"

http://git.kernel.org/?p=3Dlinux/kernel/git/acme/net-2.6.22.git;a=3Dcommitd=
iff;h=86a703f86b9e54c1c12679e34aa1e3cf16360076

       I have to read the arguments presented by Eddie and Ian, and we
can always fix this at some point when consensus is reached, but for
now, to help in getting the pile of good work Gerrit has done I've
merged it.

        The few changes I made were commented in messages I've sent to
this list today, will try to find time again to go over the rest of
the backlog, there are some that were acked by Ian, but not some, so
if Ian could take a look at the ones without an ACK I'd really
appreciate.

- Arnaldo
