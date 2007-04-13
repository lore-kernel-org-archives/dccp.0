From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 18:48:02 +0000
Subject: Re: [PATCH 19/25]: Remove unused fields in packet history structure
Message-Id: <200704131948.03194@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211845.41809@strip-the-willow>
In-Reply-To: <200703211845.41809@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  struct dccp_tx_hist_entry {
|  =A0 =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0 =A0 dccphtx_node; =A0 =
=A0 =A0 =A0 /* =A0 =A0 0 =A0 =A016 */
|  =A0 =A0 =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dccph=
tx_seqno; =A0 =A0 =A0 =A0/* =A0 =A016 =A0 =A0 8 */
|  =A0 =A0 =A0 =A0 struct timeval =A0 =A0 =A0 =A0 =A0 =A0 dccphtx_tstamp; =
=A0 =A0 =A0 /* =A0 =A024 =A0 =A016 */
|  }; /* size: 40, cachelines: 1 */
|  =A0 =A0/* last cacheline: 40 bytes */
|  [acme@mica net-2.6.22]$
| =20
|  I wonder if we could make this a single linked list, lemme see.. I
|  think so, and by doing that we get the struct down to 32 bytes, making
|  it cacheline friendly, and also simplify the operations, i.e. that
|  opencoded list operation would just go away, will leave this for
|  later, in a TODO file.
This is an excellent idea - I have just checked. It works, there is no sort=
ing
and just LIFO order.=20

Will you be working on this or would you like me to update this in terms of=
=20
struct hlist_head?
