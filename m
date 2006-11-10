From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 10 Nov 2006 13:50:35 +0000
Subject: RFC about 07a_putative_nested_lock_in_rcv.diff
Message-Id: <39e6f6c70611100550w7343a3d5l45cc0e4bc4703d0d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

        I'm going over the_whole_lot patch queue from you, many thanks
for doing this work! About 07a_putative_nested_lock_in_rcv.diff, I
haven't studied the bh_lock_sock_nested, lockdep stuff, but can't we
just use bh_lock_sock_nested in sk_receive_skb?

        I'm postponing this one for now, will look again after the
more simple patches are merged.

- Arnaldo
