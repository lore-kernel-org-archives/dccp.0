From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jun 2007 08:18:08 +0000
Subject: Re: [PATCH 2/5]: History access is redundant when sending feedback
Message-Id: <200706250918.08630@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706141005.07993@strip-the-willow>
In-Reply-To: <200706141005.07993@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > This patch
|  > =A0 1. removes redundant use of packet history for sending feedback
|  > =A0 =A0 =A0(data packet is no longer `found', just referenced);
|  > =A0 2. which obsoletes function dccp_rx_hist_find_data_packet - remove=
d;
|  > =A0 3. removes an irrelevant state `TERM' (feedback is then not sent);
|  > =A0 4. removes redundant variable `last_ack' (duplicates `last_feedbac=
k');
|  > =A0 5. converts rx_send_feedback() to use the newer timeofday interfac=
e;
|  > =A0 6. simplify the computation of p/p_inv (see note below).
|  >
|  Great - making code much simpler - makes it easier for people like me
|  to understand!
... and people like me too. I think it is good to keep code as simple as po=
ssible,
to better see the interactions. Thank you for really going through the patc=
hes
individually, I'd especially appreciate input for further simplifications. =
After
talking to Arnaldo recently, there is at least one further patch to further=
 reduce=20
- removing redundant initialisations with `0' in tx_init/rx_init.
