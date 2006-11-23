From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 23 Nov 2006 13:06:30 +0000
Subject: Re: Conditions when t_ipi, t_nom, t_delta need to be recalculated
Message-Id: <200611231306.30479@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611231302.45475@strip-the-willow>
In-Reply-To: <200611231302.45475@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  =A0 =A0 * nominal sending time: =A0 =A0t_nom =A0 =A0=3D =A0t_(i+1) + t_i=
pi =A0 =A0
=3D> should read                   t_nom    =3D  t_i     + t_ipi
