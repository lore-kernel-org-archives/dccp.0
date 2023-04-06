From: Breno Leitao <leitao@debian.org>
Date: Thu, 06 Apr 2023 15:59:53 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <ZC7seVq7St6UnKjl@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, Apr 06, 2023 at 11:34:28AM -0400, Willem de Bruijn wrote:
> On Thu, Apr 6, 2023 at 10:45=E2=80=AFAM Breno Leitao <leitao@debian.org> =
wrote:
> >
> > From: Breno Leitao <leit@fb.com>
> >
> > This patchset creates the initial plumbing for a io_uring command for
> > sockets.
> >
> > For now, create two uring commands for sockets, SOCKET_URING_OP_SIOCOUTQ
> > and SOCKET_URING_OP_SIOCINQ. They are similar to ioctl operations
> > SIOCOUTQ and SIOCINQ. In fact, the code on the protocol side itself is
> > heavily based on the ioctl operations.
>=20
> This duplicates all the existing ioctl logic of each protocol.
>=20
> Can this just call the existing proto_ops.ioctl internally and translate =
from/to
> io_uring format as needed?

This is doable, and we have two options in this case:

1) Create a ioctl core function that does not call `put_user()`, and
call it from both the `udp_ioctl` and `udp_uring_cmd`, doing the proper
translations. Something as:

	int udp_ioctl_core(struct sock *sk, int cmd, unsigned long arg)
	{
		int amount;
		switch (cmd) {
		case SIOCOUTQ: {
			amount =3D sk_wmem_alloc_get(sk);
			break;
		}
		case SIOCINQ: {
			amount =3D max_t(int, 0, first_packet_length(sk));
			break;
		}
		default:
			return -ENOIOCTLCMD;
		}
		return amount;
	}

	int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
	{
		int amount =3D udp_ioctl_core(sk, cmd, arg);

		return put_user(amount, (int __user *)arg);
	}
	EXPORT_SYMBOL(udp_ioctl);


2) Create a function for each "case entry". This seems a bit silly for
UDP, but it makes more sense for other protocols. The code will look
something like:

	 int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
	 {
		switch (cmd) {
		case SIOCOUTQ:
		{
			int amount =3D udp_ioctl_siocoutq();
			return put_user(amount, (int __user *)arg);
		}
		...
	  }

What is the best approach?
