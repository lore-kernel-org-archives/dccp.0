From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 16 Jul 2009 17:40:39 +0000
Subject: Re: How can i retrieve the ecn nonce information in a dccp datagram
Message-Id: <20090716174039.GA5776@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210907131839t545900dfjf7c9dfd529fbecb5@mail.gmail.com>
In-Reply-To: <cb00fa210907131839t545900dfjf7c9dfd529fbecb5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Ciao Ivo,

| However, we didn't know how we can access the ECN nonce information in
| the DCCP datagram. Can we access this information directly from the
| datagram or is there a predefined way to do that?
|=20
The stock kernel does not support ECN bits.

It is really my fault, I forgot to announce that there is a separate tree
to support ECN. This extends the ECN support to the extent that ECN bits
can be modified and read even in userspace. There were also some programs
to work with the userspace ECN modifications, and continuing work on this.

The tree is available from

  git://eden-feed.erg.abdn.ac.uk/dccp_exp [subtree 'ecn']

  http://eden-feed.erg.abdn.ac.uk/latest-ecn-subtree.diff.gz

  http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dsho=
rtlog;h=ECn

This is all from work several months ago, as said, I just forgot to
activate/announce it. The patch is meant to be applied on top of the
either the DCCP or CCID-4 tree.

Will also start posting the ECN-tree patches to the list.

Please post any further issues regarding ECN support, looking forward to
hearing from you.=20

Gerrit
