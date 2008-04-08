From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Tue, 08 Apr 2008 19:28:44 +0000
Subject: Re: [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <200804082128.44991.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 07 of April 2008, Gerrit Renker napisa=B3:
> We are always allocating (in dccp_init_sock and dccp_create_openreq_child=
),
> so why not make dp->dccps_qpolicy a static member rather than a pointer.
>
Then should I keep
	void dccp_qpolicy_destroy(struct sock *sk)
as an empty function or delete it? Later it might be used to call policy=20
specific destructor, but now it wouldn't look very useful...
--=20
Regards,
Tomasz Grobelny
