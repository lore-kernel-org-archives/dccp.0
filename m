From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 05 Sep 2007 15:43:47 +0000
Subject: Re: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <200709051643.47426@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708291113.07431.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291113.07431.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Ok, thanks - I am looking forward to further collaboration and patches.

As said, the format of the test tree is not set in stone and I'd be happy t=
o change it
and discuss alternatives - whichever way is best.=20

It is also possible to store more stuff - that is what the thing consumes e=
lectrical
energy for. I.e. if the CCID4 folks want to store stuff, that's welcome too.


|  > | =A0Aha. I see what you mean now. I think the best thing to do here i=
s to
|  > | =A0label each block of code introduced, that is specific to a versio=
n,
|  > | =A0with the version of the document used.
|  > That's why I thought a separate branch would be nice - it keeps all do=
cumentation and patches together
|  > so that even after some pauses in between one knows where the code cam=
e from and what it was good for.
|  >
| =20
|  That's fine by me.
