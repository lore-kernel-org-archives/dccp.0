From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 17:58:53 +0000
Subject: Re: [PATCH 2/9]: Query supported CCIDs
Message-Id: <20070929175853.GS23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.17307@strip-the-willow>
In-Reply-To: <200709281630.17307@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Sat, Sep 29, 2007 at 05:24:18PM +0100, Gerrit Renker escreveu:
> Quoting Arnaldo Carvalho de Melo:
> |  > +static u8 builtin_ccids[] =3D {
> |  > +=A0=A0=A0=A0=A0DCCPC_CCID2,=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/* C=
CID2 is supported by default */
> |  > +#if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_M=
ODULE)
> |  > +=A0=A0=A0=A0=A0DCCPC_CCID3,
> |  > +#endif
> |  > +};
> | =20
> |  This considers only code that was already merged. What about a new CCID
> |  that is not yet merged? I guess the table should be managed at ccid
> |  module registration time... but that would prevent autoloading on
> |  demand, so I think that a sysctl interface that tells the DCCP core
> |  infrastructure which are the ccids that are available is better.
> |
> For each new CCID (which is likely to have a Kconfig option), the table w=
ould
> need a new entry. The table is not necessary for autoloading, this is han=
dled
> separately, and there is flexibility in handling this. Currently (subsequ=
ent
> patch), all advertised CCIDs are autoloaded at socket creation time (only=
 if
> this is the first socket call, not when the CCID modules are already load=
ed),
> since ccid_new() is later only called in interrupt context. But this has =
the
> nice byproduct that module loading is no longer needed - firing up the ap=
plications
> at either end is sufficient to have everything loaded.
> =20
> |  Think also about an administrator deciding that even with the Linux
> |  kernel provided by his vendor containing modules for ccid2, 3, etc, he
> |  only accepts ccid3 or some other subset.
> That is an interesting thought - defining system-wide policies. The above=
 table is
> much more primitive, it mainly is book-keeping to see what is there.
> Do you mean something like net.ipv4.tcp_available_congestion_control ?

I haven't looked, but perhaps, its almost the same problem space. Almost
because TCP doesn't have feature negotiation, its the app that can use a
setsockopt to say what is the cong control module it wants to use,
despite what the other end wants, heck, the other end can and probably
will not even know if there were different cong control modules.
=20
> | =20
> |  We could have as default a table built with the modules we know at dccp
> |  core build time to be available in the current kernel build, but not
> |  prevent others from being added or existing ones to be disabled.
> The disabling can also be done on a per-connection basis, via socket opti=
ons.
> One pain with the server-priority negotiation (and reason for the table) =
is that
> when only a single value is used, then it only works if both ends happen =
to hit
> the same value. One can exploit this fact to limit the choices.
>=20
>=20
> |  So I think we can start with what you provided and implement my
> |  suggestions later.
> I am saving this in my todo folder and hope we can continue this thread.

OK! For now my thoughts are more on what-is-best-in-the-long-term, what
you have done so far is OK by me and I'll be reviewing those patches
soon. One thing is the pointer in the request_sock case that I have to
figure out what is best and possibly rework your patches to provide what
I think is best.

- Arnaldo
