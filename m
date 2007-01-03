From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 12:23:42 +0000
Subject: Re: [PATCH 1/1] DCCP: Reorganise loss interval code
Message-Id: <200701031223.42537@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612220924.34663.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612220924.34663.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > =A0=3D> However, I am not sure that the way =A0ccid3_hc_rx_update_li()=
 is called is as
|  > =A0 =A0 =A0intentioned.
|  >
|  Not sure what you mean here. Can you explain?
The parameters of ccid3_hc_rx_update_li() are:

ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
{
	// ...=20
	// The following is executed if hcrx->ccid3hcrx_li_hist is non-empty:

	/* calculate last interval length */
	seq_temp =3D dccp_delta_seqno(head->dccplih_seqno, seq_loss)

	/* Create the newest interval */
	entry->dccplih_seqno =3D seq_loss;
	entry->dccplih_interval =3D seq_temp;
	entry->dccplih_win_count =3D win_loss;
}

From this it appears that seq_loss / win_loss are associated with _loss_.
However, in ccid3_hc_rx_detect_loss they are called as:


	ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
		   hcrx->ccid3hcrx_ccval_nonloss)

which refers to the _nonloss_ variants. Loss or non_loss?
