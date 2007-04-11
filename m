From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Apr 2007 09:13:22 +0000
Subject: Re: [PATCH 4/5]: Rate-limit DCCP-Syncs
Message-Id: <200704111013.22148@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704091058.57313@strip-the-willow>
In-Reply-To: <200704091058.57313@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > +sync_ratelimit =3D HZ/8
|  > + =A0 =A0 =A0 The timeout between subsequent DCCP-Sync packets sent in=
 response to
|  > + =A0 =A0 =A0 sequence-invalid packets on the same socket (RFC 4340, 7=
.5.4). The unit
|  > + =A0 =A0 =A0 of this parameter is jiffies; a value of 0 disables rate=
-limiting.
|  > +
| =20
|  No, no, no. A userspace parameter in jiffies is just wrong I think.
|  You change HZ and this doesn't automatically change. You could be
|  doing this with different kernels on your machine even and setting
|  sysctls in a file. Take a bit of time and put this in milliseconds.
The default value is set at compilation time when HZ is known. I used jiffi=
es for the
main reason to make this sysctl consistent with the other, similar, runtime=
 variables
which are also in units of jiffies (cf. Documentation/networking/ip-sysctl.=
txt):

 * inet_peer_minttl / inet_peer_maxttl / inet_peer_gc_mintime / inet_peer_g=
c_maxtime

 * icmp_ratelimit - which is semantically the closest to this sysctl

Would you still rather have this in milliseconds?
