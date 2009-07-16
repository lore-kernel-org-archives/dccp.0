From: Leandro Sales <leandroal@gmail.com>
Date: Thu, 16 Jul 2009 19:27:32 +0000
Subject: Re: How can i retrieve the ecn nonce information in a dccp datagram
Message-Id: <5bc4c4570907161227lfe43f46p9cd1f211d19b7d4a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210907131839t545900dfjf7c9dfd529fbecb5@mail.gmail.com>
In-Reply-To: <cb00fa210907131839t545900dfjf7c9dfd529fbecb5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

I'm in the Linux Symposium, in Montreal, and there were some people
asking about the DCCP feedback to the user space applications. The ECN
bit is one of the requirements from them. So, it is very important to
have this available as soon as possible.

Ivo, when I get back to the laboratory or to Brazil we can discuss
more about this issue.

BR,
Leandro.

On Thu, Jul 16, 2009 at 2:40 PM, Gerrit Renker<gerrit@erg.abdn.ac.uk> wrote:
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
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Leandro Melo de Sales
Pervasive and Embedded Computing Laboratory
Assistent Professor in Computer Science at Federal University of Alagoas
PhD candidate in Computer Science at UFCG

"The warrior is strong in loyalty, intensity, determination,
initiative, persistence, courage and willpower. The warrior is light
in the soul, self-trust and compassion. The warrior is often called to
take the front when other cowardly make a step backwards. There are
warriors on the battlefield and in everyday life."

http://www.leandrosales.com/
