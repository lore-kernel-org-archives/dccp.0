From: Samuel Jero <sj323707@ohio.edu>
Date: Thu, 30 Dec 2010 20:16:14 +0000
Subject: Re: Sequence Number Validation Bug Fixes 0/2
Message-Id: <1293740175.22785.71.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-ldn+MaBMaj6us2+/8zVP"
List-Id: <dccp.vger.kernel.org>
References: <1293392426.3801.234.camel@jero-laptop>
In-Reply-To: <1293392426.3801.234.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-ldn+MaBMaj6us2+/8zVP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Gerrit,

> | This tool converts DCCP CCID 2 connections to TCP connections which can
> | then be analyzed with Tcptrace (http://tcptrace.org). (I can provide a
> | link to the tool if people are interested).
> |=20
> Please do -- such a tool has been missing for a long time, and the idea t=
o hook
> it up with tcptrace is both original and efficient. Analysing Ack Vectors=
 using
> tcpdump/wireshark is very tedious, so anything that can help in debugging=
 Ack
> Vector traces is a great help.

The tool can be downloaded from here:
http://jeroserver.homelinux.net/software/dccp/files/dccp2tcp.tar.gz
or here: http://oak.cats.ohiou.edu/~sj323707/dccp2tcp.tar.gz

At the moment I'm calling it dccp2tcp and releasing it under the GNU
GPL. Right now, the tool only understands DCCP over IPv4 over Ethernet
and only compiles on Linux.

I've included a README file that explains the commandline args and what
the various parts of the Tcptrace graphs represent. The short story is
you probably want to run it like this: dccp2tcp -s dccp_file tcp_file

>=20
> | It turns out this behavior is due to a nasty bug in the dccp sequence
> | number validation code (dccp_check_seqno in input.c). What happens is
> | that the receiver legitimately stops incrementing it's ack number
> | because packets from the sender are outside the valid Ack window (why
> | this happens is another problem I'm still working on). DCCP should send
> | a sync when this happens, but this sync needs to be rate-limited. If it
> | isn't time to send a sync, the DCCP code currently returns 0 which
> | indicates that the packet is good!!=20
> |=20
> Thanks a lot, you have found a real bug. I have edited your patch since
> Evolution squeezed tabs into whitespaces, and added your Signed-off --
> please check the attached result, as I would like to submit this soon.
>
Looks good. You have my okay to submit it.
>=20
> With regard to not updating the Ack Number, I remember having seen someth=
ing
> related earlier. There is a relationship between the current sending rate=
, the
> Ack Ratio, the cwnd, and the Sequence Window. The Ack window is advanced =
by the
> GSS and depends on the local value of the Sequence Window. RFC 4340, 7.5.=
2
> recommends 5 * max_packets_per_RTT as guideline for Sequence Window.
>=20
> When I looked at this earlier I noted that the dynamic update of Ack Rati=
o,
> cwnd, and Sequence Window (which are all inter-related, but are controlle=
d
> by different code paths) does not produce the expected interaction, there=
fore
> Ack Ratio is currently always 1 and Sequence Window is also static and do=
es
> not change throughout the connection.=20
>=20
> It may be that both these shortcuts cause the behaviour you observed. The
> Ack Ratio update is disabled in net/dccp/feat.c:dccp_hdlr_ack_ratio(), bu=
t
> there is currently no code to predict (guess) what the sending rate will
> be for the next 5 RTTs -- if such a heuristic is possible.

Interesting, but I don't think that's what I'm seeing.

What I'm noticing is that the DCCP sender doesn't update it's ack
numbers very often. In examining packet captures, it is typical for DCCP
to send 20-60 packets with the same ack number (If I increase the ack
and seq validity windows to 1000, I've seen 200 packets with the same
ack number).

Since the receiver should ack every packet it gets, I would think that
we should see very few packets (1-2) sent before a new ack packet comes
and updates the GSR and hence the outgoing packet's ack numbers.

Some debugging output (printk at every send and receive) seems to
indicate that the sending and receiving are happening in large chunks
and not in small slices (we send 50 packets, then receive 20 packets,
etc).

At the moment I don't have a clue why that would happen. Thoughts/ideas
would be appreciated.

>=20
> I am interested in suggestions to improve this.
>=20
> | In examining this section of code, I also noticed that the the GSR is
> | updated by any packet in the valid sequence number window. I believe
> | this represents a minor bug, because it would allow the GSR to move
> | backward as a result of an out of order packet that is still in the
> | valid window. I am also sending a patch for that as a separate email.
> |
> Excellent catch, there is a second bug here. Apart from the clerical edit=
s
> (please consult Documentation/SubmittingPatches), there is a small
> modification, sent in response to the other patch.

Thanks for the reference to Documentation/SubmittingPatches. Good
information to know.

Comments on the other patch following in a separate email.

Samuel Jero
Internetworking Research Group
Ohio University

--=-ldn+MaBMaj6us2+/8zVP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0c6IUACgkQEwoGUlJjrt+l8QCgkgfQ3t8tTZdxGOw9r3wTxKsn
vt0AoIKqbLmnNhZjPhDUruoL6HFLzJMB
=LBdv
-----END PGP SIGNATURE-----

--=-ldn+MaBMaj6us2+/8zVP--
