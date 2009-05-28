From: lotfi amirouche <lotfi.amirouche@gmail.com>
Date: Thu, 28 May 2009 14:16:21 +0000
Subject: DCCP socket option TX/RX info
Message-Id: <37b5be5c0905280716o4ed3132bpcdc7f2b84a682f40@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi,

I am a master student in Montb=E9liard, France, and I do my internship
project on DCCP utilisation on linux. =A0I noticed two issues:

- RFC 3448 (3.2.2): "X_recev is the receiver estimate of sending rate
which is sent by the receiver to the sender"; x_recev matches the
value of tfrcrx_x_recv in the struct tfrc_rx_info, and the value of
tfrctx_x_recv in struct tfrc_rx_info, so the issue is that values of
(tfrctx_x_recv,tfrcrx_x_recv) are different, is it normal?

- if these values should be the same, why in the code source tfrc.h,
tfrcrx_x_recv is declared as _U32, and tfrctx_x_recv as _U64?

And a question:

- on the sender, is it possible that the application know about the
buffer length at the DCCP level (i.e. how many packets are awaiting to
be sent)?

Thank you,
