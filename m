From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 02:57:49 +0000
Subject: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <200709061457.49593.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
References: <200708291113.07431.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291113.07431.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

(Resent with updates after Gerrit's review)

This patch set implements TFRC Faster Restart as per current draft.

Patche can also be found at:
http://wand.net.nz/~iam4/dccp/patches24/
(although do not apply patch 7)

The faster restart implementation was based on=20
draft-ietf-dccp-tfrc-faster-restart-03.txt.

The version of DCCP CCID3 in Gerrit's tree used as the base is (mostly)=20
draft-floyd-rfc3448bis-00.txt where the faster restart Internet Draft=20
specifies the use of draft-ietf-dccp-rfc3448bis-02.txt.

We did not implement all of the Internet Draft for faster restart as it was=
=20
either not required, or the base DCCP did not support the features required.

In particular the following features are missing:

=A0 =A0 * keep alive pings as per section 3.1. It has been proposed at IETF=
 69 to=20
remove these.
=A0 =A0 * the use of X_recv_set as per section 3.2. We use X_recv instead a=
s=20
X_recv_set is not part of rfc3448bis-00.txt
=A0 =A0 * Interpolation of X_fast_max as per section 3.2. This is used for =
idle=20
periods to scale back the faster restart and is used for idle periods in=20
minutes. As our tests are shorter than this in duration we have not=20
implemented. We have however provided the framework for this so it would be=
=20
trivial to complete this if desired.
=A0 =A0 * the measurement of the receive rate in the last RTT as per sectio=
n 4.2.=20
We have left our implementation at the receive rate since last feedback sen=
t=20
for simplicity of implementation. We do not believe that this would have a =

material affect, and it would equally affect both the standard implementati=
on=20
and faster restart so it would be cancelled out.
