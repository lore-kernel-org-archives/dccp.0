From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 14:04:51 +0000
Subject: Re: [PATCH] DCCP: remove timeo from output.c
Message-Id: <200612051404.51988@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612041356s6fbba9abvc1616e28a9619f4f@mail.gmail.com>
In-Reply-To: <5640c7e00612041356s6fbba9abvc1616e28a9619f4f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Nice work Ian!
|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

|  +=A0=A0=A0=A0=A0=A0=A0unsigned long delay;
With regard to the delay, I think we are now fairly on the safe side. Altho=
ugh schedule_timeout
takes `signed long', the value of delay can not be large: as per earlier di=
scussion (regarding the
return type of dccp_hc_tx_send_packet), the delay is bounded by sending one=
 packet in 64 seconds,
hence the maximum delay is 1/64 sec =3D 15.625 milliseconds (I am not sugge=
sting to use `u8' :)

Have signed off and uploaded as 10a onto http://www.erg.abdn.ac.uk/users/ge=
rrit/dccp/patch-backlog/
I did some performance testing which ended asking my boss for a faster comp=
uter, since on this one
the figures get strange as soon as system load increases.

I think we need something other than iperf to do the profiling - at the mom=
ent it does not at all
act in a reproducible or predictable way.
