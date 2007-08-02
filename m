From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 02 Aug 2007 14:40:02 +0000
Subject: Re: [PATCH 5/5]: Revert use of MSS instead of s
Message-Id: <200708021540.02720@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.53153@strip-the-willow>
In-Reply-To: <200707261356.53153@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > Can understand that - that is partly why I suggested to wait a little,=
 and see if and the
|  > two drafts stabilise. If there were updates to 4342 then I would also =
be all for tracking
|  > them. However, 4342 is written in such a clever way that updates of 34=
48 do not apply.
|  > I am in support of the 3448 draft changes that are in the kernel so fa=
r, since to my
|  > understanding they improve the performance over an `orthodox' 4342; th=
e point being that
|  > no one cares how orthodox the implementation is when the performance i=
s awful.
|  >
|  Unfortunately I can't really wait too long as it is for my thesis.
|  That's OK as I can reference which draft I use. It has been suggested
|  for CCID3.bis (and agreed) that CCID3 should track TFRC.

I have enquired about the status of rfc3448bis - the situation at the momen=
t seems that there
are a lot of changes in rfc3448bis which have not gone through community re=
view yet; there are
further edits/changes which need to be addressed (probably in the next revi=
sion for the December
IETF meeting); and only after this has been done can some stabilisation be =
expected. Until
then there are probably going to be many changes. It seems that Faster Rest=
art is being rewritten
into a new algorithm, using something like TCP cwnd validation.

For me this all looks very experimental, but it can be useful to experiment=
. Therefore, if you
wanted to, the offer is there to put all this stuff as a fork of the test t=
ree.
=20
|  > | =A0If you do have a list of them it would be great. I see quite a few
|  > | =A0comments about bis in the code.
|  > I don't have a list at present, need to go through the works. Will pos=
t at a later point.
|  >
|  Don't worry too much about this, as this is my research so don't want
|  to waste your time :-)
Thanks - much appreciated, this can take a little time.
