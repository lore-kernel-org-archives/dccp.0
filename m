From: Samuel Jero <sj323707@ohio.edu>
Date: Sun, 26 Dec 2010 19:40:26 +0000
Subject: Sequence Number Validation Bug Fixes 0/2
Message-Id: <1293392426.3801.234.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-lF5BYDGUXCKOXdDcQM+m"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-lF5BYDGUXCKOXdDcQM+m
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello All,

I have been examining DCCP for several months trying to understand
several odd behaviors that I ran across trying to utilize DCCP CCID 2
for a research project.

Over the course of that time I have become quite familiar with the DCCP
testing tree and with the DCCP protocol itself, particularly CCID 2. As
part of my examination, I wrote a tool to help graph DCCP connections.
This tool converts DCCP CCID 2 connections to TCP connections which can
then be analyzed with Tcptrace (http://tcptrace.org). (I can provide a
link to the tool if people are interested).

Examining the Graphs produced by this tool, I noticed some unusual
behaviors. The most interesting one was that at certain times the DCCP
receiver will renege on certain data segments in the Ack Vector and
renege on receiving an Ack from the sender (obvious by increasing the
length of the Ack Vector). Here is a picture:
http://jeroserver.homelinux.net/software/dccp/renege.jpg

It turns out this behavior is due to a nasty bug in the dccp sequence
number validation code (dccp_check_seqno in input.c). What happens is
that the receiver legitimately stops incrementing it's ack number
because packets from the sender are outside the valid Ack window (why
this happens is another problem I'm still working on). DCCP should send
a sync when this happens, but this sync needs to be rate-limited. If it
isn't time to send a sync, the DCCP code currently returns 0 which
indicates that the packet is good!!=20

As a result, the Ack Vector is updated. Since the data in the Ack Vector
is interpreted relative to the Ack number (which wasn't updated since
the packet was out of bounds), the Ack Vector appears to shift backwards
in time, producing the strange results already described.

I have put together a patch for this bug, which follows in a separate
email.

In examining this section of code, I also noticed that the the GSR is
updated by any packet in the valid sequence number window. I believe
this represents a minor bug, because it would allow the GSR to move
backward as a result of an out of order packet that is still in the
valid window. I am also sending a patch for that as a separate email.


Samuel Jero
Internetworking Research Group
Ohio University=20

--=-lF5BYDGUXCKOXdDcQM+m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0XmiYACgkQEwoGUlJjrt+NawCgumZ4RcjnqkxliH5Kv3f1j8Nf
tC8An3BPaHmKcrXfjni/mcxFcaE+BYOB
=s6b9
-----END PGP SIGNATURE-----

--=-lF5BYDGUXCKOXdDcQM+m--
