From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 31 Jul 2009 00:11:56 +0000
Subject: Re: How can i retrieve the ecn nonce information in a dccp datagram
Message-Id: <cb00fa210907301711y17571bb6o6a872667978c5f68@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210907131839t545900dfjf7c9dfd529fbecb5@mail.gmail.com>
In-Reply-To: <cb00fa210907131839t545900dfjf7c9dfd529fbecb5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Gerrit and everybody,
=A0=A0 we made the merge between the CCID4 (with our new patches) and ECN
trees to allow us implement some features of TRFC-SP. The merge was a
success (neither compile error nor kernel panic :P). Everything is
working fine :)!
However we are in doubt about what dccp branch our patches should be
applied, because the TRFC-SP has relation with CCID4 branch but also
depends of ECN branch Therefore, these patches don't strictly fit with
ecn or ccid4 branch.
So, what should we do about it?

I have another doubt, how stable the ECN branch is? Are there a lot
improvements to be done in the next few days or weeks?

Cheers,

Ivo


On Thu, Jul 16, 2009 at 14:40, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> Ciao Ivo,
>
> | However, we didn't know how we can access the ECN nonce information in
> | the DCCP datagram. Can we access this information directly from the
> | datagram or is there a predefined way to do that?
> |
> The stock kernel does not support ECN bits.
>
> It is really my fault, I forgot to announce that there is a separate tree
> to support ECN. This extends the ECN support to the extent that ECN bits
> can be modified and read even in userspace. There were also some programs
> to work with the userspace ECN modifications, and continuing work on this.
>
> The tree is available from
>
> =A0git://eden-feed.erg.abdn.ac.uk/dccp_exp [subtree 'ecn']
>
> =A0http://eden-feed.erg.abdn.ac.uk/latest-ecn-subtree.diff.gz
>
> =A0http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3D=
shortlog;h=ECn
>
> This is all from work several months ago, as said, I just forgot to
> activate/announce it. The patch is meant to be applied on top of the
> either the DCCP or CCID-4 tree.
>
> Will also start posting the ECN-tree patches to the list.
>
> Please post any further issues regarding ECN support, looking forward to
> hearing from you.
>
> Gerrit



--
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.



--
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
