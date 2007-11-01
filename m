From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 01 Nov 2007 11:00:15 +0000
Subject: Re: [PATCH 16/25] Share ccid3_hc_rx_sock struct and ccid3_hc_rx_sk function via tfrc_ccids
Message-Id: <200711011100.15295@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710312131.50615.leandroal@gmail.com>
In-Reply-To: <200710312131.50615.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

I think we need to get back to deciding on a naming scheme for the structs.=
 It is not
your fault, but with the current scheme the names become extremely cryptic:

|  + * =A0@tfrchcrx_last_counter =A0- =A0Tracks window counter (RFC 4342, 8=
.1)
|  + * =A0@tfrchcrx_state =A0- =A0Receiver state, one of %tfrc_hc_rx_states
|  + * =A0@tfrchcrx_bytes_recv =A0- =A0Total sum of DCCP payload bytes
|  + * =A0@tfrchcrx_x_recv =A0- =A0Receiver estimate of send rate (RFC 3448=
, sec. 4.3)
|  + * =A0@tfrchcrx_rtt =A0- =A0Receiver estimate of RTT
|  + * =A0@tfrchcrx_last_feedback =A0- =A0Time at which last feedback was s=
ent
|  + * =A0@tfrchcrx_hist =A0- =A0Packet history, exported by TFRC module
|  + * =A0@tfrchcrx_li_hist =A0- =A0Loss Interval database, exported by TFR=
C module
|  + * =A0@tfrchcrx_s =A0- =A0Received packet size in bytes
|  + * =A0@tfrchcrx_pinv =A0- =A0Inverse of Loss Event Rate (RFC 4342, sec.=
 8.5)
|  + */

Similar thing with the #defines - my eyes fail to parse this:
|  =A0#define ccid3_hc_tx_sk tfrc_hc_tx_sk
|  =A0
|  +#define ccid3_hc_rx_sock tfrc_hc_rx_sock
|  +#define ccid3hcrx_s tfrchcrx_s
|  +#define ccid3hcrx_x_recv tfrchcrx_x_recv
|  +#define ccid3hcrx_pinv tfrchcrx_pinv
|  +#define ccid3hcrx_last_feedback tfrchcrx_last_feedback
|  +#define ccid3hcrx_bytes_recv tfrchcrx_bytes_recv
|  +#define ccid3hcrx_last_counter tfrchcrx_last_counter
|  +#define ccid3hcrx_rtt tfrchcrx_rtt
|  +#define ccid3hcrx_s tfrchcrx_s
|  +#define ccid3hcrx_hist tfrchcrx_hist
|  +#define ccid3hcrx_li_hist tfrchcrx_li_hist

My suggestion is to use something like
	* `ttx_' for TFRC TX related structs/operations/fields
	* `trx_' for  "   RX  "             "
	* Arnaldo's scheme for the CCIDs=20
		-- c3rx_ / c4rx_ for RX structs/fields
		-- c3tx_ / c4tx_ for TX structs/fields

Of course that costs work. But now is probably the best time to change it -=
 so better
get it cleaned up before passing it on to Arnaldo.
