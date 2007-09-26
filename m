From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 26 Sep 2007 09:51:50 +0000
Subject: Re: [PATCH 7/8]: Handle timestamps on Request/Response exchange separately
Message-Id: <200709261051.50499@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.48514@strip-the-willow>
In-Reply-To: <200709251530.48514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Oops -
|  (9 features x 2 locations=20
|  =A0 =A0 (local/remote) x 64bit (maximum option size) gives 1152 bytes=20
It is 1152/8 =3D 144 bytes, but still too much.
