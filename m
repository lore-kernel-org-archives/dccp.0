From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 24 Apr 2008 22:16:18 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: External interface changes
Message-Id: <200804250016.19280.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080424220704.0483DBC12@poczta.oswiecenia.net>
In-Reply-To: <20080424220704.0483DBC12@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Thursday 24 of April 2008, napisa=B3e=B6:
> +	skb->priority =3D info.priority;
Here, as David pointed out, we are not sure wheter skb->priority can be use=
d.=20
But that's not the point of this patch. The point is to request for comment=
=20
when it comes to separation of externally visible interface and internal pe=
r=20
skb data storage.

> +	printk("pushing prio: %d\n", skb->priority);
And that is of course a simple mistake.
--=20
Regards,
Tomasz Grobelny
