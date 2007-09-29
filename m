From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 29 Sep 2007 16:24:18 +0000
Subject: Re: [PATCH 2/9]: Query supported CCIDs
Message-Id: <200709291724.18832@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.17307@strip-the-willow>
In-Reply-To: <200709281630.17307@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > +static u8 builtin_ccids[] =3D {
|  > +=A0=A0=A0=A0=A0DCCPC_CCID2,=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/* CCI=
D2 is supported by default */
|  > +#if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MOD=
ULE)
|  > +=A0=A0=A0=A0=A0DCCPC_CCID3,
|  > +#endif
|  > +};
| =20
|  This considers only code that was already merged. What about a new CCID
|  that is not yet merged? I guess the table should be managed at ccid
|  module registration time... but that would prevent autoloading on
|  demand, so I think that a sysctl interface that tells the DCCP core
|  infrastructure which are the ccids that are available is better.
|
For each new CCID (which is likely to have a Kconfig option), the table wou=
ld
need a new entry. The table is not necessary for autoloading, this is handl=
ed
separately, and there is flexibility in handling this. Currently (subsequent
patch), all advertised CCIDs are autoloaded at socket creation time (only if
this is the first socket call, not when the CCID modules are already loaded=
),
since ccid_new() is later only called in interrupt context. But this has the
nice byproduct that module loading is no longer needed - firing up the appl=
ications
at either end is sufficient to have everything loaded.
=20
|  Think also about an administrator deciding that even with the Linux
|  kernel provided by his vendor containing modules for ccid2, 3, etc, he
|  only accepts ccid3 or some other subset.
That is an interesting thought - defining system-wide policies. The above t=
able is
much more primitive, it mainly is book-keeping to see what is there.
Do you mean something like net.ipv4.tcp_available_congestion_control ?

| =20
|  We could have as default a table built with the modules we know at dccp
|  core build time to be available in the current kernel build, but not
|  prevent others from being added or existing ones to be disabled.
The disabling can also be done on a per-connection basis, via socket option=
s.
One pain with the server-priority negotiation (and reason for the table) is=
 that
when only a single value is used, then it only works if both ends happen to=
 hit
the same value. One can exploit this fact to limit the choices.


|  So I think we can start with what you provided and implement my
|  suggestions later.
I am saving this in my todo folder and hope we can continue this thread.
