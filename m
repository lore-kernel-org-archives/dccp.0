From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 31 Oct 2007 13:15:17 +0000
Subject: Re: [PATCH 13/25] Share TFRC feedback types struct via ccid34_lib
Message-Id: <200710311315.17256@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710310959.15075@strip-the-willow>
In-Reply-To: <200710310959.15075@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Leandro,

following Arnaldo's reply, can you please you the suggested naming scheme (=
it is also
already used in packet_history.c and loss_interval.c): I will be looking in=
to merging
the patches with the CCID3 set of patches, to reduce work and duplication.

The whole lot of CCID3 patches will then be re-submitted. Arnaldo, I would =
like to make
your job easier by sending fewer patches (the CCID3 batch is 40 patches, pl=
us Leandro's):
would you be ok with a smaller number, e.g. 5..7?

There will also be a short RFC before this (regarding locking), and I will =
make sure that
the entire batch becomes fully bisectable.

Gerrit

Quoting Arnaldo Carvalho de Melo:
|  > enum tfrc_fback_type {
|  > // ...
|  > };
|  > =A0
|  > instead of:
|  >=20
|  > | =A0enum ccid34_fback_type {
|  > | =A0+ FBACK_NONE =3D 0,
|  > | =A0+ FBACK_INITIAL,
|  > | =A0+ FBACK_PERIODIC,
|  > | =A0+ FBACK_PARAM_CHANGE
|  > | =A0+};
|  >=20
|  > There are no mechanisms other than TFRC (current work builds around TF=
RC, rather than entirely new schemes)
|  > so I think that this naming scheme is safe; and it would be consistent=
 throughout the library.
|  >=20
|  > I'd hope that Arnaldo and Ian add their take if they disagree or have =
other suggestions.
| =20
|  I agree that for things which concept comes from TFRC and are used in
|  one of the TFRC based DCCP CCIDs the best possible namespace is tfrc_.
|  If not we'll have to rename everything again when CCID5 comes if it is
|  also based on TFRC 8-)
| =20
|  And after all, even before ccid4 appeared on the radar I created
|  dccp_tfrc_lib, include/linux/tfrc.h, etc exactly for sharing code with
|  potentially new CCIDs that were based on TFRC.
| =20
