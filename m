From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 16 Nov 2006 17:45:19 +0000
Subject: Re: [BUG] DCCP performance stops on CCID3 at times
Message-Id: <200611161745.20056@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611161055.31036.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200611161055.31036.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  I'm still working on it but anybody else can feel free to help!
It is great to see that this is picked up. It is one of the items which I h=
ad put onto the ToDo list as well,
the thread starting this began on=20
		http://www.mail-archive.com/dccp%40vger.kernel.org/msg00446.html


|  And now I get these subcases:
|  Nov  2 21:22:21 localhost kernel: [26564.665163] ccid3_hc_rx_calc_first_=
li: p =3D 0, fval =3D 7046
|  This is due to the computed x_recv being very, very low I believe. So it=
 sets it to ~0
| =20
|  Nov  2 21:22:21 localhost kernel: [26564.665381] dccp_li_hist_calc_i_mea=
n: w_tot =3D 0
|  Nov  3 02:27:46 localhost kernel: [44880.646467] ccid3_hc_rx_calc_first_=
li: server, sk=DC04b16c, Could not find a win_count interval > 0. Defaultin=
g to 1
|  Nov  3 02:27:46 localhost kernel: [44880.646538] tmp2 =3D 0 ccid3_hc_rx_=
calc_first_li: x_recv =3D 0, rtt =3D1
I wonder whether this is due to the RTT, due to the following statement in =
ccid3_hc_rx_calc_first_li:
	if (rtt =3D 0)
		rtt =3D 1;
Maybe it would be good to print out when the RTT estimate is zero (with reg=
ard to the other email, I am still
puzzled about the Receiver-RTT measurement). The same statement re-appears =
in tfrc_calc_x (to avoid division-by-zero),=20
without warning.=20
I think that a warning message could bring in some light: maybe it is the c=
ase here that the RTT measurement is just
at rock bottom, always returns 0,  and thus always stays at 1.=20


It would be great if you could come up with something, you know this code b=
est. I have put it into my `TBD' folder
and may just pester with emails later ;-)=20

There is another thread which I think may be of relevance, incidentally aga=
in at the rx_packet_recv function:

	http://www.mail-archive.com/dccp%40vger.kernel.org/msg00118.html

I put this also into the ToDo list, but I am still stuck with other work. M=
aybe we could kill all those ToDos in=20
one swoop?

-- Gerrit
=20
